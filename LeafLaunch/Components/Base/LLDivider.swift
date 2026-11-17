import SwiftUI

struct LLDivider: View {

    @Environment(\.style) private var style

    var body: some View {

        Capsule()
            .runeFill(.background(.quaternary))
            .frame(height: 1.25)
            .frame(maxWidth: .infinity)

    }

}

#Preview {

    LLDivider()
        .runePadding(LLSpacing.pageInset)
        .withMockPreviews()

}
