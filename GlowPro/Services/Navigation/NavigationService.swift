//
//  NavigationService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI
import Combine

@Observable
class NavigationService: NavigationServiceProtocol, Equatable {
    
    static func == (lhs: NavigationService, rhs: NavigationService) -> Bool {
        
        lhs.routes == rhs.routes &&
        lhs.sheet == rhs.sheet &&
        lhs.fullScreenCover == rhs.fullScreenCover
        
    }
    
    var routes: [Route] = []
    var sheet: Sheet?
    var fullScreenCover: FullScreenCover?
    
    func push(_ route: Route) {
        self.routes.append(route)
    }
    
    func push(_ routes: [Route]) {
        self.routes.append(contentsOf: routes)
    }
    
    func pop() {
        
        guard !self.routes.isEmpty else { return }
        self.routes.removeLast()
        
    }
    
    func popWithDelay(_ delay: TimeInterval = 0.2) {
        
        guard !self.routes.isEmpty else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.routes.removeLast()
        }
        
    }
    
    func popLast(count: Int) {
        
        guard count > 0 else { return }
        guard !self.routes.isEmpty else { return }
        
        let safeCount = min(count, self.routes.count)
        self.routes.removeLast(safeCount)
        
    }
    
    func popToRoot() {
        self.routes = []
    }
    
    func swap(_ route: Route) {
        
        self.routes.removeLast()
        self.routes.append(route)
        
    }
    
    func replaceStack(_ route: Route) {
        
        self.routes.removeAll()
        
        Task { @MainActor in
            //The time delay may be device/app specific.
            try? await Task.sleep(nanoseconds: 400_000_000)
            await MainActor.run { [weak self] in
                self?.push(route)
            }
            
        }
        
    }
    
    // Sheets
    
    func modal(sheet: Sheet) {
        self.sheet = sheet
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    // FullScreenCover
    
    func modal(fullScreenCover: FullScreenCover) {
        self.fullScreenCover = fullScreenCover
    }
    
    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }
    
}

extension View {
    
