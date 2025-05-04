//
//  AlertTextFieldView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/10/23.
//

import SwiftUI

struct AlertTextFieldView: View {
    
    enum FocusedField: Hashable {
        case email
    }
    
    @Binding var isPresented: Bool
    
    let alert: AppAlertConfig
    
    @State var text: String = ""
    @FocusState private var focusedField: FocusedField?
    
    var tintColor: ColorSource = Style.shared.accent
    
    var isButtonEnabled: Bool {
        return self.text.count > 4
    }

    var action: ((String) -> ())
    let dismissAction: (() -> ())?
    
    init(alert: AppAlertConfig,
         initialText: String? = nil,
         isPresented: Binding<Bool>,
         action: @escaping ((String) -> ()),
         dismissAction: (() -> ())? = nil) {
        
        self.alert = alert
        self._text = .init(initialValue: initialText ?? "")
        self.action = action
        self._isPresented = isPresented
        self.dismissAction = dismissAction
        
    }
    
    init(alert: AppAlertConfig,
         initialText: String? = nil,
         action: @escaping ((String) -> ()),
         dismissAction: @escaping (() -> ())) {
        
        self.alert = alert
        self._text = .init(initialValue: initialText ?? "")
        self.action = action
        self._isPresented = .constant(true)
        self.dismissAction = dismissAction
        
    }
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            Group {
                
                HStack {
                    
                    CircularIconView(
                        foregroundColor: .color(.black),
                        size: Style.shared.spacing(.extraLarge),
                        imageSource: .systemImage("xmark")
                    )
                    .appOnTapGesture {
                        self.dismissAction?()
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Group {
                    
                    Text(self.alert.title)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .multilineTextAlignment(.center)
                        .appFont(with: .TITLE_T10)
                    
                    if let message = self.alert.message {
                        
                        Text(message)
                            .foregroundStyle(Style.shared.textColor(.body).source())
                            .multilineTextAlignment(.center)
                            .appFont(with: .BODY_B5)
                        
                    }
                    
                }
                
                TextField(
                    "Email",
                    text: self.$text,
                    prompt: Text("Email").foregroundStyle(.blackedGray)
                )
                .appTextFieldStyle(
                    text: self.text,
                    hint: "Email",
                    isFocused: self.focusedField == .email,
                    borderColor: self.tintColor
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .onSubmit({
                    self.action(self.text)
                })
                .focused(self.$focusedField, equals: .email)
                .padding(.top, Style.shared.spacing(.small))
                
                
            }
            .padding(.horizontal, 24)

            buttonStackView()
            
        }
        .padding(.top, 24)
        .background(Style.shared.background(.primary).source())
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 32)
        .appShadow(.card)
        
    }
    
    @ViewBuilder
    func button(title: String,
                color: ColorSource) -> some View {
        
        Text(title)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(self.isButtonEnabled ? color.source().opacity(1) : color.source().opacity(0.3))
            .foregroundStyle(self.alert.primaryButtonTextColor.source())
            .appFont(with: .TITLE_T5)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        
    }
    
    @ViewBuilder
    func buttonStackView() -> some View {
        
        HStack(spacing: 16) {
            
            Button(action: {
                
                self.isPresented = false
                self.action(self.text)
                self.dismissAction?()
                
            },
                   label: {
                self.button(
                    title: self.alert.primaryButtonTitle,
                    color: self.tintColor
                )
                .appShadow()
            })
            .disabled(!self.isButtonEnabled)
            
        }
        .padding(.top, 8)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        
    }
    
}

#Preview {
    
    ZStack {
        
        Color.black
            .ignoresSafeArea()
        
        AlertTextFieldView(
            alert: .init(
                title: "Some Facny Alert",
                message: "Some Super Fancy Message For The User",
                primaryButtonTitle: "Some Action",
                primaryButtonAction: {}
            ),
            isPresented: .constant(true)
        ) { text in
            print(text)
        }
        
    }

}

