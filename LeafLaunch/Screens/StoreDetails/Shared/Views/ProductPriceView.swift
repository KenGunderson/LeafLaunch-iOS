import SwiftUI

struct ProductPriceView: View {
    
    @Environment(\.style) private var style
    
    let product: Product
    
    private var hasPriceRange: Bool {
        
        let prices = self.product.variants
            .filter { $0.availability == .available }
            .compactMap(\.displayPrice)
        
        return Set(prices).count > 1
        
    }
    
    var body: some View {
        
        Group {
            
            if let price = self.product.minimumPrice {
                
                let formattedPrice = price.formatted(.currency(code: self.product.currencyCode))
                
                Text(self.hasPriceRange ? String(localized: "From \(formattedPrice)") : formattedPrice)
                    .foregroundStyle(self.style.textColor(.title))

            } else {
                
                Text(
                    self.product.isAvailable
                    ? String(localized: "Price Unavailable")
                    : String(localized: "Sold out")
                )
                .appFont(with: .BODY_3)
                .foregroundStyle(self.style.textColor(.body))
                
            }
            
        }
        .appFont(with: .TITLE_5)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        
    }
    
}

#Preview {
    
    if let product = MockCustomerModels.products.first {
        
        ProductPriceView(product: product)
            .padding(.medium)
            .withMockPreviews()
        
    }
    
}