    func withNavigationDestination() -> some View {
        
        return navigationDestination(for: Route.self) { route in
            
            switch route {
            case .auth(let route): auth(route: route)
            case .onboarding(let route): onboarding(route: route)
            case .setting(let route): settings(route: route)
            case .devSetting(let route): devSettings(route: route)
            case .business(let route): business(route: route)
            case .client(let route): client(route: route)
            case .media(let route): media(route: route)
            case .collage(let route): collage(route: route)
            case .note(let route): note(route: route)
            }
            
        }
        
        @ViewBuilder
        func auth(route: Route.Auth) -> some View {
            
            switch route {
            case .welcome:
                
                let viewModel = globalResolver.resolve(WelcomeViewModel.self)!
                
                WelcomeScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .login:
                
                let viewModel = globalResolver.resolve(LoginViewModel.self)!
                
                LoginScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .signup:
                
                let viewModel = globalResolver.resolve(SignUpViewModel.self)!
                
                SignUpScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
            }
            
        }
        
        @ViewBuilder
        func onboarding(route: Route.Onboarding) -> some View {
            
            switch route {
            case .businessSetup:
                
                OnboardingFeaturesScreen(onboardingPage: .businessSetup)
                    .navigationBarBackButtonHidden()
                
            case .locationControl:
                
                OnboardingFeaturesScreen(onboardingPage: .locationControl)
                    .navigationBarBackButtonHidden()
                
            case .photos:
                
                OnboardingFeaturesScreen(onboardingPage: .photos)
                    .navigationBarBackButtonHidden()
                
            case .beforeAndAfter:
                
                OnboardingFeaturesScreen(onboardingPage: .beforeAndAfter)
                    .navigationBarBackButtonHidden()
                
            case .documentation:
                
                OnboardingFeaturesScreen(onboardingPage: .documentation)
                    .navigationBarBackButtonHidden()
                
            case .permission:
                
                let viewModel = globalResolver.resolve(OnboardingPermissionsViewModel.self)!
                
                OnboardingPermissionsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
            }
            
        }
        
        @ViewBuilder
        func settings(route: Route.Setting) -> some View {
            
            switch route {
            case .profile: EmptyView()
            case .subscription: EmptyView()
            case .security:
                
                let viewModel = globalResolver.resolve(SecurityViewModel.self)!
                
                SecurityScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .aboutUs:
                
                let viewModel = globalResolver.resolve(AboutUsViewModel.self)!
                
                AboutUsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .frequentlyAskedQuestions:
                
                let viewModel = globalResolver.resolve(FAQViewModel.self)!
                
                FAQScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .contactSupport: EmptyView()
            case .rateApp: EmptyView()
            case .featureRequest:
                
                let viewModel = globalResolver.resolve(FeatureRequestViewModel.self)!
                
                FeatureRequestScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .privacyPolicy:
                
                let viewModel = globalResolver.resolve(LegalViewModel.self)!
                    .setup(context: .privacyPolicy)
                
                LegalScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .termsOfService:
                
                let viewModel = globalResolver.resolve(LegalViewModel.self)!
                    .setup(context: .termsAndConditions)
                
                LegalScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .logout: EmptyView()
            }
            
        }
        
        @ViewBuilder
        func business(route: Route.Business) -> some View {
            
            switch route {
            case .businessHome(let businessId):
                
                let viewModel = globalResolver.resolve(BusinessHomeViewModel.self)!
                    .setup(businessId: businessId)
                
                BusinessHomeScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .businessDetails(let businessId): Text(businessId)
            case .businessCreateEdit(let businessId):
                
                let viewModel = globalResolver.resolve(BusinessCreateEditViewModel.self)!
                    .setup(businessId: businessId)
                
                BusinessCreateEditScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .businessEmployees(let businessId, let context):
                
                let viewModel = globalResolver.resolve(BusinessEmployeeListViewModel.self)!
                    .setup(
                        businessId: businessId,
                        context: context
                    )
                
                BusinessEmployeeListScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
              
            case .businessEmployeesInvite(let businessId, let context):
                
                let viewModel = globalResolver.resolve(BusinessEmployeeInviteViewModel.self)!
                    .setup(
                        businessId: businessId,
                        context: context
                    )
                
                BusinessEmployeeInviteScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .businessEmployeeInviteList(let context):
                
                let viewModel = globalResolver.resolve(BusinessEmployeeInviteListViewModel.self)!
                    .setup(context: context)
                
                BusinessEmployeeInviteListScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .businessEmployeesUpdate(let businessId, let employeeId):
                
                let viewModel = globalResolver.resolve(BusinessEmployeeUpdateViewModel.self)!
                    .setup(
                        businessId: businessId,
                        employeeId: employeeId
                    )
                
                BusinessEmployeeUpdateScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .businessEmployeeDetails(let businessId, let employeeId):
                
                let viewModel = globalResolver.resolve(BusinessEmployeeDetailsViewModel.self)!
                    .setup(
                        businessId: businessId,
                        employeeId: employeeId
                    )
                
                BusinessEmployeeDetailsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .businessLocationHome(let locationId, let completion):
                
                let viewModel = globalResolver.resolve(BusinessLocationHomeViewModel.self)!
                    .setup(
                        locationId: locationId,
                        completion: completion
                    )
                
                BusinessLocationHomeScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .businessLocationList(let businessId):
                
                let viewModel = globalResolver.resolve(BusinessLocationListViewModel.self)!
                    .setup(businessId: businessId)
                
                BusinessLocationListScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .businessLocationCreateEdit(let businessId, let locationId):
                
                let viewModel = globalResolver.resolve(BusinessLocationCreateEditViewModel.self)!
                    .setup(
                        businessId: businessId,
                        locationId: locationId
                    )
                
                BusinessLocationCreateEditScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .businessActivitiesList(let context):
                
                let viewModel = globalResolver.resolve(BusinessActivityListViewModel.self)!
                    .setup(context: context)
                
                BusinessActivityListScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
            }
            
        }
        
        @ViewBuilder
        func client(route: Route.Client) -> some View {
            
            switch route {
            case .clientCreate(let locationId, let clientId):
                
                let viewModel = globalResolver.resolve(ClientCreateEditViewModel.self)!
                    .setup(
                        locationId: locationId,
                        clientId: clientId
                    )
                
                ClientCreateEditScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .clientList(let context):
                
                let viewModel = globalResolver.resolve(ClientListViewModel.self)!
                    .setup(context: context)
                
                ClientListScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .clientHome(let clientId):
                
                let viewModel = globalResolver.resolve(ClientHomeViewModel.self)!
                    .setup(clientId: clientId)
                
                ClientHomeScreen(viewModel: viewModel)
                
            }
            
        }
        
        @ViewBuilder
        func media(route: Route.MediaRoute) -> some View {
            
            switch route {
            case .camera(let context, let mode):
                
                let viewModel = globalResolver.resolve(CameraViewModel.self)!
                    .setup(
                        context: context,
                        mode: mode
                    )
                
                CameraScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .gallery(let context, let selection, let mediaType):
                
                let viewModel = globalResolver.resolve(MediaGalleryViewModel.self)!
                    .setup(
                        mediaContext: context,
                        mediaSelectionContext: selection,
                        mediaFilterOptions: mediaType
                    )
                
                MediaGalleryScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .preview(let selectedMedia, let media):
                
                let viewModel = globalResolver.resolve(MediaPreviewViewModel.self)!
                    .setup(
                        selectedMedia: selectedMedia,
                        media: media
                    )
                
                MediaPreviewScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .review(let context, let images):
                
                let viewModel = globalResolver.resolve(MediaReviewViewModel.self)!
                    .setup(
                        context: context,
                        images: images
                    )
                
                MediaReviewScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            }
            
        }
        
        @ViewBuilder
        func note(route: Route.NoteRoute) -> some View {
            
            switch route {
            case .noteList(let clientId):
                
                let viewModel = globalResolver.resolve(NoteListViewModel.self)!
                    .setup(clientId: clientId)
                
                NoteListScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .noteCreateEdit(let context, let clientId):
                
                let viewModel = globalResolver.resolve(NoteCreateEditViewModel.self)!
                    .setup(
                        context: context,
                        clientId: clientId
                    )
                
                NoteCreateEditScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            }
            
        }
        
        @ViewBuilder
        func collage(route: Route.CollageRoute) -> some View {
            
            switch route {
            case .createEdit(let clientId, let collageId):
                
                let viewModel = globalResolver.resolve(CollageCreateEditViewModel.self)!
                    .setup(
                        clientId: clientId,
                        collageId: collageId
                    )
                
                CollageCreateEditScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
            }
            
        }
        
        @ViewBuilder
        func devSettings(route: Route.DevSetting) -> some View {
            
            switch route {
            case .components:
                
                DemoView()
                    .navigationBarBackButtonHidden()
                
            case .userDefaults:
                
                let viewModel = globalResolver.resolve(DevUserDefaultsViewModel.self)!
                
                DevUserDefaultsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .routes:
                                    
                let viewModel = globalResolver.resolve(DevRoutesViewModel.self)!
                
                DevRoutesScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .deeplinks:
                
                let viewModel = globalResolver.resolve(DevDeeplinksViewModel.self)!
                
                DevDeeplinksScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
                
            case .analytics:
                                    
                let viewModel = globalResolver.resolve(DevAnalyticsViewModel.self)!
                
                DevAnalyticsScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            case .impersonate:
                
                let viewModel = globalResolver.resolve(DevImpersonateViewModel.self)!
                
                DevImpersonateScreen(viewModel: viewModel)
                    .navigationBarBackButtonHidden()

            }
            
        }
        
    }
    
