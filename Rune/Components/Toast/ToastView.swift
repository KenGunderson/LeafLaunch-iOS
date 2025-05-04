//
//  ToastView.swift
//  Rival
//
//  Created by Sako Hovaguimian on 1/29/24.
//

import SwiftUI

enum ToastStyle {
    
    case standard
    case custom
    
}

struct CustomToastView: View {
    
    var size: CGSize
    var item: ToastItem
    
    @State private var delayTask: DispatchWorkItem?
    
    var body: some View {
        
        HStack(spacing: Style.shared.spacing(.none)) {
            
            if let image = item.image {
                
                image
                    .view()
                    .font(.title3)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 10)
                    .foregroundStyle(self.item.tint.source())
                
            }
            
            VStack(alignment: .leading) {
                
                Text(self.item.title)
                    .lineLimit(nil)
                    .appFont(with: .TITLE_T4)
                    .foregroundStyle(self.item.titleColor.source())
                
            }
            
        }
        
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Style.shared.background(.tertiary).source())
        .clipShape(.capsule)
        .appShadow()
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded({ value in
                    
                    guard self.item.isUserInteractionEnabled else { return }
                    
                    let endY = value.translation.height
                    let velocityY = value.velocity.height
                    
                    switch self.item.direction {
                    case .top:
                        
                        if (endY + velocityY) < 100 {
                            /// Removing Toast
                            removeToast()
                        }
                        
                    case .bottom:
                        
                        if (endY + velocityY) > 100 {
                            /// Removing Toast
                            removeToast()
                        }
                        
                    }
                    
                })
        )
        .onAppear {
            
            guard let timing = self.item.timing else { return }
            guard self.delayTask == nil else { return }
            
            self.delayTask = .init(block: {
                removeToast()
            })
            
            if let delayTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + timing.rawValue, execute: delayTask)
            }
            
        }
        
        /// Limiting Size
        .frame(maxWidth: self.size.width * 0.7)
        .transition(.offset(y: self.item.direction == .top ? -150 : 150))
        
    }
    
    func removeToast() {
        
        if let delayTask {
            delayTask.cancel()
        }
        
        withAnimation(.snappy) {
            ToastManager.shared.toasts.removeAll(where: { $0.id == self.item.id })
        }
        
    }
    
}

struct ToastView: View {
    
    var size: CGSize
    var item: ToastItem
    
    @State private var delayTask: DispatchWorkItem?
    
    var body: some View {
        
        HStack(spacing: Style.shared.spacing(.none)) {
            
            if let image = item.image {
                
                image
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 10)
                    .foregroundStyle(self.item.tint.source())
                
            }
            
            VStack(alignment: .leading) {
                
                Text(self.item.title)
                    .lineLimit(nil)
                    .appFont(with: .TITLE_T4)
                    .foregroundStyle(self.item.titleColor.source())
                
                if let message = self.item.message {
                    
                    Text(message)
                        .lineLimit(nil)
                        .foregroundStyle(self.item.messageColor.source())
                        .appFont(with: .BODY_B4)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
            }
            .allowsHitTesting(false)
            
        }
        
        .if(self.item.message != nil, transform: { view in
            view.frame(width: self.size.width * 0.8)
        })
        .padding(.horizontal, 16)
        .padding(.vertical, self.item.message == nil ? 8 : 16)
        
        .background(Style.shared.background(.tertiary).source())
        .clipShape(.rect(cornerRadius: self.item.message == nil ? 99 : Style.shared.radius(.small2)))
        .appShadow()
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded({ value in
                    
                    guard self.item.isUserInteractionEnabled else { return }
                    
                    let endY = value.translation.height
                    let velocityY = value.velocity.height
                    
                    switch self.item.direction {
                    case .top:
                        
                        if (endY + velocityY) < 100 {
                            /// Removing Toast
                            removeToast()
                        }
                        
                    case .bottom:
                        
                        if (endY + velocityY) > 100 {
                            /// Removing Toast
                            removeToast()
                        }
                        
                    }
                    
                })
        )
        .onAppear {
            
            guard let timing = self.item.timing else { return }
            guard self.delayTask == nil else { return }
            
            self.delayTask = .init(block: {
                removeToast()
            })
            
            if let delayTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + timing.rawValue, execute: delayTask)
            }
            
        }
        
        /// Limiting Size
        .frame(maxWidth: self.item.message == nil ? self.size.width * 0.7 : self.size.width * 0.8)
        .transition(.offset(y: self.item.direction == .top ? -150 : 150))
        
    }
    
    func removeToast() {
        
        if let delayTask {
            delayTask.cancel()
        }
        
        withAnimation(.snappy) {
            ToastManager.shared.toasts.removeAll(where: { $0.id == self.item.id })
        }
        
    }
    
}

#Preview {
    
    VStack {
        
        ToastView(size: .init(width: UIScreen.main.bounds.width - 32, height: 100), item: .init(
            title: "jsdklflksdjfj",
            titleColor: Style.shared.accent,
            message: "2383289238 90923908 23892 890 23 89  9329 8823 0823809",
            messageColor: Style.shared.textColor(.title),
            image: .systemImage("person.fill"),
            tint: Style.shared.accent,
            isUserInteractionEnabled: true,
            timing: nil
        ))
        
        ToastView(size: .init(width: UIScreen.main.bounds.width - 32, height: 100), item: .init(
            title: "jsdklflksdjfj",
            titleColor: Style.shared.accent,
            message: "2383289238 90923908 23892 890 23 89  9329 8823 0823809",
            messageColor: Style.shared.textColor(.title),
            image: .systemImage("person.fill"),
            tint: Style.shared.accent,
            isUserInteractionEnabled: true,
            timing: nil
        ))
        
    }
    
}
