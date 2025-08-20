//
//  Section.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import SwiftUI

struct SectionView: View {
    
    let title: String
    let titleFont: Theme.FontKey
    let showDivider: Bool
    let viewAllTitle: String
    let viewAllAction: (() -> Void)?
    
    init(title: String,
         titleFont: Theme.FontKey = .TITLE_6,
         showDivider: Bool = false,
         viewAllTitle: String = "View All",
         viewAllAction: (() -> Void)? = nil) {
        
        self.title = title
        self.titleFont = titleFont
        self.showDivider = showDivider
        self.viewAllTitle = viewAllTitle
        self.viewAllAction = viewAllAction
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                
                Text(self.title)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(Rune.Style.shared.textColor(.title).source())
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                
                if let viewAllAction {
                    
                    HStack {
                        
                        Text(self.viewAllTitle)
                            .appFont(with: .BODY_2)
                        
                        Image(systemName: "arrow.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                        
                    }
                    .foregroundStyle(Rune.Style.shared.textColor(.body).source())
                    .asButton {
                        viewAllAction()
                    }
                    
                }
                
            }
            
            if self.showDivider {
                
                Divider()
                    .background(Style.shared.background(.border).source())
                
            }
            
        }
        
    }
    
}
