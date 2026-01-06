//
//  RestrictCapture.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 11/1/25.
//

import UIKit
import SwiftUI

struct RestrictCaptureView<Content: View>: UIViewControllerRepresentable {
    
    private let colorScheme: ColorScheme?
    private let statusBarStyle: UIUserInterfaceStyle
    private let content: () -> Content
    
    init(colorScheme: ColorScheme? = nil,
         statusBarStyle: UIUserInterfaceStyle,
         @ViewBuilder content: @escaping () -> Content) {
        
        self.colorScheme = colorScheme
        self.statusBarStyle = statusBarStyle
        self.content = content
        
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        
        let root = AnyView(
            
            self.content()
                .preferredColorScheme(self.colorScheme)
            
        )
        
        let controller = ViewController(
            colorScheme: self.colorScheme,
            statusBarStyle: self.statusBarStyle,
            rootView: root
        )
        
        return controller
        
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        
        // If needed later, you can add a method on ViewController to update
        // uiViewController.hostingController.rootView here.
        
    }
    
}

final class ViewController: UIViewController {
    
    private let colorScheme: ColorScheme?
    private let statusBarStyle: UIUserInterfaceStyle
    private let rootView: UIView = .init()
    private let hostingController: UIHostingController<AnyView>
    
    init(colorScheme: ColorScheme?,
         statusBarStyle: UIUserInterfaceStyle,
         rootView: AnyView) {
        
        self.colorScheme = colorScheme
        self.statusBarStyle = statusBarStyle
        self.hostingController = UIHostingController(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func loadView() {
        
        self.view = .secureView
        self.view.overrideUserInterfaceStyle = self.statusBarStyle
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        self.rootView.backgroundColor = .clear
        
        self.view.addSubview(self.rootView)
        self.rootView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.rootView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.rootView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.rootView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.rootView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        // hostingController.view fills rootView
        self.addChild(self.hostingController)
        self.rootView.addSubview(self.hostingController.view)
        self.hostingController.didMove(toParent: self)
        
        self.hostingController.view.backgroundColor = .clear
        self.hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.hostingController.overrideUserInterfaceStyle = .unspecified
        
        NSLayoutConstraint.activate([
            self.hostingController.view.topAnchor.constraint(equalTo: self.rootView.topAnchor),
            self.hostingController.view.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor),
            self.hostingController.view.leadingAnchor.constraint(equalTo: self.rootView.leadingAnchor),
            self.hostingController.view.trailingAnchor.constraint(equalTo: self.rootView.trailingAnchor)
        ])
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
}

// MARK: - View Modifier (same API)

public extension View {
    
    @ViewBuilder
    func restrictCapture(_ restrict: Bool = true,
                         colorScheme: ColorScheme? = .light,
                         statusBarStyle: UIUserInterfaceStyle = .light) -> some View {
        
        if restrict {
            
            ZStack {
                
                Color.clear.ignoresSafeArea()
                    .preferredColorScheme(colorScheme)
                
                RestrictCaptureView(
                    colorScheme: colorScheme,
                    statusBarStyle: statusBarStyle
                ) {
                    self.preferredColorScheme(.light)
                }
                .preferredColorScheme(colorScheme)
                
            }
            .ignoresSafeArea()
            .preferredColorScheme(colorScheme)
            
        } else {
            self
        }
        
    }
    
}

// MARK: - Secure UIView Factory

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
        
        secureView.overrideUserInterfaceStyle = .dark
        secureView.backgroundColor = .black
        
        return secureView
        
    }
    
}
