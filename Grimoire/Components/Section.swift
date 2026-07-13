//
//  Section.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import SwiftUI

struct SectionView<Trailing: View>: View {

    @Environment(\.style) private var style
    
    let leadingTitle: String
    let leadingTitleFont: Theme.FontKey
    let leadingForegroundColor: ColorSource
    let showDivider: Bool
    let dividerLineWidth: CGFloat
    let trailingTitle: String
    let trailingAction: (() -> Void)?
    let trailingView: Trailing?
    
    init(leadingTitle: String,
         leadingTitleFont: Theme.FontKey = .TITLE_6,
         leadingForegroundColor: ColorSource = .text(.title),
         showDivider: Bool = false,
         dividerLineWidth: CGFloat = 1.5,
         trailingTitle: String = "View All",
         trailingAction: (() -> Void)? = nil,
         @ViewBuilder trailingView: () -> Trailing) {
        
        self.leadingTitle = leadingTitle
        self.leadingTitleFont = leadingTitleFont
        self.leadingForegroundColor = leadingForegroundColor
        self.showDivider = showDivider
        self.dividerLineWidth = dividerLineWidth
        self.trailingTitle = trailingTitle
        self.trailingAction = trailingAction
        self.trailingView = trailingView()
        
    }
    
    private init(leadingTitle: String,
                 leadingTitleFont: Theme.FontKey,
                 leadingForegroundColor: ColorSource,
                 showDivider: Bool,
                 dividerLineWidth: CGFloat,
                 trailingTitle: String,
                 trailingAction: (() -> Void)?,
                 trailingView: Trailing?) {
        
        self.leadingTitle = leadingTitle
        self.leadingTitleFont = leadingTitleFont
        self.leadingForegroundColor = leadingForegroundColor
        self.showDivider = showDivider
        self.dividerLineWidth = dividerLineWidth
        self.trailingTitle = trailingTitle
        self.trailingAction = trailingAction
        self.trailingView = trailingView
        
    }
    
    var body: some View {
        
        VStack(
            alignment: .leading,
            spacing: self.style.spacing(.extraSmall)
        ) {
            
            HStack {
                
                Text(self.leadingTitle)
                    .appFont(with: self.leadingTitleFont)
                    .foregroundStyle(self.leadingForegroundColor)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                
                self.trailingContent
                
            }
            
            if self.showDivider {
                
                Capsule()
                    .fill(.background(.quaternary))
                    .frame(height: self.dividerLineWidth)
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private var trailingContent: some View {
        
        if let trailingView = self.trailingView {
            
            trailingView
            
        } else if let trailingAction = self.trailingAction {
            
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
    
}

extension SectionView where Trailing == EmptyView {
    
    init(leadingTitle: String,
         leadingTitleFont: Theme.FontKey = .TITLE_6,
         leadingForegroundColor: ColorSource = .text(.title),
         showDivider: Bool = false,
         dividerLineWidth: CGFloat = 1.5,
         trailingTitle: String = "View All",
         trailingAction: (() -> Void)? = nil) {
        
        self.init(
            leadingTitle: leadingTitle,
            leadingTitleFont: leadingTitleFont,
            leadingForegroundColor: leadingForegroundColor,
            showDivider: showDivider,
            dividerLineWidth: dividerLineWidth,
            trailingTitle: trailingTitle,
            trailingAction: trailingAction,
            trailingView: nil
        )
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        VStack {
            
            SectionView(
                leadingTitle: "Section 1",
                showDivider: true
            )
            
            SectionView(
                leadingTitle: "Section 2",
                showDivider: true,
                trailingTitle: "Show me more",
                trailingAction: {}
            )
            
            SectionView(
                leadingTitle: "Section 3",
                showDivider: true,
                dividerLineWidth: 2.5
            )
            
            SectionView(
                leadingTitle: "Section 4",
                leadingTitleFont: .HEADER_4,
                showDivider: true,
                dividerLineWidth: 6
            ) {
                
                HStack(spacing: 2) {
                    
                    Image(systemName: "sparkles")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                    
                    Text("Custom View")
                        .appFont(with: .BODY_2)
                    
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .appBorder(cornerRadius: .extraLarge, color: .palette(.link))
                .foregroundStyle(.palette(.link))
                
            }
            
        }
        .padding(.horizontal, .large)
        
    }
    
}
