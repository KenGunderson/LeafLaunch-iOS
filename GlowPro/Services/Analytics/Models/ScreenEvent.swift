//
//  ScreenEvent.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/01/23.
//

import Foundation

indirect enum ScreenEvent: AnalyticsEvent {
    
    enum OnboardingScreen {
        
        case start
        case login
        case signUp
        case appOverview
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .start: name = "start"
            case .login: name = "login"
            case .signUp: name = "sign_up"
            case .appOverview: name = "app_overview"
            }
            
            return "onboarding.\(name)"
            
        }
        
    }
    
    enum Tab {
        
        case tab1
        case tab2
        case tab3
        case tab4
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .tab1: name = "Tab 1"
            case .tab2: name = "Tab 2"
            case .tab3: name = "Tab 3"
            case .tab4: name = "Tab 4"
            }
            
            return "tab.\(name)"
            
        }
        
    }
    
    enum ProfileScreen {
        
        case profile(userId: String)
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .profile: name = "user_profile"
            }
            
            return "profile.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .profile(let userId): return ["user_id": userId]
            }
            
        }
        
    }
    
    enum ResourceScreen {
        
        case resources
        case categoryList
        case subcategoryList(categoryId: String)
        case detail(itemId: String)
        
        case milestones
        case milestoneDetails(milestoneId: String)
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .resources: name = "resources"
            case .categoryList: name = "category_list"
            case .subcategoryList: name = "subcategory_list"
            case .detail: name = "detail"
            case .milestones: name = "milestones"
            case .milestoneDetails: name = "milestone_details"
            }
            
            return "resource.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .resources: return [:]
            case .categoryList: return [:]
            case .subcategoryList(let categoryId):
                
                return [
                    "category_id": categoryId
                ]
            case .detail(let itemId): return ["item_id": itemId]
            case .milestones: return [:]
            case .milestoneDetails(let milestoneId): return ["milestone_id": milestoneId]
            }
            
        }
        
    }
    
    enum CommunityScreen {
        
        case posts
        case createPost
        case updatePost(postId: String)
        case postDetails(postId: String)
        
        case polls
        case createPoll
        case pollDetails(pollId: String)
        
        case blogs
        case blogDetails(blogId: String)
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .posts: name = "posts"
            case .createPost: name = "post_create"
            case .updatePost: name = "post_update"
            case .postDetails: name = "post_details"
            case .polls: name = "polls"
            case .createPoll: name = "poll_create"
            case .pollDetails: name = "poll_details"
            case .blogs: name = "blogs"
            case .blogDetails: name = "blog_details"
            }
            
            return "community.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .posts: return [:]
            case .createPost: return [:]
            case .updatePost(let postId): return ["post_id": postId]
            case .postDetails(let postId): return ["post_id": postId]
            case .polls: return [:]
            case .createPoll: return [:]
            case .pollDetails(let pollId): return ["poll_id": pollId]
            case .blogs: return [:]
            case .blogDetails(let blogId): return ["blog_id": blogId]
            }
            
        }
        
    }
    
    enum JournalScreen {
        
        case createJournalEntry
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .createJournalEntry: name = "create_journal_entry"
            }
            
            return "journal.\(name)"
            
        }
        
    }
    
    enum Settings {
        
        case settings
        case profile
        case legal(context: String)
        case faq
        case featureRequest
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .settings: name = "settings"
            case .profile: name = "profile"
            case .legal: name = "legal"
            case .faq: name = "faq"
            case .featureRequest: name = "feature_request"
            }
            
            return "settings.\(name)"
            
        }
        
        var properties: [String: Any]? {
            
            switch self {
            case .settings: return [:]
            case .profile: return [:]
            case .legal(let context): return ["context": context]
            case .faq: return [:]
            case .featureRequest: return [:]
            }
            
        }
        
    }
    
    enum DevSettings {
        
        case settings
        case components
        case routes
        case deeplinks
        case userDefaults
        case analytics
        case impersonate
        
        var screenName: String {
            
            var name: String
            
            switch self {
            case .settings: name = "settings"
            case .components: name = "componenets"
            case .routes: name = "routes"
            case .deeplinks: name = "deeplinks"
            case .userDefaults: name = "user_defaults"
            case .analytics: name = "analytics"
            case .impersonate: name = "impersonate"
            }
            
            return "dev_settings.\(name)"
            
        }
        
    }
    
    case root
    case launch
    case main
    case onboarding(OnboardingScreen)
    case tab(Tab)
    case profile(ProfileScreen)
    case resources(ResourceScreen)
    case community(CommunityScreen)
    case journal(JournalScreen)
    case search
    case favorites
    case whatsNew
    case settings(Settings)
    case devSettings(DevSettings)
    
    var eventType: EventType {
        return .screen
    }
    
    var eventData: EventData {
        
        var screenName: String
        var properties: [String: Any]?
        
        switch self {
        case .root: screenName = "root"
        case .launch: screenName = "launch"
        case .main: screenName = "main"
        case .onboarding(let screen): screenName = screen.screenName
        case .tab(let screen): screenName = screen.screenName
        case .resources(let screen):
            
            screenName = screen.screenName
            properties = screen.properties
            
        case .community(let screen):
            
            screenName = screen.screenName
            properties = screen.properties
            
        case .journal(let screen): screenName = screen.screenName
        case .devSettings(let screen): screenName = screen.screenName
        case .search: screenName = "search"
        case .favorites: screenName = "favorites"
        case .settings(let screen): screenName = screen.screenName
        case .whatsNew: screenName = "whats_new"
        case .profile(let screen):
            
            screenName = screen.screenName
            properties = screen.properties
            
        }
        
        var _properties = properties ?? [:]
        _properties["screen"] = screenName
        
        return EventData(
            name: "screen_view",
            properties: _properties
        )
        
    }
    
}
