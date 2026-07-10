//
//  BaseAppCardConfig.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/19/25.
//

import SwiftUI

struct BaseAppCardConfigView: View {
    
    let image: ImageSource
    let title: String
    let attributedText: AttributedText
    let tintColor: ColorSource
    let actionTitle: String
    let action: () -> Void
    
    init(image: ImageSource,
         title: String,
         attributedText: AttributedText,
         tintColor: ColorSource = .color(GPColor.green),
         actionTitle: String,
         action: @escaping () -> Void) {
        
        self.image = image
        self.title = title
        self.attributedText = attributedText
        self.tintColor = tintColor
        self.actionTitle = actionTitle
        self.action = action
        
    }
    
    var body: some View {
        
        VStack(spacing: Style.shared.spacing(.large)) {
         
            icon()
            titleMessage()
            actionButton()
            
        }
        
    }
    
    private func icon() -> some View {
        
        self.image
            .view()
            .aspectRatio(contentMode: .fit)
            .frame(height: 80)
            .foregroundStyle(self.tintColor)
        
    }
    
    private func titleMessage() -> some View {
        
        Group {
            
            Text(self.title)
                .appFont(with: .HEADER_3)
                .foregroundStyle(.text(.title))
            
            self.attributedText
                .multilineTextAlignment(.center)
                .padding(.top, -Style.shared.spacing(.small2))
                .padding(.horizontal, .medium)
            
        }
        
    }
    
    private func actionButton() -> some View {
        
        CommonButton(title: self.actionTitle) {
            self.action()
        }
        .padding(.horizontal, .medium)
        
    }
    
}

#Preview {
    
    let alertService = mockResolve(AlertServiceProtocol.self)
    
    AppBaseView(alignment: .bottom) {
        
        VStack {
            
            CommonButton(title: "Show Alert") {
                
                alertService.showAlert(
                    .init(.card(.invitationAlert(
                        name: "Sako Hovaguimian",
                        businessName: "Bronx Tales"
                    ) {
                        print("Testing")
                    }
                    )))
                
            }
            
            CommonButton(title: "Show Alert") {
                
                alertService.showAlert(.init(
                    .card(.init(viewBuilder: { dismissAction in
                        
                        BaseAppCardConfigView(
                            image: .systemImage("person.fill"),
                            title: "Test App Card Action",
                            attributedText: .init(content: { Text("This is the message of the app card. It is a long message that needs to be wrapped to multiple lines. It is a long message that needs to be wrapped to multiple lines. It is a long message that needs to be wrapped to multiple lines.") }),
                            actionTitle: "Complete"
                        ) {
                            dismissAction()
                        }
                        .asAnyView()
                        
                    },
                                cornerRadius: Style.shared.radius(.extraLarge),
                                backgroundCardInset: .init(top: 0, left: 24, bottom: 250, right: 24),
                                contentCardInset: .init(top: 40, left: 16, bottom: 40, right: 16),
                                cardBackgroundColor: .background(.secondary),
                                shouldDismissOnOutsideTouch: false,
                                shouldDismissOnDrag: true
                ))))
                
            }
            
        }
        .padding(.horizontal, .extraLarge)
        
    }
    .withMockServices()
    
}
