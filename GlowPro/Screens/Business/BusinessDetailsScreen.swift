//
//  BusinessDetailsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import SwiftUI

struct BusinessEditDetailsScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case businessName
        case email
        case phone
        case street
        case street2
        case city
        case state
        case zip
        
        var displayName: String {
            switch self {
            case .businessName: return "Business Name"
            case .email: return "Email"
            case .phone: return "Phone"
            case .street: return "Street"
            case .street2: return "Street 2"
            case .city: return "City"
            case .state: return "State"
            case .zip: return "Zip"
            }
        }
        
    }
    
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessDetailsViewModel
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        
        content()
        
        // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            .onAppear {
                
                self.tabBarNavigationService
                    .shouldShowTabBar(false)
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(backgroundStyle: Style.shared.background(.primary)) {
            navBar()
        } scrollViewContent: {
            contentView()
        }
        
    }
    
    private func navBar() -> some View {
        
        let backButton = BackButton(backgroundColor: .color(.clear)) {
            self.dismiss()
        }
            .asAnyView()
        
        return NavBarView(
            title: "Your Business",
            leftButtonView: backButton
        )
        
    }
    
    private func contentView() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.extraLarge)) {
            
            // TextFields
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                sectionTitle("General Information")
                
                textField(fieldToFocus: .businessName)
                textField(fieldToFocus: .email)
                textField(fieldToFocus: .phone)
                
            }
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                sectionTitle("Business Address")
                
                textField(fieldToFocus: .street)
                textField(fieldToFocus: .street2)
                textField(fieldToFocus: .city)
                
                HStack {
                    
                    textField(fieldToFocus: .state)
                    textField(fieldToFocus: .zip)
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        
        Text(title)
            .foregroundStyle(Style.shared.textColor(.title).source())
            .appFont(with: .TITLE_T8)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        
    }
    
    private func textField(fieldToFocus: FocusedField) -> some View {
        
        var text: Binding<String> = .constant("")
        var isFocused: Bool = false
        var keyboardType: UIKeyboardType = .default
        var textContentType: UITextContentType = .organizationName
        
        let placeholder: String = fieldToFocus.displayName
        
        switch fieldToFocus {
        case .businessName:
            
            text = self.$viewModel.name
            isFocused = self.focusedField == .businessName
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
            
        case .state:
            
            text = self.$viewModel.state
            isFocused = self.focusedField == .state
            keyboardType = .default
            textContentType = .addressState
            
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
                style: .border(),
                isFocused: isFocused
            )
            .focused(self.$focusedField, equals: fieldToFocus)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .submitLabel(.done)
            .textInputAutocapitalization(.words)
            .appOnTapGesture {
                self.focusedField = fieldToFocus
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessDetailsViewModel.self)
        .setup(businessId: "123")
    
    BusinessEditDetailsScreen(viewModel: viewModel)
        .withMockServices()
    
}
