//
//  FAQViewModel.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 1/23/25.
//

import SwiftUI
import Combine

final class FAQViewModel: ViewModel {
    
    internal let loggerName: String = "FAQ_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"
    
    struct FAQItem: Hashable {
        
        let title: String
        let description: String
        
    }
    
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    
    private var cancelBag: CancelBag!
    
    @Published private(set) var faqItems: [FAQItem] = []
    
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        self.faqItems = buildFAQItems()
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
    private func buildFAQItems() -> [FAQItem] {
        
        return [
            
            .init(
                title: "What is My First Day?",
                description: """
                My First Day is a demo designed to showcase how a well-structured app can provide a seamless and intuitive user experience. It demonstrates key features and capabilities in a way that is accessible to everyone.

                This app focuses on providing users with clear guidance, organized content, and interactive elements to make the experience as engaging as possible. Whether you're exploring for the first time or coming back to refine your workflow, My First Day has you covered.

                The goal is to set the standard for functionality while ensuring the app feels approachable and user-friendly. It's not just about features—it's about making your first interaction memorable.
                """
            ),
            .init(
                title: "How do I use the app?",
                description: """
                Using the app is simple and intuitive. Start by exploring the main features presented on the home screen. Each section is designed to guide you step by step through its functionality.

                If you're unsure about a feature, look for tooltips or help icons that provide additional information. These hints are built into the app to make navigation as straightforward as possible.

                For an even smoother experience, follow the on-screen prompts that appear during your journey. These prompts are tailored to provide just the right amount of assistance without feeling intrusive.
                """
            ),
            .init(
                title: "Can I customize my experience?",
                description: """
                Absolutely! Customizing your experience is a key feature of this app. You can adjust settings and preferences to make the app work exactly how you like it.

                Whether it's changing the theme, setting reminders, or organizing features based on your workflow, the app offers a variety of options to personalize your journey. Take some time to explore the settings menu to unlock all the possibilities.

                Your preferences are saved and applied instantly, ensuring that the app always feels like it’s designed just for you. If you ever want to reset your changes, you can do so with a single tap.
                """
            ),
            .init(
                title: "What should I do if I encounter an issue?",
                description: """
                If you run into any issues while using the app, don’t worry! We've provided a 'Help & Support' section where you can find quick solutions to common problems.

                Start by reviewing the FAQs and troubleshooting guides available in the app. These resources are designed to address most questions and concerns quickly.

                If you need further assistance, our support team is just a message away. Use the contact form in the 'Help & Support' section to reach out, and someone will get back to you as soon as possible.
                """
            ),
            .init(
                title: "Is there a way to provide feedback?",
                description: """
                Yes, we welcome your feedback! It’s important for us to know what’s working well and what can be improved.

                To share your thoughts, head to the feedback section in the app. There, you’ll find a simple form where you can describe your experience, suggest new features, or report any bugs.

                Your feedback helps shape the future of this app, ensuring it meets the needs of all users. We appreciate you taking the time to help us improve!
                """
            )
            
        ]
        
    }
    
}

extension FAQViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.faq))
    }
    
}
