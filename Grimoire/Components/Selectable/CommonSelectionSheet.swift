//
//  CommonSelectionSheet.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/9/25.
//


import SwiftUI

struct CommonSelectionSheet<S: Selectable>: View {
    
    enum SelectionStyle {
        
        case single
        case multi
        
    }
    
    @Environment(\.dismiss) private var dismiss
    
    let options: [S]
    let headerTitle: String
    let headerSubtitle: String?
    let selectionStyle: SelectionStyle
    let selectionAction: (Set<S>) -> ()
    
    @State private var selectedOptions: Set<S>
    
    init(options: [S],
         headerTitle: String,
         headerSubtitle: String?,
         selectionStyle: SelectionStyle,
         selectedOptions: Set<S>,
         selectionAction: @escaping (Set<S>) -> ()) {
        
        self.options = options
        self.headerTitle = headerTitle
        self.headerSubtitle = headerSubtitle
        self.selectionStyle = selectionStyle
        self._selectedOptions = State(initialValue: selectedOptions)
        self.selectionAction = selectionAction
        
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading) {
                    
                    Text(self.headerTitle)
                        .appFont(with: .HEADER_H5)
                    
                    if let subtitle = self.headerSubtitle {
                        
                        Text(subtitle)
                            .appFont(with: .BODY_B10)
                            .foregroundStyle(.gray)
                        
                    }
                    
                }
                .padding(.bottom, .medium)
                
                ForEach(self.options, id: \.self) { option in
                    
                    optionView(
                        option,
                        isSelected: self.selectedOptions.contains(option)
                    )
                    .asButton {
                        
                        withAnimation {
                            selectOption(option)
                        }
                        
                    }
                    
                }
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .leading
            )
            .padding(.vertical, .large)
            
        }
        .safeAreaInset(edge: .bottom) {
            
            if self.selectionStyle == .multi {
                
                CommonButton(title: "Select Topics") {
                    
                    self.selectionAction(self.selectedOptions)
                    dismiss()
                    
                }
                
            }
            
        }
        .background(Style.shared.background(.primary).source())
        .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
        .scrollBounceBehavior(.basedOnSize)
        .animation(.bouncy, value: self.selectedOptions)
        
    }
    
    private func optionView(_ option: S,
                           isSelected: Bool) -> some View {
        
        AppCardView(horizontalPadding: Theme.SpacingKey.none) {
            
            HStack {
                
                if isSelected {
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: 12,
                            height: 12
                        )
                        .transition(
                            .move(edge: .leading)
                            .combined(with: .opacity)
                            .combined(with: .scale)
                        )
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.blue)
                        .clipShape(.circle)
                    
                }
                
                Text(option.description)
                    .appFont(with: .TITLE_T5)
                
            }
            .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
            
        }
        
    }
    
    private func selectOption(_ option: S) {
        
        switch self.selectionStyle {
        case .single:
            
            self.selectedOptions = [option]
            self.selectionAction(selectedOptions)
            dismiss()
            
        case .multi:
            
            if self.selectedOptions.contains(option) {
                self.selectedOptions.remove(option)
            } else {
                self.selectedOptions.insert(option)
            }
        }
        
    }
    
}

enum AssetOptions: String, Identifiable, CaseIterable, CustomStringConvertible {
    
    case bank
    case car
    case guitar
    
    var description: String {
        return self.rawValue.capitalized
    }
    
    var id: Self { self }
    
}

enum DebtOptions: String, Identifiable, CaseIterable, CustomStringConvertible {
    
    case creditCard
    case carLoan
    case studentLoan
    
    var description: String {
        return self.rawValue.capitalized
    }
    
    var id: Self { self }
    
}

#Preview {
    
    @Previewable @State var showSingleSelectionSheet: Bool = false
    @Previewable @State var showMultiSelectionSheet: Bool = false
    
    @Previewable @State var assetSingleSelection: Set<AssetOptions> = []
    @Previewable @State var debtMultiSelection: Set<DebtOptions> = []
    
    ZStack {
        
        Style
            .shared
            .background(.primary)
            .view()
            .ignoresSafeArea()
        
        VStack {
            
            CommonButton(title: "Show Single Selection Sheet") {
                showSingleSelectionSheet = true
            }
            
            if let selectedFirstAsset = assetSingleSelection.first {
                
                Text("Selected Single Topic: \(selectedFirstAsset)")
                    .transition(.slide)
                
            }
            
            CommonButton(title: "Show Multi Selection Sheet") {
                showMultiSelectionSheet = true
            }
            
            if !debtMultiSelection.isEmpty {
                
                HStack {

                    ForEach(Array(debtMultiSelection), id: \.self) { text in
                        
                        Text(text.description)
                            .appFont(with: .TITLE_T4)
                            .foregroundStyle(.black)
                            .padding(.horizontal, .medium)
                            .padding(.vertical, .small)
                            .background(Color(uiColor: .systemGray6))
                            .clipShape(.capsule)
                        
                    }
                    
                }
                
            }
            
        }
        .padding(.horizontal, .extraLarge)
        
    }
    .sheet(isPresented: $showSingleSelectionSheet) {
        
        CommonSelectionSheet(
            options: AssetOptions.allCases,
            headerTitle: "Select A Topic:",
            headerSubtitle: "Please select at least one",
            selectionStyle: .single,
            selectedOptions: assetSingleSelection) { selectedAssets in
                assetSingleSelection = selectedAssets
            }
            .presentationDetents([.fraction(0.5)])
            .presentationCornerRadius(Style.shared.radius(.large))
        
    }
    .sheet(isPresented: $showMultiSelectionSheet) {
        
        CommonSelectionSheet(
            options: DebtOptions.allCases,
            headerTitle: "Select A Topic:",
            headerSubtitle: "Please select all that apply",
            selectionStyle: .multi,
            selectedOptions: debtMultiSelection) { selectedDebts in
                debtMultiSelection = selectedDebts
            }
            .presentationDetents([.fraction(0.65)])
            .presentationCornerRadius(Style.shared.radius(.large))
        
    }
    .onChange(of: assetSingleSelection) { oldValue, newValue in
        print(newValue.map(\.description).joined(separator: ", "))
    }
    .onChange(of: debtMultiSelection) { oldValue, newValue in
        print(newValue.map(\.description).joined(separator: ", "))
    }
    
}
