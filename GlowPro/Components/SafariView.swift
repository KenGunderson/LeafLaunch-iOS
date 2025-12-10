//
//  SafariView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/9/25.
//

import SwiftUI
import WebKit
import SafariServices

struct SafariView: UIViewRepresentable {

    let url: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView(frame: .zero)
    }

    func updateUIView(_ view: WKWebView,
                      context: Context) {
        
        if let url = URL(string: url) {
            
            let request = URLRequest(url: url)
            view.load(request)
            
        }
        
    }
    
}
