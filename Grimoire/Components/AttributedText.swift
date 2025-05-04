//
//  AttributedTextBuilder.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/12/25.
//

import SwiftUI

@resultBuilder
struct AttributedTextBuilder {
    
    static func buildBlock(_ components: Text...) -> Text {
        components.reduce(Text(""), { $0 + $1 })
    }
    
}

struct AttributedText: View {
    
    private let content: Text

    /// Initializes an `AttributedText` view using the provided builder closure.
    /// - Parameter content: A closure returning a composed `Text` using the `AttributedTextBuilder`.
    init(@AttributedTextBuilder content: () -> Text) {
        self.content = content()
    }
    
    var body: some View {
        content
    }
    
}

#Preview {
    
    AttributedText {
        
        Text("You have ")
        
        Text("$9000.00")
            .foregroundColor(.red)
            .fontWeight(.bold)
            .underline()
        
        Text(" left in your checking account")
        
    }
    
}
