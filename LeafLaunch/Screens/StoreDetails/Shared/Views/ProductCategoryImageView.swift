import SwiftUI
import UIKit

struct ProductCategoryImageView: View {

    let url: URL

    var body: some View {

        Group {

            if self.url.isFileURL {

                if let image = UIImage(contentsOfFile: self.url.path) {

                    ImageSource.uiImage(image)
                        .view()
                        .scaledToFit()

                } else {

                    placeholder()

                }

            } else {

                ImageSource.remote(
                    url: self.url,
                    contentMode: .fit,
                    placeholder: AnyView(placeholder())
                )
                .view()

            }

        }

    }

    @ViewBuilder
    private func placeholder() -> some View {

        ImageSource.systemImage("leaf")
            .view()
            .scaledToFit()
            .foregroundStyle(.text(.body))

    }

}
