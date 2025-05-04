//
//  DevAnalyticsScreen.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 10/19/24.
//

import SwiftUI
import Charts

struct DevAnalyticsScreen: View {
    
    @StateObject var viewModel: DevAnalyticsViewModel
    @Environment(NavigationService.self) private var navigationService
    
    var body: some View {
        
        AppHeaderScrollView {
            
            headerView()
                .padding(.bottom, .extraSmall)
            
        } scrollViewContent: {
            
            content()
            
        }
        
        // Lifecycle
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }
        
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        VStack {
            
            NavBarView(
                title: "Analytics",
                leftButtonView: (
                    BackButton {
                        self.viewModel.dismiss()
                    }
                ).asAnyView()
            )
            
            segmentedControl()
            
            switch self.viewModel.selectedDisplayType {
            case .logs: logFilterHeaderView()
            case .analytics: EmptyView()
            }
            
        }
        
    }
    
    private func segmentedControl() -> some View {
        
        let allOptions = DevAnalyticsViewModel.DisplayType.allCases.map({ $0.rawValue.capitalized })
        
        return CommonSegmentedControl(
            selectedOption: self.$viewModel.selectedDisplayTypeString,
            options: allOptions
        )
        .padding(.top, .small)
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func logFilterHeaderView() -> some View {
        
        FiltersViewPreview(
            filters: self.viewModel.allOSLogOptions,
            selectedFilter: self.$viewModel.selectedOSLogTypeString,
            selectedFilterColor: .color(self.viewModel.selectedOSLogType?.color() ?? .pink)
        )
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, .small)
        .transition(.move(edge: .top).combined(with: .opacity).animation(.bouncy))
        
    }
    
    private func content() -> some View {
        
        LazyVStack(spacing: Style.shared.spacing(.medium)) {
            
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
            }
            
        }
        .animation(.bouncy, value: self.viewModel.logEvents)
        
    }
    
    private func section(title: String) -> some View {
        
        Group {
            
            LazyVStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                
                Text(title)
                    .appFont(with: .HEADER_H5)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Divider()
                    .background(Style.shared.textColor(.body).source())
                
            }
            
        }
        
    }
    
    private func logEventsList() -> some View {
        
        let events = self.viewModel.logEvents.reversed()
        
        return LazyVStack(spacing: Style.shared.spacing(.medium)) {
            
            section(title: "Log Events")
            
            ForEach(events, id: \.id) { event in
                logEventView(event)
            }
            
        }
        
    }
    
    private func analyticsList() -> some View {
        
        let events = self.viewModel.events.reversed()
        
        return LazyVStack(spacing: Style.shared.spacing(.medium)) {
            
            section(title: "Analytic Events")
            
            ForEach(events, id: \.id) { event in
                analyticsView(event)
            }
            
        }
        
    }
    
    private func analyticsView(_ eventData: EventData) -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading) {
                
                Text(eventData.name)
                    .appFont(with: .TITLE_T4)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                if let properties = eventData.properties {
                    JSONPreviewView(jsonData: properties)
                }
                
                Text(
                    eventData.createdAt,
                    format: .dateTime.day().month().year().hour().minute().second()
                )
                .appFont(with: .BODY_B1)
                .foregroundStyle(Style.shared.textColor(.body).source())
                
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
                            size: 32,
                            imageSource: .systemImage(logEvent.level.systemImage())
                        )
                        
                        Text(logEvent.level.displayName())
                            .appFont(with: .TITLE_T4)
                            .foregroundStyle(logEvent.level.color())
                        
                    }
                    
                    Text(logEvent.title)
                        .appFont(with: .TITLE_T4)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                    Text(logEvent.message)
                        .appFont(with: .BODY_B5)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .padding(.top, .custom(2))
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            
                            if let emoji = logEvent.emoji {
                                
                                Text(emoji)
                                    .appFont(with: .TITLE_T4)
                                    .foregroundStyle(Style.shared.textColor(.title).source())
                                
                            }
                            
                            Text(logEvent.source)
                                .appFont(with: .BODY_B4)
                            
                        }
                        
                        Text(
                            logEvent.createdAt,
                            format: .dateTime.day().month().year().hour().minute().second()
                        )
                        .appFont(with: .BODY_B1)
                        
                    }
                    .padding(.top, .medium)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    
                }
                .padding(.leading, .small)
                .padding([.vertical, .trailing], .medium)
                
            }
            .background(.backgroundTappable)
            .clipShape(.rect)
            
        }
        
    }
    
    private func tokenView(text: String) -> some View {
        
        TokenView(
            text: text,
            foregroundStyle: Style.shared.textColor(.title),
            backgroundStyle: Style.shared.accent
        )
        
    }
    
}

#Preview {
    
    DevAnalyticsScreen(
        viewModel: mockResolve(DevAnalyticsViewModel.self)
    )
    .withMockServices()
    
}
