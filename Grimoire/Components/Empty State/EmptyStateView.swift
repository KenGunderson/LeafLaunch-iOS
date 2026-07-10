//
//  NoContentView.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/17/25.
//

import SwiftUI

struct EmptyStateView: View {
    
    let config: EmptyStateConfig
    
    var body: some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            self.config
                .image
                .view()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.text(.title))
                .frame(width: 100, height: 120)
            
            Text(self.config.title)
                .appFont(with: .HEADER_4)
                .foregroundStyle(.text(.title))
                .multilineTextAlignment(.center)
            
            if let message = self.config.message {
                
                Text(message)
                    .appFont(with: .BODY_3)
                    .foregroundStyle(.text(.body))
                    .multilineTextAlignment(.center)
                
            }
            
            if let actionTitle = self.config.actionTitle {
                
                CommonButton(title: actionTitle) {
                    self.config.action?()
                }
                .padding(.top, .small)
                
            }
            
        }
        .padding(.horizontal, .large)
        
    }
    
}

#Preview {
    
    @Previewable @State var showEmptyState: Bool = true
    
    AppBaseView {
        
        ScrollView {
            
            Group {
            
                if !showEmptyState {
                    
                    ForEach(0...50) { index in
                        
                        Text("\(index)")
                            .appFont(with: .TITLE_5)
                            .foregroundStyle(.text(.title))
                        
                    }
                    .border(.red)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .init(.blurReplace)
                    ))
                    
                }
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            
        }
        
    }
    .emptyStateOverlay(
        shouldShow: showEmptyState,
        config: .init(
            title: "No Clients Found",
            message: "Start building your client base by adding your first client",
            image: .systemImage("magnifyingglass"),
            actionTitle: "Add Your First Client",
            action: {
                print("Do Something")
            }
        ),
        transition: .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .init(.blurReplace)
        ),
        animation: .bouncy
    )
    .safeAreaInset(edge: .bottom) {
        
        CommonButton(title: "Show / Hide") {
            showEmptyState.toggle()
        }
        .padding(.horizontal, .large)
        
    }
    .animation(.bouncy, value: showEmptyState)
    
}
