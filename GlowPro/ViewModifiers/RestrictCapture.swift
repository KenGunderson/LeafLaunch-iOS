//
//  RestrictCapture.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/1/25.
//

import UIKit
import SwiftUI

final class ViewController: UIViewController {
    
    private let rootView: UIView = .init()
    
    override func loadView() {
        self.view = .secureView
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.rootView.backgroundColor = .red
        
        self.view.addSubview(self.rootView)
        self.rootView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.rootView.topAnchor.constraint(equalTo: view.topAnchor),
            self.rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
}

struct RestrictCaptureView<Content: View>: UIViewRepresentable {
    
    private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    func makeUIView(context: Context) -> UIView {
        
        let secureView: UIView = .secureView
        
        let hostingController = UIHostingController(rootView: content())
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        secureView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: secureView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: secureView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: secureView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: secureView.trailingAnchor)
        ])
        
        return secureView
        
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
}

extension View {

    @ViewBuilder
    func restrictCapture(_ restrict: Bool = true) -> some View {
        
        if restrict {
            RestrictCaptureView { self }
        } else {
            self
        }
        
    }
    
}

extension UIView {
    
    static var secureView: UIView {
        
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = false
        
        guard let secureView = textField.layer.sublayers?.first?.delegate as? UIView else {
            return .init()
        }
        
        secureView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        return secureView
        
    }
    
}
