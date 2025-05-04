//
//  LoggerService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import OSLog

extension Logger {
    
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    // MARK: - SERVICES
    
    static let auth = Logger(subsystem: subsystem, category: "[🔑🔑🔑🔑🔑 AUTH_SERVICE]")
    static let alert = Logger(subsystem: subsystem, category: "[🚨🚨🚨🚨🚨 ALERT_SERVICE]")
    static let firebase = Logger(subsystem: subsystem, category: "[🔥🔥🔥🔥🔥 FIREBASE_SERVICE]")
    static let deeplink = Logger(subsystem: subsystem, category: "[🔗🔗🔗🔗🔗 DEEPLINK_SERVICE]")
    static let impersonate = Logger(subsystem: subsystem, category: "[🕵️‍♂️🕵️‍♂️🕵️‍♂️🕵️‍♂️🕵️‍♂️ IMPERSONATE_SERVICE]")
    static let API = Logger(subsystem: subsystem, category: "[🌐🌐🌐🌐🌐 API_SERVICE]")
    static let mockAPI = Logger(subsystem: subsystem, category: "[🌐🌐🌐🌐🌐 MOCK_API_SERVICE]")
    static let analyticsAPI = Logger(subsystem: subsystem, category: "[🌐🌐🌐🌐🌐 ANALYTICS_API_SERVICE]")
    static let webSocket = Logger(subsystem: subsystem, category: "[🌐🌐🌐🌐🌐 WEB_SOCKET_SERVICE]")
    static let appDelegate = Logger(subsystem: subsystem, category: "[🗂️🗂️🗂️🗂️🗂️ APP_DELEGATE]")
    static let pushNotification = Logger(subsystem: subsystem, category: "[📬📬📬📬📬 PUSH_NOTIFICATION_SERVICE]")
    static let lifecycle = Logger(subsystem: subsystem, category: "[♻️♻️♻️♻️♻️ PUSH_NOTIFICATION_SERVICE]")
    static let analytics = Logger(subsystem: subsystem, category: "[🎥🎥🎥🎥🎥 ANALYTICS_SERVICE]")
    static let widget = Logger(subsystem: subsystem, category: "[⌚️⌚️⌚️⌚️⌚️ WIDGET_SERVICE]")
    static let environment = Logger(subsystem: subsystem, category: "[🌍🌍🌍🌍🌍 ENVIRONMENT_SERVICE]")
    static let connectivity = Logger(subsystem: subsystem, category: "[📡📡📡📡📡 CONNECTIVITY_SERVICE]")
    static let launch = Logger(subsystem: subsystem, category: "[🚀🚀🚀🚀🚀 LAUNCH_SERVICE]")
    static let permissions = Logger(subsystem: subsystem, category: "[📜📜📜📜📜 PERMISSIONS_SERVICE]")
    static let userDefaults = Logger(subsystem: subsystem, category: "[🗄️🗄️🗄️🗄️🗄️ PERMISSIONS_SERVICE]")
    static let navigation = Logger(subsystem: subsystem, category: "[🧭🧭🧭🧭🧭 NAVIGATION_SERVICE]")
    
    // MARK: - VIEW MODELS

    static let root = Logger(subsystem: subsystem, category: "[🌳🌳🌳🌳🌳 ROOT]")
    static let main = Logger(subsystem: subsystem, category: "[🏁🏁🏁🏁🏁 MAIN]")
    static let onboarding = Logger(subsystem: subsystem, category: "[🎟️🎟️🎟️🎟️🎟️ MAIN]")
    static let home = Logger(subsystem: subsystem, category: "[🏠🏠🏠🏠🏠 HOME]")
    
    static let whatsNew = Logger(subsystem: subsystem, category: "[🆕🆕🆕🆕🆕 WHATS_NEW]")
    
    static let tab1 = Logger(subsystem: subsystem, category: "[🆕🆕🆕🆕🆕 TAB_1]")
    static let tab2 = Logger(subsystem: subsystem, category: "[🆕🆕🆕🆕🆕 TAB_2]")
    static let tab3 = Logger(subsystem: subsystem, category: "[🆕🆕🆕🆕🆕 TAB_3]")
    static let tab4 = Logger(subsystem: subsystem, category: "[🆕🆕🆕🆕🆕 TAB_4]")
    
    // MARK: Auth
    
    static let welcome = Logger(subsystem: subsystem, category: "[WELCOME]")
    static let login = Logger(subsystem: subsystem, category: "[LOGIN]")
    static let signUp = Logger(subsystem: subsystem, category: "[SIGN_UP]")

}


extension Logger {
    
    func prettyLogging(level: OSLogType = .debug,
                       title: String,
                       message: String) {
        
        let messageWithSpacing = """
        \(title):
        \(message)
        """
        
        self.log(level: level, "\(messageWithSpacing)")
        
    }
    
}
