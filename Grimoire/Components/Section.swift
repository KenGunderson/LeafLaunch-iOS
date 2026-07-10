//
//  Section.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import SwiftUI

struct SectionView: View {
    
    let leadingTitle: String
    let leadingTitleFont: Theme.FontKey
    let leadingForegroundColor: ColorSource
    let showDivider: Bool
    let trailingTitle: String
    let trailingAction: (() -> Void)?
    
    init(leadingTitle: String,
         leadingTitleFont: Theme.FontKey = .TITLE_6,
         leadingForegroundColor: ColorSource = .text(.title),
         showDivider: Bool = false,
         trailingTitle: String = "View All",
         trailingAction: (() -> Void)? = nil) {
        
        self.leadingTitle = leadingTitle
        self.leadingTitleFont = leadingTitleFont
        self.leadingForegroundColor = leadingForegroundColor
        self.showDivider = showDivider
        self.trailingTitle = trailingTitle
        self.trailingAction = trailingAction
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
            
            HStack {
                
                Text(self.leadingTitle)
                    .appFont(with: self.leadingTitleFont)
                    .foregroundStyle(self.leadingForegroundColor)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                
                if let trailingAction {
                    
                    HStack {
                        
                        Text(self.trailingTitle)
                            .appFont(with: .BODY_2)
                        
                        Image(systemName: "arrow.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                        
                    }
                    .foregroundStyle(.text(.body))
                    .asButton {
                        trailingAction()
                    }
                    
                }
                
            }
            
            if self.showDivider {
                
                Capsule()
                    .fill(.background(.quaternary))
                    .frame(height: 1.5)
                
            }
            
        }
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        VStack {
            
            SectionView(leadingTitle: "Section 1", showDivider: true) {}
            SectionView(leadingTitle: "Section 2", showDivider: true, trailingTitle: "Show me more") {}
            SectionView(leadingTitle: "Section 3", showDivider: true) {}
            SectionView(leadingTitle: "Section 4", leadingTitleFont: .HEADER_4) {}
            
        }
        .padding(.horizontal, .large)
        
    }
    
}