    func withSheetDestination(_ customSheet: Binding<Sheet?>) -> some View {
        
        /// DEV-NOTE: Add `presentationBackground` modifier to presenting view to avoid flickering; Apple bug
        
        // We do this for SE Phones
//        let halfSheet = 0.60
//        let iphoneSESheet = 0.70
//
//        let isModernDevice: Bool = UIDevice.isModernDevice
        
        return sheet(item: customSheet) { sheet in
            
            switch sheet {
            case .securityPin(let context,
                              let businessId,
                              let completion):
                
                let viewModel = globalResolver.resolve(SecurityPinInputViewModel.self)!
                    .setup(
                        context: context,
                        businessId: businessId,
                        completion: completion
                    )
                
                SecurityPinInputScreen(viewModel: viewModel)
                
            case .whatsNew:
                
                let viewModel = globalResolver.resolve(WhatsNewViewModel.self)!
                    .setup(whatsNewItem: Constants.WhatsNewItems.items.last!)
                
                WhatsNewScreen(viewModel: viewModel)
                
            case .permissions:
                
                Color.indigo.ignoresSafeArea()
            }
            
        }
        
    }
    
    func withFullScreenCover(_ customFullScreenCover: Binding<FullScreenCover?>) -> some View {
        
        return fullScreenCover(item: customFullScreenCover) { fullScreenCover in
            
            switch fullScreenCover {
            case .devSettings:
                
                let viewModel = globalResolver.resolve(DevSettingsViewModel.self)!
                DevSettingsScreen(viewModel: viewModel)
                
            case .onboarding:
                
                let viewModel = globalResolver.resolve(OnboardingViewModel.self)!
                    .setup(pages: [
                        .businessSetup,
                        .locationControl,
                        .photos,
                        .beforeAndAfter,
                        .documentation,
                        .permission
                    ])
                
                OnboardingScreen(viewModel: viewModel)
            
            case .settings:
                
                let viewModel = globalResolver.resolve(SettingsViewModel.self)!
                SettingsScreen(viewModel: viewModel)
                
            case .mediaTags(let selectedMedia):
                
                let viewModel = globalResolver.resolve(MediaTagViewModel.self)!
                    .setup(media: selectedMedia)
                
                MediaTagScreen(viewModel: viewModel)
                
            case .mediaMultiTags(let selectedMedia):
                
                let viewModel = globalResolver.resolve(MediaMultiTagViewModel.self)!
                    .setup(media: selectedMedia)
                
                MediaMultiTagScreen(viewModel: viewModel)
                
            case .mediaPreview(let url):
                
                MediaURLPreviewView(url: url)
                
            case .subscriptionPaywall:
                
                let viewModel = globalResolver.resolve(SubscriptionPaywallViewModel.self)!
                    .setup()
                
                SubscriptionPaywallScreen(viewModel: viewModel)
            }
            
        }
        
    }
    
}
