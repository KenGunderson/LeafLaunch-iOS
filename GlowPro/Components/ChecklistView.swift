//
//  ChecklistView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/28/25.
//

import SwiftUI

struct ChecklistView: View {
    
    enum ChecklistItemType: String, CaseIterable {
        
        case completeProfile
        case createLocation
        case createClient
        case createMedia
        
        var displayName: String {
            switch self {
            case .completeProfile: return "Complete Profile"
            case .createLocation: return "Create Location"
            case .createClient: return "Add Client"
            case .createMedia: return "Take a Photo"
            }
        }
        
        var icon: ImageSource {
            switch self {
            case .completeProfile: return ActivityCategory.business.icon
            case .createLocation: return ActivityCategory.location.icon
            case .createClient: return ActivityCategory.client.icon
            case .createMedia: return ActivityCategory.camera.icon
            }
        }
        
        var color: Color {
            switch self {
            case .completeProfile: return ActivityCategory.business.color
            case .createLocation: return ActivityCategory.location.color
            case .createClient: return ActivityCategory.client.color
            case .createMedia: return ActivityCategory.camera.color
            }
        }
         
    }
    
    struct ChecklistItem: Equatable {
        
        let type: ChecklistItemType
        let isComplete: Bool
        
        init(type: ChecklistItemType,
             isComplete: Bool) {
            
            self.type = type
            self.isComplete = isComplete
            
        }
        
    }
    
    let checklistItems: [ChecklistItem]
    let checklistAction: (ChecklistItemType) -> Void
    
    var progress: Int {
        
        let completedItems = self.checklistItems.filter { $0.isComplete }.count
        let totalCount = self.checklistItems.count
        
        return (completedItems / totalCount) * 100
        
    }
    
    var body: some View {
     
        VStack(spacing: Style.shared.spacing(.none)) {
            
            ForEach(self.checklistItems, id: \.type) { item in
                
                let isLastItem = (item.type == self.checklistItems.last?.type)
                
                itemView(
                    item,
                    isLastItem: isLastItem
                )
                .appOnTapGesture {
                    self.checklistAction(item.type)
                }
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .background(Style.shared.background(.secondary).source())
        .appBorder(config: .init(cornerRadius: .small2, tintColor: Style.shared.background(.quaternary)))
        
    }
    
    @ViewBuilder
    private func itemView(_ item: ChecklistItem,
                          isLastItem: Bool) -> some View {
        
        VStack(alignment: .leading,
               spacing: Style.shared.spacing(.medium)) {
            
            HStack {
                
                item.type
                    .icon
                    .view(renderingMode: .template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .frame(maxWidth: 24, maxHeight: 24)
                    .foregroundStyle(item.type.color)
                    .frame(width: 40, height: 40)
                    .background(item.type.color.opacity(0.10))
                    .cornerRadius(.small)
                    .appBorder(
                        cornerRadius: .small,
                        color: .color(item.type.color),
                        lineWidth: 2
                    )
                
                Text(item.type.displayName)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: item.isComplete ? "checkmark.circle.fill" : "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: item.isComplete ? 28 : 16,
                        height: item.isComplete ? 28 : 16
                    )
                    .foregroundStyle(
                        item.isComplete
                            ? Style.shared.accent.source()
                            : Style.shared.background(.quaternary).source()
                    )
                
            }
            .padding(.horizontal, .small2)
            
            if !isLastItem {
                
                Rectangle()
                    .fill(Style.shared.background(.quaternary).source())
                    .frame(height: 1.5)
                
            }
            
        }
        .padding(.top, .medium)
        .padding(.bottom, isLastItem ? .medium : .none)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.backgroundTappable)
        
    }
    
}

#Preview {
    
    @Previewable @State var toggleValue: Bool = false
    
    AppBaseView {
        
        ChecklistView(checklistItems: [
            .init(type: .completeProfile, isComplete: toggleValue),
            .init(type: .createLocation, isComplete: toggleValue),
            .init(type: .createClient, isComplete: toggleValue),
            .init(type: .createMedia, isComplete: toggleValue),
        ]) { _ in
            
        }
        .padding(.horizontal, .large)
        
    }
    .onTapGesture {
        toggleValue.toggle()
    }
    
}
