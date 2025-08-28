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
        case createOrJoinBusiness
        case addClient
        case takeAPhoto
        
        var displayName: String {
            switch self {
            case .completeProfile: return "Complete Profile"
            case .createOrJoinBusiness: return "Create or Join Business"
            case .addClient: return "Add Client"
            case .takeAPhoto: return "Take a Photo"
            }
        }
        
        var icon: ImageSource {
            switch self {
            case .completeProfile: return .image(.iconNoteOutline)
            case .createOrJoinBusiness: return .systemImage("storefront")
            case .addClient: return .image(.iconPersonOutline)
            case .takeAPhoto: return .image(.iconCamera)
            }
        }
        
        var color: Color {
            switch self {
            case .completeProfile: return GPColor.iconGreen
            case .createOrJoinBusiness: return GPColor.iconBlue
            case .addClient: return GPColor.iconPurple
            case .takeAPhoto: return GPColor.iconTeal
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
                
            }
            .animation(.smooth, value: self.checklistItems)
            
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
                        color: .color(item.type.color)
                    )
                
                Text(item.type.displayName)
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(
                        item.isComplete
                            ? Style.shared.accent.source()
                            : Style.shared.background(.quaternary).source()
                    )
                    .contentTransition(.symbolEffect(.replace))
                
                
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
        
    }
    
}

#Preview {
    
    @Previewable @State var toggleValue: Bool = false
    
    AppBaseView {
        
        ChecklistView(checklistItems: [
            .init(type: .completeProfile, isComplete: toggleValue),
            .init(type: .createOrJoinBusiness, isComplete: toggleValue),
            .init(type: .addClient, isComplete: toggleValue),
            .init(type: .takeAPhoto, isComplete: toggleValue),
        ])
        .padding(.horizontal, .large)
        
    }
    .onTapGesture {
        toggleValue.toggle()
    }
    
}
