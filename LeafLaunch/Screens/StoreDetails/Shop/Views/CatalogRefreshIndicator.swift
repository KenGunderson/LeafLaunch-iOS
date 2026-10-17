import SwiftUI

struct CatalogRefreshIndicator: View {

    @Environment(\.style) private var style

    let context: PullToRefreshIndicatorContext
    let hasFailed: Bool
    let didRefresh: Bool

    private var progress: CGFloat {
        self.context.isFinishing ? 1 : min(max(self.context.progress, 0), 1)
    }

    private var statusColor: ColorSource {

        guard self.context.isFinishing else {
            return .foreground(.primary)
        }

        if self.hasFailed {
            return .palette(.error)
        }

        return self.didRefresh ? .palette(.success) : .foreground(.primary)

    }

    private var symbolName: String {

        if self.context.isFinishing {

            if self.hasFailed {
                return "exclamationmark"
            }

            return self.didRefresh ? "checkmark" : "leaf.fill"

        }

        return self.context.isRefreshing ? "leaf.fill" : "arrow.down"

    }

    private var title: String {

        switch self.context.phase {
        case .idle, .pulling:
            return String(localized: "Pull To Refresh")

        case .armed:
            return String(localized: "Release To Refresh")

        case .refreshing:
            return String(localized: "Refreshing Menu")

        case .finishing:

            if self.hasFailed {
                return String(localized: "Couldn't Refresh")
            }

            return self.didRefresh
                ? String(localized: "Menu Updated")
                : String(localized: "Menu")
        }

    }

    private var message: String {

        switch self.context.phase {
        case .idle, .pulling, .armed:
            return String(localized: "Get the latest products")

        case .refreshing:
            return String(localized: "Checking the latest products…")

        case .finishing:

            if self.hasFailed {
                return String(localized: "Pull again to retry")
            }

            return self.didRefresh
                ? String(localized: "You're up to date")
                : String(localized: "Ready to browse")
        }

    }

    var body: some View {

        HStack(spacing: self.style.spacing(.small2)) {

            progressIndicator()
            statusCopy()

        }
        .centerHorizontally()
        .padding(.horizontal, .medium)
        .padding(.vertical, .medium)
        .animation(.spring(response: 0.32, dampingFraction: 0.8), value: self.context.isArmed)
        .animation(.smooth(duration: 0.24), value: self.context.isRefreshing)
        .animation(.smooth(duration: 0.24), value: self.context.isFinishing)

    }

    @ViewBuilder
    private func progressIndicator() -> some View {

        ZStack {

            if self.context.isRefreshing {

                AppLoadingView(style: .circleRunner(
                    color: self.statusColor,
                    trimSubtractionScale: 0.72,
                    size: self.style.spacing(.large2),
                    speed: 0.24
                ))
                .transition(.opacity)

            } else {

                ProgressCircle(
                    progress: self.progress,
                    inactiveColor: .background(.quaternary),
                    activeColor: self.statusColor,
                    lineWidth: 2.5
                )
                .transition(.opacity)

            }

            ImageSource.systemImage(self.symbolName)
                .view(shouldResize: false)
                .appFont(with: .TITLE_1)
                .foregroundStyle(self.statusColor)
                .rotationEffect(.degrees(self.context.isArmed ? 180 : 0))
                .contentTransition(.symbolEffect(.replace))

        }
        .frame(
            width: self.style.spacing(.large2),
            height: self.style.spacing(.large2)
        )
        .scaleEffect(self.context.isArmed ? 1.08 : 0.9 + (self.progress * 0.1))

    }

    @ViewBuilder
    private func statusCopy() -> some View {

        VStack(spacing: self.style.spacing(.extraSmall)) {

            Text(self.title)
                .appFont(with: .TITLE_1)
                .foregroundStyle(.text(.title))

            Text(self.message)
                .appFont(with: .NOTE_1)
                .foregroundStyle(.text(.body))

        }
        .multilineTextAlignment(.center)
        .contentTransition(.opacity)
        .fixedSize(horizontal: false, vertical: true)

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
