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
            return .palette(.link)
        }

        if self.hasFailed {
            return .palette(.error)
        }

        return self.didRefresh ? .palette(.success) : .palette(.link)

    }

    private var symbolName: String {

        if self.context.isFinishing {

            if self.hasFailed {
                return "exclamationmark"
            }

            return self.didRefresh ? "checkmark" : "arrow.clockwise"

        }

        return "arrow.down"

    }

    private var title: String {

        switch self.context.phase {
        case .idle, .pulling:
            return String(localized: "Pull To Refresh")

        case .armed:
            return String(localized: "Release To Refresh")

        case .refreshing:
            return String(localized: "Refreshing Products…")

        case .finishing:

            if self.hasFailed {
                return String(localized: "Couldn't Refresh")
            }

            return self.didRefresh
                ? String(localized: "Products Updated")
                : String(localized: "Menu")
        }

    }

    var body: some View {

        HStack(spacing: self.style.spacing(.small2)) {

            progressIndicator()
            Text(self.title)
                .appFont(with: .TITLE_1)
                .foregroundStyle(.text(.body))
                .contentTransition(.opacity)
                .frame(maxWidth: .infinity, alignment: .leading)

        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .medium)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
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
                    size: self.style.spacing(.large)
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

                ImageSource.systemImage(self.symbolName)
                    .view(shouldResize: false)
                    .appFont(with: .TITLE_1)
                    .foregroundStyle(self.statusColor)
                    .rotationEffect(.degrees(self.context.isArmed ? 180 : 0))
                    .contentTransition(.symbolEffect(.replace))

            }

        }
        .frame(
            width: self.style.spacing(.large),
            height: self.style.spacing(.large)
        )
        .scaleEffect(self.context.isArmed ? 1.08 : 0.9 + (self.progress * 0.1))

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
