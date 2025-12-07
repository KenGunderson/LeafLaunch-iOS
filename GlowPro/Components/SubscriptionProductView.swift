//
//  SubscriptionProductView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/15/25.
//

import SwiftUI

struct SubscriptionProductView: View {
    
    let product: StripeSubscriptionProduct
    let interval: SubscriptionPaywallViewModel.Interval
    let isSelected: Bool
    
    var backgroundColor: ColorSource {
        
        return self.isSelected
        ? .color(Style.shared.accent.asColor!.opacity(0.15))
        : Style.shared.background(.secondary)
        
    }
    
    var borderColor: ColorSource {
        
        return self.isSelected
        ? Style.shared.accent
        : .color(.clear)
        
    }
    
    var body: some View {
            
        AppCardView(backgroundStyle: self.backgroundColor) {
            
            VStack(
                alignment : .leading,
                spacing : Style.shared.spacing(.small)
            ) {
                
                checkmarkView()
                headerView()
                descriptionView()

                benefitsView()
                    .padding(.top, .small)
                
            }
            
        }
        .background(.backgroundTappable)
        .appBorder(
            cornerRadius: .small2,
            color: borderColor,
            lineWidth: 3.5
        )
        
    }
    
    @ViewBuilder
    private func checkmarkView() -> some View {
        
        var toggleForegroundColor: ColorSource {
            
            return self.isSelected
                ? Style.shared.accent
                : Style.shared.background(.quaternary)
            
        }
        
        Image(systemName: self.isSelected ? "checkmark.circle.fill" : "circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 28)
            .foregroundStyle(toggleForegroundColor.source())
        
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        let price = self.product
            .prices
            .filter({ $0.interval == self.interval.stripeName && $0.amount > 0 })
            .first
        
        let normalizedPrice = (price?.amount ?? 0) / 100
     
        HStack {
            
            Text(self.product.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            HStack(spacing: Style.shared.spacing(.custom(2))) {
                
                Text(normalizedPrice, format: .currency(code: "USD"))
                    .contentTransition(.numericText(value: Double(normalizedPrice)))
                    .foregroundStyle(Style.shared.accent.source())
                
                Text("/ \(self.interval.stripeName.capitalized)")
                    .contentTransition(.numericText())
                    .foregroundStyle(Style.shared.accent.source())
                
            }
//            .padding(.horizontal, 12)
//            .padding(.vertical, 4)
//            .background(Style.shared.accent.source(opacity: 0.12))
//            .clipShape(.rect(cornerRadius: 8))
            
        }
        .appFont(with: .TITLE_6)
        
    }
    
    @ViewBuilder
    private func descriptionView() -> some View {
        
        if let description = self.product.description {
            
            Text(description)
                .appFont(with: .BODY_2)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        
    }
    
    @ViewBuilder
    private func benefitsView() -> some View {
        
        let data = self.product.metadata ?? .init()
        
        let totalNumberOfLocations = data.totalNumberOfLocations ?? 0
        let totalNumberOfEmployees = data.totalNumberOfEmployees ?? 0
        let totalNumberOfMedia = data.totalNumberOfMedia ?? 0
        
        var stringNumberOfLocations: String {
            return totalNumberOfLocations == -1 ? "Unlimited" : "\(totalNumberOfLocations)"
        }
        
        var stringNumberOfEmployees: String {
            return totalNumberOfEmployees == -1 ? "Unlimited" : "\(totalNumberOfEmployees)"
        }
        
        var stringNumberOfMedia: String {
            return totalNumberOfMedia == -1 ? "Unlimited" : "\(totalNumberOfMedia)"
        }
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("Included In This Plan:")
                .foregroundStyle(Style.shared.textColor(.body).source())
                .appFont(with: .TITLE_4)
            
            // Location
            
            benefitView(
                icon: .systemImage("pin.fill"),
                title: "\(stringNumberOfLocations) Location\(pluralize(totalNumberOfLocations))",
                color: .color(ActivityCategory.location.color)
            )
            
            // Employee
            
            benefitView(
                icon: .image(.iconPerson, renderingMode: .template),
                title: "\(stringNumberOfEmployees) Additional Staff",
                color: .color(ActivityCategory.employee.color)
            )
            
            // Media
            
            benefitView(
                icon: .systemImage("camera.fill"),
                title: "\(stringNumberOfMedia) Media Upload\(pluralize(totalNumberOfMedia))",
                color: .color(ActivityCategory.media.color)
            )
            
            // Notes
            
            benefitView(
                icon: .image(.iconNoteOutline, renderingMode: .template),
                title: "Unlimited Notes & Forms",
                color: .color(ActivityCategory.note.color)
            )
            
        }
        
    }
    
    private func benefitView(icon: ImageSource,
                             title: String,
                             color: ColorSource) -> some View {
        
        HStack(spacing: Style.shared.spacing(.custom(6))) {
            
            icon
                .view()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .padding(.small)
                .foregroundStyle(color.source())
                .background(color.source(opacity: 0.15), in: .circle)
            
            Text(title)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .appFont(with: .TITLE_3)
                .lineLimit(nil)
            
        }
        
    }
    
    private func pluralize(_ count: Int) -> String {
        return (count == 1) ? "" : "s"
    }
    
}

#Preview {
        
    var product: StripeSubscriptionProduct = StripeSubscriptionProduct(
        id: "1",
        name: "Team Plan",
        description: "This is the first tier. It is awesome! You're going to love it!",
        defaultPriceId: nil,
        prices: [
            .init(id: "1", amount: 1000, interval: "month"),
            .init(id: "1", amount: 1000, interval: "year"),
        ],
        active: true,
        metadata: .init()
    )
    
    AppBaseView {
        
        VStack {
            
            SubscriptionProductView(
                product: product,
                interval: .yearly,
                isSelected: false
            )
            .padding(.horizontal, 24)
            
            SubscriptionProductView(
                product: product,
                interval: .yearly,
                isSelected: true
            )
            .padding(.horizontal, 24)
            
        }
        
    }
    
}
