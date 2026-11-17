//
//  DevAnalyticsListScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 10/19/24.
//

import SwiftUI
import Charts

struct DevAnalyticsListScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject var viewModel: DevAnalyticsListViewModel

    var body: some View {

        LLAppHeaderScrollView {

            headerView()
                .runePadding(.bottom, LLSpacing.metadata)

        } scrollViewContent: {

            content()

        }

        // Lifecycle

        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

    }

    @ContentBuilder
    private func headerView() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            NavHeader(
                title: "Analytics",
                leadingNavButtons: [.back],
                leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
            )

            segmentedControl()

            switch self.viewModel.selectedDisplayType {
            case .logs:

                logFilterHeaderView()

            case .analytics: EmptyView()
            case .api: EmptyView()
            }

            actionHeaderView()

        }

    }

    @ContentBuilder
    private func segmentedControl() -> some View {

        let allOptions = DevAnalyticsListViewModel.DisplayType.allCases.map(\.title)

        LLSegmentedControl(
            selectedOption: self.$viewModel.selectedDisplayTypeString,
            options: allOptions,
            selectedTextColor: .text(.titleInverted)
        )
        .runePadding(.top, LLSpacing.groupedContent)
        .runePadding(.horizontal, LLSpacing.pageInset)

    }

    @ContentBuilder
    private func logFilterHeaderView() -> some View {

        RNFiltersViewPreview(
            filters: self.viewModel.allOSLogOptions,
            selectedFilter: self.$viewModel.selectedOSLogTypeString,
            selectedFilterColor: .color(self.viewModel.selectedOSLogType?.color() ?? .clear),
            filterSelectedText: .text(.titleInverted)
        )
        .fixedSize(
            horizontal: false,
            vertical: true
        )
        .runePadding(.vertical, LLSpacing.groupedContent)
        .transition(.move(edge: .top).combined(with: .opacity).animation(.bouncy))

    }

    @ContentBuilder
    private func actionHeaderView() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            RNTokenView(
                text: "\(self.viewModel.clearActionTitle) (\(self.viewModel.selectedDisplayCount))",
                foregroundStyle: .text(.button),
                backgroundStyle: .color(.red)
            )
            .runeAsButton {
                self.viewModel.clearSelectedData()
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .runePadding(.horizontal, LLSpacing.pageInset)
        .runePadding(.bottom, LLSpacing.groupedContent)

    }

    @ContentBuilder
    private func content() -> some View {

        LazyVStack(spacing: self.style.spacing(LLSpacing.listRow)) {

            switch self.viewModel.selectedDisplayType {
            case .logs:

                logEventsList()

            case .analytics:

                analyticsList()

            case .api:

                apiList()
            }

        }
        .llBlurReplace(
            value: self.viewModel.selectedDisplayType,
            transition: AnyTransition.opacity
                .combined(with: AnyTransition(.blurReplace))
                .combined(with: .move(edge: .bottom))
        )
        .animation(
            .bouncy,
            value: self.viewModel.logEvents
        )

    }

    @ContentBuilder
    private func section(title: String) -> some View {

        Group {

            LazyVStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.metadata)
            ) {

                Text(title)
                    .runeFont(with: LeafLaunchThemeTokens.headingFont)
                    .runeTextColor(.title)

                LLDivider()

            }

        }

    }

    @ContentBuilder
    private func logEventsList() -> some View {

        let events = self.viewModel.logEvents.reversed()

        LazyVStack(spacing: self.style.spacing(LLSpacing.listRow)) {

            section(title: "Log Events")

            ForEach(events, id: \.id) { event in
                logEventView(event)
            }

        }

    }

    @ContentBuilder
    private func analyticsList() -> some View {

        let events = self.viewModel.events.reversed()

        LazyVStack(spacing: self.style.spacing(LLSpacing.listRow)) {

            section(title: "Analytic Events")

            ForEach(events, id: \.id) { event in
                analyticsView(event)
            }

        }

    }

    @ContentBuilder
    private func apiList() -> some View {

        LazyVStack(spacing: self.style.spacing(LLSpacing.listRow)) {

            section(title: "API Logs")

            ForEach(self.viewModel.allAPILogResponses, id: \.date) { apiLogResponse in
                apiView(apiLogResponse)
            }

        }

    }

    @ContentBuilder
    private func analyticsView(_ eventData: EventData) -> some View {

        LLAppCardView {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                Text(eventData.name)
                    .runeFont(with: .TITLE_3)
                    .runeTextColor(.title)

                if let properties = eventData.properties {
                    RNJSONPreviewView(jsonData: properties)
                }

                Text(
                    eventData.createdAt,
                    format: .dateTime.day().month().year().hour().minute().second()
                )
                .runeFont(with: .BODY_1)
                .runeTextColor(.body)

            }

        }

    }

    @ContentBuilder
    private func apiView(_ apiLogResponse: APILogResponse) -> some View {

        LLAppCardView {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.cardContent)
            ) {

                apiSummary(apiLogResponse)
                apiPayloads(apiLogResponse)

                Text(
                    apiLogResponse.date,
                    format: .dateTime.day().month().year().hour().minute().second()
                )
                .runeFont(with: .BODY_1)
                .runeTextColor(.body)

            }

        }

    }

    @ContentBuilder
    private func apiSummary(_ apiLogResponse: APILogResponse) -> some View {

        Group {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.metadata)
            ) {

                Text("Method: \(apiLogResponse.method)")
                    .runeFont(with: .TITLE_3)
                    .runeTextColor(.title)

                Text("Status Code: \(apiLogResponse.statusCode)")
                    .runeFont(with: .TITLE_3)
                    .foregroundStyle(apiLogResponse.statusCode < 400 ? .green : .red)

                Text("Path: \(apiLogResponse.path)")
                    .runeFont(with: .BODY_1)
                    .runeTextColor(.body)

            }

        }

    }

    @ContentBuilder
    private func apiPayloads(_ apiLogResponse: APILogResponse) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            let headerParameters = apiLogResponse.headers
            if !headerParameters.isEmpty {

                buildJSONPreviewView(
                    title: "Header Parameters:",
                    json: headerParameters
                )

            }

            let queryParameters = apiLogResponse.queryParameters
            if !queryParameters.isEmpty {

                buildJSONPreviewView(
                    title: "Query Parameters:",
                    json: queryParameters
                )

            }

            let bodyParameters = apiLogResponse.body
            if !bodyParameters.isEmpty {

                buildJSONPreviewView(
                    title: "Body Parameters:",
                    json: bodyParameters
                )

            }

            if let jsonResponse = apiLogResponse.responseJSON {

                buildJSONPreviewView(
                    title: "Response:",
                    json: jsonResponse
                )

            }

            if let error = apiLogResponse.error {

                buildJSONPreviewView(
                    title: "Error:",
                    json: ["message": error.getMessageForError()]
                )

            }

        }

    }

    @ContentBuilder
    private func buildJSONPreviewView(title: String,
                                      json: [String: Any]) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            Text(title)
                .runeFont(with: .TITLE_5)
                .runeTextColor(.title)

            RNJSONPreviewView(
                jsonData: json,
                titleFont: .TITLE_2,
                subtitleFont: .TITLE_2,
                bodyFont: .TITLE_2,
                maxHeight: 120
            )

        }

    }

    @ContentBuilder
    private func logEventView(_ logEvent: LogEvent) -> some View {

        LLAppCardView(
            verticalPadding: .none,
            horizontalPadding: .none
        ) {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                Rectangle()
                    .runeFill(.color(logEvent.level.color()))
                    .frame(width: 8)

                VStack(
                    alignment: .leading,
                    spacing: self.style.spacing(LLSpacing.groupedContent)
                ) {

                    logLevel(logEvent)

                    Text(logEvent.title)
                        .runeFont(with: .TITLE_3)
                        .runeTextColor(.title)

                    Text(logEvent.message)
                        .runeFont(with: .BODY_3)
                        .runeTextColor(.body)
                        .runePadding(.top, LLSpacing.tightMetadata)

                    logMetadata(logEvent)

                }
                .runePadding(.leading, LLSpacing.groupedContent)
                .runePadding([.vertical, .trailing], .medium)

            }
            .background(.backgroundTappable)
            .clipShape(.rect)

        }

    }

    @ContentBuilder
    private func logLevel(_ logEvent: LogEvent) -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            RNCircularIconView(
                foregroundColor: .color(logEvent.level.color()),
                backgroundColor: .color(logEvent.level.color().opacity(0.1)),
                imageSource: .systemImage(logEvent.level.systemImage()),
                size: 32
            )

            Text(logEvent.level.displayName())
                .runeFont(with: .TITLE_3)
                .foregroundStyle(logEvent.level.color())

        }

    }

    @ContentBuilder
    private func logMetadata(_ logEvent: LogEvent) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                if let emoji = logEvent.emoji {

                    Text(emoji)
                        .runeFont(with: .TITLE_3)
                        .runeTextColor(.title)

                }

                Text(logEvent.source)
                    .runeFont(with: .BODY_2)

            }

            Text(
                logEvent.createdAt,
                format: .dateTime.day().month().year().hour().minute().second()
            )
            .runeFont(with: .BODY_1)

        }
        .runePadding(.top, LLSpacing.listRow)
        .runeTextColor(.body)

    }

}

#Preview {

    DevAnalyticsListScreen(
        viewModel: mockResolve(DevAnalyticsListViewModel.self)
    )
    .withMockServices()

}
