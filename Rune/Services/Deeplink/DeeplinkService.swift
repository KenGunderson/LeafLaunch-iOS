//
//  DeeplinkService.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/15/24.
//

// Example Deeplink
/// `gentle-path://{host}/{route}`
/// We technically don't need host, we have it in case of the navigation tab bar later down the road

// DEEPLINKS

/// TAB: `gentle-path://host/tab?tab=community` { ANY TAB ITEM GOES HERE }
// TODO: - MAKE PATHS HERE FOR EASY REFERENCE

import Foundation

// TODO: - Make this case iterable to produce errors in dev debug

enum DeeplinkRoutes: String, CaseIterable {
    
    case tab
    
}

class DeeplinkService: DeeplinkServiceProtocol {
    
    private var tabBarNavigationService: TabBarNavigationService?
    private var mainViewModel: MainViewModel?
    private let lifecycleService: ViewLifecycleServiceProtocol
    
    private let logger = RuneLogger.service(.deeplink)
    
    init(lifecycleService: ViewLifecycleServiceProtocol) {
        
        self.lifecycleService = lifecycleService
        self.logger.logInit()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func setup(mainViewModel: MainViewModel?,
               tabBarNavigationService: TabBarNavigationService) {
        
        self.mainViewModel = mainViewModel
        self.tabBarNavigationService = tabBarNavigationService
        
    }
    
    func handle(url: URL) {
        
        self.logger.debugMessage("Handle URL \(url)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        if let _ = components.host {
            
            let paths = components.path.components(separatedBy: "/").dropFirst()
            let queryParameters = components.queryItems
            
            guard let deepLink = DeeplinkRoutes(rawValue: paths.first ?? "") else { return }
            
            self.logger
                .prettyDebugMessage("\(deepLink.rawValue)")
            
            switch deepLink {
            case .tab:
                
                handleTabDeeplink(from: queryParameters)
                return
                
            }
            
        }
        
    }
    
    // *****************************
    // MARK: - TAB -
    // *****************************
    
    private func handleTabDeeplink(from queryParameters: [URLQueryItem]?) {
        
        if let tab = queryParameters?.first(where: { $0.name == "tab" }),
           let tabString = tab.value {
            
            self.logger
                .debugMessage("\(tab.value ?? "")")
            
            guard let selectedTab = Tab(rawValue: tabString) else { return }
                        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.tabBarNavigationService?.select(selectedTab)
            }
            
        }
        
    }
//    
//    // *****************************
//    // MARK: - SEARCH -
//    // *****************************
//    
//    private func handleSearchDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        if let searchQueryParam = queryParameters?.first(where: { $0.name == "query" }),
//           let query = searchQueryParam.value,
//           !query.isEmpty {
//                        
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?
//                    .currentNavigationService()
//                    .push(.search(query: nil))
//                
//            }
//            
//        }
//        
//    }
//    
//    // *****************************
//    // MARK: - RESOURCES -
//    // *****************************
//    
//    private func handleBlogsDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            
//            self?.tabBarNavigationService?.select(.resources)
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?
//                    .currentNavigationService()
//                    .push(.blogs)
//                
//            }
//            
//        }
//        
//    }
//    
//    private func handleBlogDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        if let blogQueryParam = queryParameters?.first(where: { $0.name == "blog_id" }),
//           let blogId = blogQueryParam.value {
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?.select(.resources)
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                    
//                    self?.tabBarNavigationService?
//                        .currentNavigationService()
//                        .push(.blogDetails(blogId: blogId))
//                    
//                }
//                
//            }
//            
//        }
//        
//    }
//    
//    private func handleResourceCategoryDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            
//            self?.tabBarNavigationService?
//                .currentNavigationService()
//                .push(.resource(.categoryList))
//            
//        }
//        
//    }
//    
//    private func handleResourceSubcategoryDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        if let categoryQueryParam = queryParameters?.first(where: { $0.name == "category" }),
//           let categoryString = categoryQueryParam.value {
//            
//            self.logger
//                .debugMessage("\(categoryString)")
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                var context: ResourceSubcategoryListViewModel.Context {
//                    
//                    return categoryString.count >= 30
//                    ? .resourceCategory(id: categoryString)
//                    : .resource(type: categoryString)
//                    
//                }
//                
//                self?.tabBarNavigationService?
//                    .currentNavigationService()
//                    .push(.resource(.subcategoryList(context: context)))
//                
//            }
//            
//        }
//        
//    }
//    
//    private func handleResourceItemListDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        if let route = getRouteForItemDeeplink(from: queryParameters) {
//            
//            self.tabBarNavigationService?
//                .currentNavigationService()
//                .push(route)
//            
//        }
//        
//    }
//    
//    private func getRouteForItemDeeplink(from queryParameters: [URLQueryItem]?) -> Route? {
//        
//        if let categoryQueryParam = queryParameters?.first(where: { $0.name == "item_id" }),
//           let categoryString = categoryQueryParam.value {
//            
//            return .resource(.details(id: categoryString))
//            
//        }
//        
//        return nil
//        
//    }
//    
//    private func handleMilestonesDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            
//            self?.tabBarNavigationService?.select(.resources)
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?
//                    .currentNavigationService()
//                    .push(.milestones)
//                
//            }
//            
//        }
//        
//    }
//    
//    private func handleMilestoneDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        if let milestoneIdParam = queryParameters?.first(where: { $0.name == "milestone_id" }),
//           let milestoneId = milestoneIdParam.value,
//           !milestoneId.isEmpty {
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?.select(.resources)
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                    
//                    self?.tabBarNavigationService?
//                        .currentNavigationService()
//                        .push(.milestoneDetails(milestoneId: milestoneId))
//                    
//                }
//                
//            }
//            
//        }
//        
//    }
//    
//    // *****************************
//    // MARK: - COMMUNITY -
//    // *****************************
//    
//    private func handleCommunityPostsDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            
//            self?.tabBarNavigationService?.select(.community)
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?
//                    .currentNavigationService()
//                    .push(.communityPosts)
//                
//            }
//            
//        }
//        
//    }
//    
//    private func handleCommunityPostDetailsDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        if let postIdParam = queryParameters?.first(where: { $0.name == "post_id" }),
//           let postId = postIdParam.value,
//           !postId.isEmpty {
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?.select(.community)
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                    
//                    self?.tabBarNavigationService?
//                        .currentNavigationService()
//                        .push(.communityPostDetails(postId: postId))
//                    
//                }
//                
//            }
//            
//        }
//        
//    }
//   
//    private func handleCommunityPollDetailsDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        if let pollIdParam = queryParameters?.first(where: { $0.name == "poll_id" }),
//           let pollId = pollIdParam.value,
//           !pollId.isEmpty {
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?.select(.community)
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                    
//                    self?.tabBarNavigationService?
//                        .currentNavigationService()
//                        .push(.communityPollsDetails(pollId: pollId))
//                    
//                }
//                
//            }
//            
//        }
//        
//    }
//    
//    private func handleCommunityCreatePoll(from queryParameters: [URLQueryItem]?) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//         
//            self?.tabBarNavigationService?.select(.community)
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?
//                    .currentNavigationService()
//                    .modal(fullScreenCover: .communityCreatePoll)
//                
//            }
//            
//        }
//        
//    }
//    
//    private func handleCommunityPollsDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            
//            self?.tabBarNavigationService?.select(.community)
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?
//                    .currentNavigationService()
//                    .push(.communityPolls)
//                
//            }
//            
//        }
//        
//    }
//    
//    private func handleCommunityCreatePostDeeplink(from queryParameters: [URLQueryItem]?) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            
//            self?.tabBarNavigationService?.select(.community)
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                
//                self?.tabBarNavigationService?
//                    .currentNavigationService()
//                    .modal(fullScreenCover: .communityCreateUpdatePost(context: .create))
//                
//            }
//            
//        }
//        
//    }
    
}
