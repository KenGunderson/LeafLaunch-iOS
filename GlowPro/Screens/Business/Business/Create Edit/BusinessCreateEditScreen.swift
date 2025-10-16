//
//  BusinessCreateEditScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import SwiftUI

struct BusinessCreateEditScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case name
        case email
        case phone
        
        var displayName: String {
            switch self {
            case .name: return "Business Name"
            case .email: return "Business Email"
            case .phone: return "Business Phone (Optional)"
            }
        }
        
    }
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessCreateEditViewModel
    
    @FocusState private var focusedField: FocusedField?
    
    @State private var selectedState: Constants.USState?
    @State private var isStateDropDownPresented: Bool = false
    
    var body: some View {
        
        content()
        
            // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(navigationService: self.navigationService)
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
        
            // Animations
        
            .animation(.spring, value: self.isStateDropDownPresented)
        
            // Tap
        
            .onSubmit {
                handleOnSubmit()
            }
        
            .onTapGesture {
                
                self.focusedField = nil
                self.isStateDropDownPresented = false
                
            }
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            contentCards()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: self.viewModel.isCreateContext ? "Create Business" : "Edit Business",
            leftButtonView: backButton
        )
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.large)) {
            
            businessGeneralInformation()
            categoriesView()
            subcategoriesView()
            
        }
        .padding(.horizontal, .medium)
        .padding(.bottom, .custom(72))
        .animation(.bouncy, value: self.viewModel.selectedCategories)
        .animation(.bouncy, value: self.viewModel.selectedSubcategories)
        
    }
    
    private func businessGeneralInformation() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "General Information")
            
            AppCardView {
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    textField(fieldToFocus: .name)
                    textField(fieldToFocus: .email)
                    textField(fieldToFocus: .phone)
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func categoriesView() -> some View {
        
        let allCategories = BusinessCategory.allCases
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Categories")
            
            WStack {
                
                ForEach(allCategories, id: \.rawValue) { category in
                    
                    let isSelected = self.viewModel.selectedCategories.contains(category)
                    
                    TokenView(
                        text: category.displayName,
                        foregroundStyle: isSelected ? Style.shared.textColor(.button) : Style.shared.textColor(.title),
                        backgroundStyle: isSelected ? Style.shared.accent : Style.shared.background(.quaternary)
                    )
                    .asButton {
                        self.viewModel.set(category: category)
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func subcategoriesView() -> some View {
        
        let allSubcategories = self.viewModel.selectedCategories.flatMap { $0.subcategories }

        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Subcategories")
            
            WStack {
                
                ForEach(Array(allSubcategories.enumerated()), id: \.element) { index, subcategory in
                    
                    let isSelected = self.viewModel.selectedSubcategories.contains(subcategory)
                    
                    if !self.viewModel.selectedCategories.isEmpty {
                        
                        TokenView(
                            text: subcategory.displayName,
                            foregroundStyle: isSelected ? Style.shared.textColor(.button) : Style.shared.textColor(.title),
                            backgroundStyle: isSelected ? Style.shared.accent : Style.shared.background(.quaternary)
                        )
                        .asButton {
                            self.viewModel.set(subcategory: subcategory)
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                    }
                    
                }
                
            }
            
        }
        .animation(.bouncy, value: self.viewModel.selectedCategories)
        .animation(.bouncy, value: self.viewModel.selectedSubcategories)
        
    }
    
    private func textField(fieldToFocus: FocusedField) -> some View {
        
        var text: Binding<String> = .constant("")
        var isFocused: Bool = false
        var keyboardType: UIKeyboardType = .default
        var textContentType: UITextContentType = .organizationName
        
        let placeholder: String = fieldToFocus.displayName
        
        switch fieldToFocus {
        case .name:
            
            text = self.$viewModel.name
            isFocused = self.focusedField == .name
            keyboardType = .default
            textContentType = .organizationName
            
        case .email:
            
            text = self.$viewModel.email
            isFocused = self.focusedField == .email
            keyboardType = .emailAddress
            textContentType = .emailAddress
            
        case .phone:
            
            text = self.$viewModel.phone
            isFocused = self.focusedField == .phone
            keyboardType = .phonePad
            textContentType = .telephoneNumber
        }
        
        return TextField("", text: text)
            .titleUnderlineTextFieldStyle(
                text: text.wrappedValue,
                title: placeholder,
                style: .border(cornerRadius: .custom(6)),
                isFocused: isFocused,
                foregroundColor: Style.shared.textColor(.title),
                textFieldFont: .BODY_3
            )
            .focused(self.$focusedField, equals: fieldToFocus)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .textInputAutocapitalization(fieldToFocus == .email ? .none : .words)
            .autocorrectionDisabled(true)
            .appOnTapGesture {
                self.focusedField = fieldToFocus
            }
        
    }
    
    private func handleOnSubmit() {
        
        var nextFocusedField: FocusedField? = nil
        
        switch self.focusedField {
        case .name: nextFocusedField = .email
        case .email: nextFocusedField = .phone
        default: nextFocusedField = nil
        }
        
        self.focusedField = nextFocusedField
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if self.focusedField == nil {
            
            CommonButton(
                title: "Save",
                isEnabled: self.viewModel.isSubmitButtonEnabled
            ) {
                self.viewModel.createOrUpdate()
            }
            .padding(.top, .small)
            .padding(.horizontal, .medium)
            .transition(.move(edge: .bottom)
                .combined(with: .opacity)
                .animation(.bouncy(duration: 0.3))
            )
            .background(Style.shared.background(.primary).source())
            
        }
        
    }
    
    @ViewBuilder
    private func stateDropDown() -> some View {
                
        VStack(spacing: Style.shared.spacing(.custom(8))) {
            
            Text("State")
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CommonDropDownMenu(
                options: Constants.USState.allCases,
                buttonHeight: 44.5,
                maxItemDisplayed: 3,
                backgroundStyle: .color(.minimumOpacity),
                shadow: .none,
                textHorizontalPadding: .small,
                shouldPushContentDown: true,
                animation: .spring,
                selectedOption: self.$selectedState,
                showDropDown: self.$isStateDropDownPresented
            )
            .appBorder(
                cornerRadius: .custom(6),
                color: Style.shared.background(.quaternary),
                lineWidth: 1
            )
            
        }
        .padding(.top, .small)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessCreateEditViewModel.self)
        .setup(businessId: MockModels.ID.business1)
    
    BusinessCreateEditScreen(viewModel: viewModel)
        .withMockServices()
    
}
