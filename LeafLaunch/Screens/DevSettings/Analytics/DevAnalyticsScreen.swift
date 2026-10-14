//
//  DevAnalyticsScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 10/19/24.
//

import SwiftUI
import Charts

struct DevAnalyticsScreen: GPView {

    @Environment(\.style) private var style

    @StateObject var viewModel: DevAnalyticsViewModel
    @Environment(NavigationService.self) private var navigationService

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {

            headerView()
                .padding(.bottom, .extraSmall)

        } scrollViewContent: {

            content()

        }

        // Lifecycle

        .onFirstAppear { [weak viewModel] in

            viewModel?
                .handleFirstAppear()

            viewModel?
                .setup(navigationService: self.navigationService)

        }

    }

    @ViewBuilder
    private func headerView() -> some View {

        VStack {

            NavBarView(
                title: "Analytics",
                leftButtonView: (
                    NavBarButton(style: .back) {
                        self.viewModel.dismiss()
                    }
                ).asAnyView()
            )

            segmentedControl()

            switch self.viewModel.selectedDisplayType {
            case .logs: logFilterHeaderView()
            case .analytics: EmptyView()
            case .api: EmptyView()
            }

            actionHeaderView()

        }

    }

    private func segmentedControl() -> some View {

        let allOptions = DevAnalyticsViewModel.DisplayType.allCases.map({ $0.rawValue.capitalized })

        return CommonSegmentedControl(
            selectedOption: self.$viewModel.selectedDisplayTypeString,
            options: allOptions,
            selectedTextColor: .text(.titleInverted)
        )
        .padding(.top, .small)
        .padding(.horizontal, .medium)

    }

    @ViewBuilder
    private func logFilterHeaderView() -> some View {

        FiltersViewPreview(
            filters: self.viewModel.allOSLogOptions,
            selectedFilter: self.$viewModel.selectedOSLogTypeString,
            selectedFilterColor: .color(self.viewModel.selectedOSLogType?.color() ?? .clear),
            filterSelectedText: .text(.titleInverted)
        )
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, .small)
        .transition(.move(edge: .top).combined(with: .opacity).animation(.bouncy))

    }

    @ViewBuilder
    private func actionHeaderView() -> some View {

        HStack {

            TokenView(
                text: "\(self.viewModel.clearActionTitle) (\(self.viewModel.selectedDisplayCount))",
                foregroundStyle: .text(.button),
                backgroundStyle: .color(.red)
            )
            .asButton {
                self.viewModel.clearSelectedData()
            }

            Spacer(minLength: 0)

        }
        .padding(.horizontal, .medium)
        .padding(.bottom, .small)

    }

    private func content() -> some View {

        LazyVStack(spacing: self.style.spacing(.medium)) {

            switch self.viewModel.selectedDisplayType {
            case .logs:

                logEventsList()
                    .transition(
                        .opacity
                            .combined(with: .blurReplace)
                            .combined(with: .move(edge: .bottom))
                    )

            case .analytics:

                analyticsList()
                    .transition(
                        .opacity
                            .combined(with: .blurReplace)
                            .combined(with: .move(edge: .bottom))
                    )

            case .api:

                apiList()
                    .transition(
                        .opacity
                            .combined(with: .blurReplace)
                            .combined(with: .move(edge: .bottom))
                    )
            }

        }
        .animation(.bouncy, value: self.viewModel.logEvents)

    }

    private func section(title: String) -> some View {

        Group {

            LazyVStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(title)
                    .appFont(with: .HEADER_4)
                    .foregroundStyle(.text(.title))

                Divider()
                    .background(.text(.body))

            }

        }

    }

    private func logEventsList() -> some View {

        let events = self.viewModel.logEvents.reversed()

        return LazyVStack(spacing: self.style.spacing(.medium)) {

            section(title: "Log Events")

            ForEach(events, id: \.id) { event in
                logEventView(event)
            }

        }

    }

    private func analyticsList() -> some View {

        let events = self.viewModel.events.reversed()

        return LazyVStack(spacing: self.style.spacing(.medium)) {

            section(title: "Analytic Events")

            ForEach(events, id: \.id) { event in
                analyticsView(event)
            }

        }

    }

    private func apiList() -> some View {

        return LazyVStack(spacing: self.style.spacing(.medium)) {

            section(title: "API Logs")

            ForEach(viewModel.allAPILogResponses, id: \.date) { apiLogResponse in
                apiView(apiLogResponse)
            }

        }

    }

    private func analyticsView(_ eventData: EventData) -> some View {

        AppCardView {

            VStack(alignment: .leading) {

                Text(eventData.name)
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(.text(.title))

                if let properties = eventData.properties {
                    JSONPreviewView(jsonData: properties)
                }

                Text(
                    eventData.createdAt,
                    format: .dateTime.day().month().year().hour().minute().second()
                )
                .appFont(with: .BODY_1)
                .foregroundStyle(.text(.body))

            }

        }

    }

    private func apiView(_ apiLogResponse: APILogResponse) -> some View {

        return AppCardView {

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                Group {

                    VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                        Text("Method: \(apiLogResponse.method)")
                            .appFont(with: .TITLE_3)
                            .foregroundStyle(.text(.title))

                        Text("Status Code: \(apiLogResponse.statusCode)")
                            .appFont(with: .TITLE_3)
                            .foregroundStyle(apiLogResponse.statusCode < 400 ? .green : .red)

                        Text("Path: \(apiLogResponse.path)")
                            .appFont(with: .BODY_1)
                            .foregroundStyle(.text(.body))

                    }

                }

                VStack(alignment: .leading) {

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

                Text(
                    apiLogResponse.date,
                    format: .dateTime.day().month().year().hour().minute().second()
                )
                .appFont(with: .BODY_1)
                .foregroundStyle(.text(.body))

            }

        }

        func buildJSONPreviewView(title: String,
                                  json: [String: Any]) -> some View {

            VStack(alignment: .leading) {

                Text(title)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(.text(.title))

                JSONPreviewView(
                    jsonData: json,
                    titleFont: .TITLE_2,
                    subtitleFont: .TITLE_2,
                    bodyFont: .TITLE_2,
                    maxHeight: 120
                )

            }

        }

    }

    private func logEventView(_ logEvent: LogEvent) -> some View {

        AppCardView(
            verticalPadding: .none,
            horizontalPadding: .none
        ) {

            HStack {

                Rectangle()
                    .fill(logEvent.level.color())
                    .frame(width: 8)

                VStack(alignment: .leading) {

                    HStack {

                        CircularIconView(
                            foregroundColor: .color(logEvent.level.color()),
                            backgroundColor: .color(logEvent.level.color().opacity(0.1)),
                            imageSource: .systemImage(logEvent.level.systemImage()),
                            size: 32
                        )

                        Text(logEvent.level.displayName())
                            .appFont(with: .TITLE_3)
                            .foregroundStyle(logEvent.level.color())

                    }

                    Text(logEvent.title)
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(.text(.title))

                    Text(logEvent.message)
                        .appFont(with: .BODY_3)
                        .foregroundStyle(.text(.body))
                        .padding(.top, .custom(2))

                    VStack(alignment: .leading) {

                        HStack {

                            if let emoji = logEvent.emoji {

                                Text(emoji)
                                    .appFont(with: .TITLE_3)
                                    .foregroundStyle(.text(.title))

                            }

                            Text(logEvent.source)
                                .appFont(with: .BODY_2)

                        }

                        Text(
                            logEvent.createdAt,
                            format: .dateTime.day().month().year().hour().minute().second()
                        )
                        .appFont(with: .BODY_1)

                    }
                    .padding(.top, .medium)
                    .foregroundStyle(.text(.body))

                }
                .padding(.leading, .small)
                .padding([.vertical, .trailing], .medium)

            }
            .background(.backgroundTappable)
            .clipShape(.rect)

        }

    }

}

#Preview {

    DevAnalyticsScreen(
        viewModel: mockResolve(DevAnalyticsViewModel.self)
    )
    .withMockServices()

}
