import SwiftUI

struct LLRefreshIndicator: View {

    @Environment(\.style) private var style

    let context: RNPullToRefreshIndicatorContext
    var hasFailed = false
    var didRefresh = false
    var refreshingTitle = String(localized: "Refreshing…")
    var updatedTitle = String(localized: "Updated")
    var completedTitle = String(localized: "Refresh Complete")

    private var progress: CGFloat {
        self.context.isFinishing ? 1 : self.clampedProgress
    }

    private var clampedProgress: CGFloat {

        let nonnegativeProgress = max(self.context.progress, 0)
        return min(nonnegativeProgress, 1)

    }

    private var statusColor: RNColorSource {

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
        case .idle,
                .pulling:

            return String(localized: "Pull To Refresh")

        case .armed:
            return String(localized: "Release To Refresh")
        case .refreshing:
            return self.refreshingTitle

        case .finishing:

            if self.hasFailed {
                return String(localized: "Couldn't Refresh")
            }

            return self.didRefresh
                ? self.updatedTitle
                : self.completedTitle
        }

    }

    private var statusTitles: [String] {

        [
            String(localized: "Pull To Refresh"),
            String(localized: "Release To Refresh"),
            self.refreshingTitle,
            String(localized: "Couldn't Refresh"),
            self.updatedTitle,
            self.completedTitle
        ]

    }

    var body: some View {

        HStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            progressIndicator()
            statusLabel()

        }
        .runePadding(.horizontal, LLSpacing.pageInset)
        .runePadding(.vertical, LLSpacing.listRow)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .center)
        .animation(
            .spring(
                response: 0.32,
                dampingFraction: 0.8
            ),
            value: self.context.isArmed
        )
        .animation(
            .smooth(duration: 0.24),
            value: self.context.isRefreshing
        )
        .animation(
            .smooth(duration: 0.24),
            value: self.context.isFinishing
        )

    }

    @ContentBuilder
    private func statusLabel() -> some View {

        ZStack(alignment: .leading) {

            ForEach(self.statusTitles.indices, id: \.self) { index in

                Text(self.statusTitles[index])
                    .hidden()
                    .accessibilityHidden(true)

            }

            Text(self.title)
                .contentTransition(.numericText())

        }
        .runeFont(with: .TITLE_1)
        .runeTextColor(.body)
        .fixedSize(
            horizontal: false,
            vertical: true
        )

    }

    @ContentBuilder
    private func progressIndicator() -> some View {

        ZStack {

            if self.context.isRefreshing {

                RNLoadingView(style: .circleRunner(
                    color: self.statusColor,
                    trimSubtractionScale: 0.72,
                    size: 24
                ))
                .transition(.opacity)

            } else {

                RNProgressCircle(
                    progress: self.progress,
                    inactiveColor: .background(.quaternary),
                    activeColor: self.statusColor,
                    lineWidth: 2.5
                )
                .transition(.opacity)

                RNImageSource.systemImage(self.symbolName)
                    .view(shouldResize: false)
                    .runeFont(with: .TITLE_1)
                    .foregroundStyle(self.statusColor)
                    .rotationEffect(.degrees(self.context.isArmed ? 180 : 0))
                    .contentTransition(.symbolEffect(.replace))

            }

        }
        .frame(
            width: 24,
            height: 24
        )
        .scaleEffect(self.context.isArmed ? 1.08 : 0.9 + (self.progress * 0.1))

    }

}

