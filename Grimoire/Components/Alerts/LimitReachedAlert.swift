//
//  LimitReachedAlert.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 11/22/25.
//

import SwiftUI

@MainActor
extension AppCardConfig {
    
    struct LimitReachhedAlert {
        
        let type: LimitType
        let businessName: String
        let isSubscribed: Bool
        let subscribeAction: () -> Void
        let dismissAction: () -> Void
        
    }
    
    enum LimitType {
        
        case media
        case location
        case employee
        
        var cardTitle: String {
            switch self {
            case .media: return "Limit Reached"
            case .location: return "Limit Reached"
            case .employee: return "Limit Reached"
            }
        }
        
        var systemImageName: String {
            switch self {
            case .media: return "camera.circle.fill"
            case .location: return "pin.circle.fill"
            case .employee: return "person.circle.fill"
            }
        }
        
        func headerSuffix(businessName: String) -> String {
            switch self {
            case .media: return "has reached its monthly media limit."
            case .location: return "has reached its location limit."
            case .employee: return "has reached its team member limit."
            }
        }
        
        var introLine: String {
            switch self {
            case .media:
                return "Good news: everything you’ve already saved is safe and sound. "
            case .location:
                return "Good news: everything you’ve already set up is safe and sound. "
            case .employee:
                return "Good news: your current team and their access are not affected. "
            }
        }
        
        func subscribedBody(businessName: String) -> String {
            
            switch self {
            case .media:
                
                return """
                You’re already on a Grimoire plan.
                
                To keep capturing new photos and videos this month, you can:\n
                • Upgrade your plan for a bigger monthly media limit.\n
                • Turn on “Allow Overages” in Security Settings
                """
                
            case .location:
                
                return """
                You’re already on a Grimoire plan.
                
                To add another location, you can:\n
                • Upgrade your plan to support more locations.\n
                • Remove a location you no longer need to free up a spot.
                """
                
            case .employee:
                
                return """
                You’re already on a Grimoire plan.
                
                To add another team member, you can:\n
                • Upgrade your plan to support more employees.\n
                • Remove a team member you no longer need to free up a seat.
                """
            }
            
        }
        
        func unsubscribedBody(businessName: String) -> String {
            
            switch self {
            case .media:
                
                return """
                \(businessName) has reached the maximum number of media for the free tier. Subscribe today to add more media and continue your operations.
                """
                
            case .location:
                
                return """
                \(businessName) has reached the maximum number of locations for the free tier. Subscribe today to add more locations and centralize your operations.
                """
                
            case .employee:
                
                return """
                \(businessName) has reached the maximum number of employees for the free tier. Subscribe today to add more employees to your business.
                """
            }
            
        }
        
    }
    
    static func limitReachedAlert(limitReachedAlert: LimitReachhedAlert) -> AppCardConfig {
        
        let businessName = limitReachedAlert.businessName
        let isSubscribed = limitReachedAlert.isSubscribed
        let type = limitReachedAlert.type
        
        let isSubscribedText: String = {
            if isSubscribed {
                return limitReachedAlert.type.subscribedBody(businessName: businessName)
            } else {
                return limitReachedAlert.type.unsubscribedBody(businessName: businessName)
            }
        }()
        
        let actionTitle: String = {
            isSubscribed ? "Upgrade" : "Subscribe"
        }()
        
        let attributedText = AttributedText {
            
            Text("\(businessName) ")
                .font(Style.shared.font(.HEADER_1))
                .foregroundStyle(Style.shared.accent.source())
            
            Text(type.headerSuffix(businessName: businessName))
                .foregroundStyle(Style.shared.textColor(.title).source())
                .font(Style.shared.font(.HEADER_1))
            
            Text("\n\n")
            
            Text(type.introLine)
                .font(Style.shared.font(.BODY_3))
                .foregroundStyle(Style.shared.textColor(.body).source())
            
            Text(isSubscribedText)
                .font(Style.shared.font(.BODY_3))
                .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        
        return .init(
            viewBuilder: { dismissAction in
                
                BaseAppCardConfigView(
                    image: .systemImage(type.systemImageName),
                    title: type.cardTitle,
                    attributedText: attributedText,
                    tintColor: Style.shared.accent,
                    actionTitle: actionTitle,
                    action: {
                        
                        dismissAction()
                        limitReachedAlert.subscribeAction()
                        
                    })
                .overlay(alignment: .topTrailing) {
                    
                    CircularIconView(
                        foregroundColor: Style.shared.textColor(.titleInverted),
                        backgroundColor: Style.shared.background(.quaternary),
                        imageSource: .systemImage("xmark"),
                        size: 36
                    )
                    .asButton {
                        
                        dismissAction()
                        limitReachedAlert.dismissAction()
                        
                    }
                    .padding(.top, -Style.shared.spacing(.small2))
                    
                }
                .asAnyView()
                
            },
            cornerRadius: Style.shared.radius(.large),
            backgroundCardInset: .init(top: 0, left: 24, bottom: UIScreen.main.bounds.height * 0.20, right: 24),
            contentCardInset: .init(top: 40, left: 16, bottom: 40, right: 16),
            cardBackgroundColor: Style.shared.background(.secondary),
            shouldDismissOnOutsideTouch: false,
            shouldDismissOnDrag: false
        )
    }
    
}

#Preview {
    
    let alertService = mockResolve(AlertServiceProtocol.self)
    
    AppBaseView(alignment: .bottom) {
        
        CommonButton(title: "Show Alert") {
            
            alertService
                .showAlert(.init(.card(
                    
                    .limitReachedAlert(
                        limitReachedAlert: .init(
                            type: .media,
                            businessName: "Mock Business",
                            isSubscribed: true,
                            subscribeAction: {
                                
                            }, dismissAction: {
                                
                            })
                    )
                    
                )))

        }
        .padding(.horizontal, .extraLarge)
        
    }
    .withMockServices()
    
}
