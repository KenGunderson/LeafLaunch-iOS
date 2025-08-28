//
//  DeleteEmployeeCardView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/27/25.
//

import SwiftUI

@MainActor
extension AppCardConfig {
    
    static func deleteEmployeeAlert() -> AppCardConfig {
        
        return .init(
            viewBuilder: { dismissAction in
                
                    .init(
                        DeleteEmployeeAlertView(
                            dismissAction: dismissAction
                        ).asAnyView()
                    )
                
            },
            cornerRadius: Style.shared.radius(.medium),
            backgroundCardInset: .init(top: 0, left: 0, bottom: 0, right: 0),
            contentCardInset: .init(top: 16, left: 16, bottom: 32, right: 16),
            cardBackgroundColor: Style.shared.background(.secondary),
            shouldDismissOnOutsideTouch: true,
            shouldDismissOnDrag: true
        )
        
    }
    
}

fileprivate
struct DeleteEmployeeAlertView: View {
    
    private let dismissAction: () -> Void
    
    init(dismissAction: @escaping () -> Void) {
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            HStack {
                
                Text("Delete Employee?")
                    .appFont(with: .HEADER_4)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Spacer()
                
                Image(systemName: "xmark")
                    .aspectRatio(contentMode: .fit)
                    .padding(12)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .background(Style.shared.background(.quaternary).source(opacity: 0.75))
                    .clipShape(.circle)
                    .fontWeight(.semibold)
                    .asButton {
                        self.dismissAction()
                    }
                
            }
            
            Text("Are you sure you want to delete this employee? This action cannot be undone. Would you like to delete this employee from the company or just the location?")
                .appFont(with: .BODY_4)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                CommonButton(title: "Delete From Company",
                             backgroundStyle: Style.shared.background(.error)) {
                    
                }
                
                CommonButton(title: "Delete From Location",
                             backgroundStyle: Style.shared.background(.error)) {
                    
                }
                
            }
            .padding(.top, .large)
            
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        
    }
    
}

#Preview {
    
    let alertService = mockResolve(AlertServiceProtocol.self)
    
    AppBaseView(alignment: .bottom) {
        
        CommonButton(title: "Show Alert") {
            
            alertService.showAlert(
                .init(.card(
                    .deleteEmployeeAlert()
                )))
            
        }
        .padding(.horizontal, .extraLarge)
        
    }
    .withMockServices()
    
}
