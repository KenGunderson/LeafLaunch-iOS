//
//  NoteTypeSelectionView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/31/25.
//

import SwiftUI

struct NoteTypeSelectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let selectedNoteTypeAction: (NoteType) -> Void
    
    init(selectedNoteTypeAction: @escaping (NoteType) -> Void) {
        self.selectedNoteTypeAction = selectedNoteTypeAction
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            Text("Select Note Type:")
                .appFont(with: .HEADER_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            ForEach(NoteType.allCases, id: \.rawValue) { source in
                noteTypeItemView(source)
            }
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .large)
        .background(Style.shared.background(.primary).source())
        
    }
    
    @ViewBuilder
    private func noteTypeItemView(_ noteType: NoteType) -> some View {
        
        AppCardView(shadow: .subtle) {
            
            Text(noteType.displayName)
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .asButton {
            
            selectedNoteTypeAction(noteType)
            dismiss()
            
        }
        
    }
    
}

#Preview {
    
    NoteTypeSelectionView { noteType in
        print(noteType.displayName)
    }
    
}
