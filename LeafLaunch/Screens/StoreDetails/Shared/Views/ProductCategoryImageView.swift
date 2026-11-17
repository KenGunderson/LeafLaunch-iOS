import SwiftUI
import UIKit

struct ProductCategoryImageView: View {

    let url: URL

    var body: some View {

        Group {

            if self.url.isFileURL {

                if let image = UIImage(contentsOfFile: self.url.path) {

                    RNImageSource.uiImage(image)
                        .view()
                        .scaledToFit()

                } else {

                    placeholder()

                }

            } else {

                RNImageSource.remote(
                    url: self.url,
                    contentMode: .fit,
                    placeholder: AnyView(placeholder())
                )
                .view()

            }

        }

    }

    @ContentBuilder
    private func placeholder() -> some View {

        RNImageSource.systemImage("leaf")
            .view()
            .scaledToFit()
            .runeTextColor(.body)

    }

}
