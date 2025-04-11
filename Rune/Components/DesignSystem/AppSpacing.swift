//
//  AppSpacing.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/31/23.
//

//import SwiftUI
//
//enum Spacing {
//    
//    /// 0
//    case none
//    
//    /// 4
//    case xSmall
//    
//    /// 8
//    case small
//    
//    /// 16
//    case medium
//    
//    /// 24
//    case large
//    
//    /// 32
//    case xLarge
//    
//    /// custom
//    case custom(CGFloat)
//    
//    var value: CGFloat {
//        switch self {
//        case .none: return 0
//        case .xSmall: return 4
//        case .small: return 8
//        case .medium: return 16
//        case .large: return 24
//        case .xLarge: return 32
//        case .custom(let size): return size
//        }
//    }
//    
//}
//
//extension View {
//    
//    func padding(_ edges: Edge.Set = .all,
//                 _ length: CustomTheme.SpacingKey) -> some View {
//        
//        return self.padding(edges, length.value)
//        
//    }
//    
//    func padding(_ length: CustomTheme.SpacingKey) -> some View {
//        
//        return self.padding(.all, length.value)
//        
//    }
//    
//}
//
////extension CGFloat {
////    
////    /// Represents a spacing of 0.
////    static let appNone = Spacing.none.value
////    
////    /// Represents a spacing of 4.
////    static let appXSmall = Spacing.xSmall.value
////    
////    /// Represents a spacing of 8.
////    static let appSmall = DesignSystem.shared.spacing(.small)
////    
////    /// Represents a spacing of 16.
////    static let appMedium = DesignSystem.shared.spacing(.medium)
////    
////    /// Represents a spacing of 24.
////    static let appLarge = DesignSystem.shared.spacing(.large)
////    
////    /// Represents a spacing of 32.
////    static let appXLarge = DesignSystem.shared.spacing(.xLarge)
////    
////}
//
//extension EdgeInsets {
//    
//    init(top: CustomTheme.SpacingKey = .none,
//         left: CustomTheme.SpacingKey = .none,
//         bottom: CustomTheme.SpacingKey = .none,
//         right: CustomTheme.SpacingKey = .none) {
//        
//        self.init(
//            top: top.value,
//            leading: left.value,
//            bottom: bottom.value,
//            trailing: right.value
//        )
//        
//    }
//    
//    init(spacing: CustomTheme.SpacingKey) {
//        
//        self.init(
//            top: CustomTheme.SpacingKey.value,
//            leading: CustomTheme.SpacingKey.value,
//            bottom: CustomTheme.SpacingKey.value,
//            trailing: CustomTheme.SpacingKey.value
//        )
//        
//    }
//
//    init(verticalSpacing spacing: CustomTheme.SpacingKey) {
//        
//        self.init(
//            top: CustomTheme.SpacingKey.value,
//            leading: 0,
//            bottom: CustomTheme.SpacingKey.value,
//            trailing: 0
//        )
//        
//    }
//
//    init(horizontalSpacing spacing: CustomTheme.SpacingKey) {
//        
//        self.init(
//            top: 0,
//            leading: CustomTheme.SpacingKey.value,
//            bottom: 0,
//            trailing: CustomTheme.SpacingKey.value
//        )
//        
//    }
//    
//}
