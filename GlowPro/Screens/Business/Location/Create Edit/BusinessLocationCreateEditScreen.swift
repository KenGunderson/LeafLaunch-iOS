//
//  BusinessLocationCreateEditScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/9/25.
//

import SwiftUI

struct BusinessLocationCreateEditScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case name
        case street
        case street2
        case city
        case zip
        
        var displayName: String {
            switch self {
            case .name: return "Location Name"
            case .street: return "Street"
            case .street2: return "Street 2"
            case .city: return "City"
            case .zip: return "Zip"
            }
        }
        
    }
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessLocationCreateEditViewModel
    
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
            .animation(.spring, value: self.viewModel.selectedState)
        
        // Tap
        
            .onTapGesture {
                
                self.focusedField = nil
                self.isStateDropDownPresented = false
                
            }
        
        // OnChange
        
            .onChange(of: self.selectedState) { oldValue, newValue in
                
                if newValue != self.viewModel.selectedState {
                    
                    self.viewModel
                        .set(state: newValue)
                    
                }
                
            }
        
            .onChange(of: self.viewModel.selectedState) { oldValue, newValue in
                
                if newValue != self.selectedState {
                    selectedState = newValue
                }
                
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
        
        let trashButton = NavBarButton(style: .trash) {
            
            self.viewModel
                .presentDeleteLocationAlert()
            
        }
        .asAnyView()
        
        let shouldShowTrashButton = self.viewModel.isEditMode && self.viewModel.isOwner
        
        return NavBarView(
            title: self.viewModel.navTitle,
            leftButtonView: backButton,
            rightButtonView: shouldShowTrashButton ? trashButton : nil
        )
        
    }
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.large)) {
            
            businessGeneralInformation()
            businessAddress()
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func businessGeneralInformation() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "General Information")
            
            AppCardView {
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    textField(fieldToFocus: .name)
                }
                
            }
            
        }
        
    }
    
    private func businessAddress() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Business Address")
            
            AppCardView {
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    textField(fieldToFocus: .street)
                    textField(fieldToFocus: .street2)
                    textField(fieldToFocus: .city)
                    
                    HStack(alignment: self.isStateDropDownPresented ? .top : .bottom) {
                        
                        stateDropDown()
                        
                        textField(fieldToFocus: .zip)
                            .padding(.top, self.isStateDropDownPresented ? 9.5 : 0)
                        
                    }
                    
                }
                
            }
            
        }
        
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

        case .street:
            
            text = self.$viewModel.street
            isFocused = self.focusedField == .street
            keyboardType = .default
            textContentType = .streetAddressLine1
            
        case .street2:
            
            text = self.$viewModel.street2
            isFocused = self.focusedField == .street2
            keyboardType = .default
            textContentType = .streetAddressLine2
            
        case .city:
            
            text = self.$viewModel.city
            isFocused = self.focusedField == .city
            keyboardType = .default
            textContentType = .addressCity

        case .zip:
            
            text = self.$viewModel.zip
            isFocused = self.focusedField == .zip
            keyboardType = .default
            textContentType = .postalCode
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
            .submitLabel(.done)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .appOnTapGesture {
                self.focusedField = fieldToFocus
            }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if self.focusedField == nil {
            
            CommonButton(title: self.viewModel.saveButtonTitle,
                         isEnabled: self.viewModel.isSaveButtonEnabled) {
                
                self.viewModel
                    .saveOrUpdate()
                
            }
            .padding(.top, .small)
            .padding(.horizontal, .medium)
            .transition(.move(edge: .bottom)
                .combined(with: .opacity)
                .animation(.smooth(duration: 0.3))
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
    
    let viewModel = mockResolve(BusinessLocationCreateEditViewModel.self)
        .setup(
            businessId: MockModels.ID.business1,
            locationId: MockModels.ID.location1
        )
    
    BusinessLocationCreateEditScreen(viewModel: viewModel)
        .withMockServices()
    
}
