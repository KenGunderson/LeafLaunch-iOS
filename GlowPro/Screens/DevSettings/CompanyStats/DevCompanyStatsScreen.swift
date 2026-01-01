//
//  DevCompanyStatsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/31/25.
//

import SwiftUI

struct DevCompanyStatsScreen: GPView {
    
    @StateObject var viewModel: DevCompanyStatsViewModel
    @Environment(NavigationService.self) private var navigationService
    
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium,
                            backgroundStyle: Style.shared.background(.primary)) {
            
            headerView()
            
        } scrollViewContent: {
            
            content()
            
        }
        
        // Lifecycle
        
        .task {
            
            self.viewModel
                .loadData()
            
        }
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }
        
        // On Change
        
        .onChange(of: self.viewModel.selectedInterval) { oldValue, newValue in
            
            guard let newValue else { return }
            guard newValue != oldValue else { return }
            
            self.viewModel
                .loadData()
            
        }
        
        // Animations
        .animation(.snappy, value: self.viewModel.companyStats)
        
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "Company Stats",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            if let stats = self.viewModel.companyStats {
                
                Group {
                    
                    intervalSegmentedControl()
                    totalsSection(companyStats: stats)
                    
                    growthSection(companyStats: stats)
                    averagesSection(companyStats: stats)
                    infrastructureSection(companyStats: stats)
                    downtrendSection(companyStats: stats)
                    
                    groupedActivitiesSection(companyStats: stats)
                    groupedCategories(companyStats: stats)
                    groupedSubCategories(companyStats: stats)
                    groupedStates(companyStats: stats)
                    
                    featureRequestSection(companyStats: stats)
                    
                }
                .compositingGroup()
                .geometryGroup()
                .frameInfinity()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
            }
            
        }
        .frameInfinity()
        
    }
    
    @ViewBuilder
    private func intervalSegmentedControl() -> some View {
        
        CommonSegmentedControl(
            selectedOption: self.$viewModel.selectedInterval,
            options: CompanyStatInterval.allCases
        )
        
    }
    
    @ViewBuilder
    private func totalsSection(companyStats: CompanyStats) -> some View {
        
        AppCardView {
        
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                SectionView(
                    leadingTitle: "Totals",
                    showDivider: true
                )
                
                titleValueLabel(
                    title: "Users",
                    value: companyStats.totals.totalUsers,
                    image: ActivityCategory.employee.icon,
                    color: GPColor.green
                )
                
                titleValueLabel(
                    title: "Subscriptions",
                    value: companyStats.totals.totalSubscriptions,
                    image: .systemImage("dollarsign.circle.fill"),
                    color: ActivityCategory.note.color
                )
                
                titleValueLabel(
                    title: "Businesses",
                    value: companyStats.totals.totalSubscriptions,
                    image: ActivityCategory.business.icon,
                    color: ActivityCategory.business.color
                )
                
                titleValueLabel(
                    title: "Locations",
                    value: companyStats.totals.totalLocations,
                    image: ActivityCategory.location.icon,
                    color: ActivityCategory.location.color
                )
                
                titleValueLabel(
                    title: "Employees",
                    value: companyStats.totals.totalEmployees,
                    image: ActivityCategory.employee.icon,
                    color: ActivityCategory.employee.color
                )
                
                titleValueLabel(
                    title: "Media",
                    value: companyStats.totals.totalMedia,
                    image: ActivityCategory.media.icon,
                    color: ActivityCategory.media.color
                )
                
                titleValueLabel(
                    title: "Media Favorites",
                    value: companyStats.totals.totalMediaFavorites,
                    image: .systemImage("star.fill"),
                    color: .yellow
                )
                
                titleValueLabel(
                    title: "Clients",
                    value: companyStats.totals.totalClients,
                    image: ActivityCategory.client.icon,
                    color: ActivityCategory.client.color
                )
                
                titleValueLabel(
                    title: "Feature Requests",
                    value: companyStats.totals.totalFeatureRequests,
                    image: .systemImage("lightbulb.fill"),
                    color: .teal
                )
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .compositingGroup()
        .geometryGroup()
        
    }
    
    @ViewBuilder
    private func averagesSection(companyStats: CompanyStats) -> some View {
        
        AppCardView {
        
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                SectionView(
                    leadingTitle: "Averages",
                    showDivider: true
                )
                
                titleValueLabel(
                    title: "Average Clients Per Business",
                    value: companyStats.averages.avgClientsPerBusiness.formatted(.number.precision(.fractionLength(1)))
                )
                
                titleValueLabel(
                    title: "Average Locations Per Business",
                    value: companyStats.averages.avgLocationsPerBusiness.formatted(.number.precision(.fractionLength(1)))
                )
                
                titleValueLabel(
                    title: "Average Media Per Client",
                    value: companyStats.averages.avgMediaPerClient.formatted(.number.precision(.fractionLength(1)))
                )
                
                titleValueLabel(
                    title: "Average Favorites Per Location",
                    value: companyStats.averages.avgMediaFavoritesPerLocation.formatted(.number.precision(.fractionLength(1)))
                )
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .compositingGroup()
        .geometryGroup()
        
    }
    
    @ViewBuilder
    private func featureRequestSection(companyStats: CompanyStats) -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                SectionView(
                    leadingTitle: "Feature Requests",
                    showDivider: true
                )
                
                ForEach(companyStats.featureRequests.featureRequests, id: \.id) { request in
                    featureRequest(request)
                }
                
            }
            
        }
        .compositingGroup()
        .geometryGroup()
        
    }
    
    private func groupedActivitiesSection(companyStats: CompanyStats) -> some View {
        
        var dict: [String: Int] = [:]
        
        companyStats
            .groupedTotals
            .groupedActivities
            .sorted { $0.count > $1.count }
            .forEach {
                
                dict[$0.activityType] = ($0.count)
                
            }
        
        return groupedSection(
            title: "Grouped Activities",
            data: dict
        )
        
    }
    
    private func groupedCategories(companyStats: CompanyStats) -> some View {
        
        var dict: [String: Int] = [:]
        
        companyStats
            .groupedTotals
            .groupedCategories
            .sorted { $0.category < $1.category }
            .forEach {
                
                dict[$0.category] = ($0.count)
                
            }
        
        return groupedSection(
            title: "Grouped Categories",
            data: dict
        )
        
    }
    
    private func groupedSubCategories(companyStats: CompanyStats) -> some View {
        
        var dict: [String: Int] = [:]
        
        companyStats
            .groupedTotals
            .groupedSubcategories
            .sorted { $0.subcategory < $1.subcategory }
            .forEach {
                
                dict[$0.subcategory] = ($0.count)
                
            }
        
        return groupedSection(
            title: "Grouped Subcategories",
            data: dict
        )
        
    }
    
    private func groupedStates(companyStats: CompanyStats) -> some View {
        
        var dict: [String: Int] = [:]
        
        companyStats
            .groupedTotals
            .groupedLocationStates
            .sorted { $0.state < $1.state }
            .forEach {
                
                dict[$0.state] = ($0.count)
                
            }
        
        return groupedSection(
            title: "Grouped States",
            data: dict
        )
        
    }
    
    @ViewBuilder
    private func groupedSection(title: String,
                                data: [String: Int]) -> some View {
        
        let sortedKeys = Array(data.keys).sorted()
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                SectionView(
                    leadingTitle: title,
                    showDivider: true
                )
                
                ForEach(sortedKeys, id: \.id) { key in

                    let value = data[key]
                    
                    titleValueLabel(
                        title: key.uppercased(),
                        value: value ?? 0
                    )
                    
                }
                
            }
            
        }
        .compositingGroup()
        .geometryGroup()
        
    }
    
    @ViewBuilder
    private func infrastructureSection(companyStats: CompanyStats) -> some View {

        let infrastructure = companyStats.infrastructure
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                SectionView(
                    leadingTitle: "Infrastructure Summary",
                    showDivider: true
                )
                
                titleValueLabel(
                    title: "Active Subscriptions",
                    value: infrastructure.activeSubscriptions
                )
                
                titleValueLabel(
                    title: "Businesses Without Subscriptions",
                    value: infrastructure.businessesWithoutSubscriptions
                )
                
                titleValueLabel(
                    title: "Businesses Without Locations",
                    value: infrastructure.businessesWithNoLocations
                )
                
                titleValueLabel(
                    title: "Employees Without Locations",
                    value: infrastructure.employeesWithoutLocations
                )
                
                titleValueLabel(
                    title: "Unlinked Media",
                    value: infrastructure.unlinkedMedia
                )
                
            }
            
        }
        .compositingGroup()
        .geometryGroup()
        
    }
    
    @ViewBuilder
    private func growthSection(companyStats: CompanyStats) -> some View {
        
        let growth = companyStats.growth
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                SectionView(
                    leadingTitle: "Growth",
                    showDivider: true
                )
                
                growthLabel(
                    title: "Users",
                    total: growth.users.added,
                    percentageChange: growth.users.pctOfTotal ?? 0
                )
                
                growthLabel(
                    title: "Businesses",
                    total: growth.businesses.added,
                    percentageChange: growth.businesses.pctOfTotal ?? 0
                )
                
                growthLabel(
                    title: "Subscriptions",
                    total: growth.subscriptions.added,
                    percentageChange: growth.subscriptions.pctOfTotal ?? 0
                )
                
                growthLabel(
                    title: "Clients",
                    total: growth.clients.added,
                    percentageChange: growth.clients.pctOfTotal ?? 0
                )
                
                growthLabel(
                    title: "Media",
                    total: growth.media.added,
                    percentageChange: growth.media.pctOfTotal ?? 0
                )
                
            }
            
        }
        .compositingGroup()
        .geometryGroup()
        
    }
    
    @ViewBuilder
    private func titleValueLabel(title: String,
                                 value: Int,
                                 image: ImageSource? = nil,
                                 color: Color = GPColor.iconGreen) -> some View {
        
        HStack {
            
            if let image {
                
                image
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(color)
                    .contentShape(.rect)
                    .clipShape(.rect)
                
            }
            
            AttributedText {
                
                Text("\(title): ")
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .font(Style.shared.font(.BODY_3))
                
                Text("\(value.formatted(.number))")
                    .font(Style.shared.font(.HEADER_1))
                    .foregroundStyle(color)
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func growthLabel(title: String,
                             total: Int,
                             percentageChange: Double) -> some View {
        
        let chevron = percentageChange > 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill"
        let chevronTintColor = percentageChange > 0 ? GPColor.iconGreen : GPColor.iconRed
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            Text("\(title): ")
                .foregroundStyle(Style.shared.textColor(.title).source())
                .font(Style.shared.font(.BODY_3))
            
            Text("\(total.formatted(.number))")
                .font(Style.shared.font(.HEADER_1))
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            HStack(spacing: Style.shared.spacing(.extraSmall)) {
                
                Image(systemName: chevron)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 8, height: 8)
                    .foregroundStyle(chevronTintColor)
                    .contentShape(.rect)
                    .clipShape(.rect)
                
                Text(percentageChange, format: .percent.precision(.fractionLength(2)))
                    .font(Style.shared.font(.HEADER_1))
                    .foregroundStyle(chevronTintColor)
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func titleValueLabel(title: String,
                                 value: String,
                                 image: ImageSource? = nil,
                                 color: Color = GPColor.iconGreen) -> some View {
        
        HStack {
            
            if let image {
                
                image
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(color)
                
            }
            
            AttributedText {
                
                Text("\(title): ")
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .font(Style.shared.font(.BODY_3))
                
                Text(value)
                    .font(Style.shared.font(.HEADER_1))
                    .foregroundStyle(color)
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func featureRequest(_ request: CompanyFeatureRequest) -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {

                Text(request.message)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .font(Style.shared.font(.TITLE_5))
                
                Text(request.createdAt ?? .now, format: .dateTime)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .font(Style.shared.font(.BODY_2))
                
            }
            
        }
        .compositingGroup()
        .geometryGroup()
        
    }
    
    @ViewBuilder
    private func downtrendSection(companyStats: CompanyStats) -> some View {

        let downtrend = companyStats.downtrend

        AppCardView {

            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {

                SectionView(
                    leadingTitle: "Downtrend",
                    showDivider: true
                )

                titleValueLabel(
                    title: "Subscribed Businesses",
                    value: downtrend.subscribedBusinessCount,
                    image: ActivityCategory.business.icon,
                    color: ActivityCategory.business.color
                )

                titleValueLabel(
                    title: "Cancelled Subscriptions",
                    value: downtrend.cancelledSubscriptionsCount,
                    image: .systemImage("xmark.circle.fill"),
                    color: GPColor.iconRed
                )

                titleValueLabel(
                    title: "Downgrades Happening Next Billing Cycle",
                    value: downtrend.tierUpdateScheduleCount,
                    image: .systemImage("calendar.badge.clock"),
                    color: ActivityCategory.note.color
                )

                titleValueLabel(
                    title: "Downgrades In Schedule",
                    value: downtrend.downgradesInScheduleCount,
                    image: .systemImage("arrow.down.circle.fill"),
                    color: .yellow
                )

                titleValueLabel(
                    title: "Deleted Locations w/ Media (Count)",
                    value: downtrend.deletedLocationsWithMediaCount,
                    image: ActivityCategory.location.icon,
                    color: ActivityCategory.location.color
                )

                titleValueLabel(
                    title: "Deleted Locations w/ Media (Total Media)",
                    value: downtrend.deletedLocationsWithMediaTotalMedia,
                    image: ActivityCategory.media.icon,
                    color: ActivityCategory.media.color
                )

                if !downtrend.deletedLocationsWithMedia.isEmpty {

                    SectionView(
                        leadingTitle: "Deleted Locations With Media",
                        showDivider: true
                    )

                    ForEach(downtrend.deletedLocationsWithMedia, id: \.locationId) { item in
                        deletedLocationWithMediaRow(item)
                    }

                }

                if !downtrend.tierUpdateSchedule.isEmpty {

                    SectionView(
                        leadingTitle: "Downgrades Coming",
                        showDivider: true
                    )

                    ForEach(downtrend.tierUpdateSchedule, id: \.subscriptionId) { item in
                        subscriptionScheduleRow(item)
                    }

                }

            }

        }
        .compositingGroup()
        .geometryGroup()

    }
    
    @ViewBuilder
    private func deletedLocationWithMediaRow(_ item: CompanyDeletedLocationWithMedia) -> some View {

        AppCardView {

            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {

                HStack(spacing: Style.shared.spacing(.small)) {

                    ActivityCategory.location.icon
                        .view()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(ActivityCategory.location.color)

                    Text(item.locationName)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .font(Style.shared.font(.TITLE_5))

                }

                titleValueLabel(
                    title: "Business",
                    value: item.businessName
                )

                titleValueLabel(
                    title: "Media Count",
                    value: item.mediaCount,
                    image: ActivityCategory.media.icon,
                    color: ActivityCategory.media.color
                )
                .padding(.top, .small2)

                if let deletedAt = item.deletedAt {

                    titleValueLabel(
                        title: "Deleted At",
                        value: deletedAt
                    )

                }

            }

        }
        .compositingGroup()
        .geometryGroup()

    }

    @ViewBuilder
    private func subscriptionScheduleRow(_ item: CompanySubscriptionData) -> some View {

        AppCardView {

            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {

                HStack(spacing: Style.shared.spacing(.small)) {

                    ImageSource.systemImage("storefront.fill")
                        .view()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(ActivityCategory.business.color)

                    Text(item.businessName)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .font(Style.shared.font(.TITLE_5))

                }

                titleValueLabel(
                    title: "Owner",
                    value: item.ownerName,
                    color: .black
                )

                titleValueLabel(
                    title: "Owner Email",
                    value: item.ownerEmail,
                    color: .black
                )

                titleValueLabel(
                    title: "Months Subscribed",
                    value: item.monthsSubscribed,
                    color: .black
                )

                titleValueLabel(
                    title: "Created At",
                    value: item.createdAt,
                    color: .black
                )

            }

        }
        .compositingGroup()
        .geometryGroup()

    }
    
}

#Preview {
    
    DevCompanyStatsScreen(
        viewModel: mockResolve(DevCompanyStatsViewModel.self)
    )
    .withMockServices()
    
}
