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
                
                let hasAvailableVariant = self.product.variants.contains { $0.availability == .available }
                
                Text(
                    self.product.status == .published && hasAvailableVariant
                    ? String(localized: "Price Unavailable")
                    : String(localized: "Sold Out")
                )
                .appFont(with: .TITLE_2)
                .foregroundStyle(self.style.textColor(.body))
                
            }
            
        }
        .appFont(with: .TITLE_5)
        
    }
    
}

#Preview {
    
    if let product = MockCustomerModels.products.first {
        
        ProductPriceView(product: product)
            .padding(.medium)
            .withMockPreviews()
        
    }
    
}
