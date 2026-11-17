import SwiftUI

struct CatalogRefreshIndicator: View {

    let context: RNPullToRefreshIndicatorContext
    let hasFailed: Bool
    let didRefresh: Bool

    var body: some View {

        LLRefreshIndicator(
            context: self.context,
            hasFailed: self.hasFailed,
            didRefresh: self.didRefresh,
            refreshingTitle: String(localized: "Refreshing Products…"),
            updatedTitle: String(localized: "Products Updated"),
            completedTitle: String(localized: "Menu")
        )

    }

}

#Preview {

    CatalogRefreshIndicator(
        context: .init(
            phase: .armed(progress: 1),
            progress: 1,
            offset: 96,
            isRefreshing: false
        ),
        hasFailed: false,
        didRefresh: false
    )
    .withMockPreviews()

}
