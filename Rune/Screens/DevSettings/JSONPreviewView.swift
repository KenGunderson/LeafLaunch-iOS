//
//  JSONPreviewView.swift
//  Rune2
//
//  Created by Sako Hovaguimian on 5/3/25.
//

import SwiftUI

struct JSONPreviewView: View {
    
    let jsonData: [String: Any]
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 8) {
                
                JSONNodeView(json: jsonData, indentLevel: 0)
                
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding()
            
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .frame(minHeight: 80)
        .frame(maxHeight: 400)
        .background(Style.shared.background(.tertiary).source())
        .clipShape(.rect(cornerRadius: Style.shared.radius(.medium)))
        
    }
    
}

struct JSONNodeView: View {
    
    let json: Any
    let indentLevel: Int
    
    var body: some View {
        
        Group {
            
            if let dictionary = json as? [String: Any] {
                
                ForEach(dictionary.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("\(key):")
                            .font(.headline)
                            .foregroundColor(colorForLevel(indentLevel))
                            .padding(.leading, CGFloat(indentLevel * 20))
                        
                        JSONNodeView(json: value, indentLevel: indentLevel + 1)
                        
                    }
                    
                }
                
            } else if let array = json as? [Any] {
                
                ForEach(Array(array.enumerated()), id: \.offset) { index, element in
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("[\(index)]:")
                            .font(.subheadline)
                            .foregroundColor(colorForLevel(indentLevel))
                            .padding(.leading, CGFloat(indentLevel * 20))
                        
                        JSONNodeView(json: element, indentLevel: indentLevel + 1)
                        
                    }
                    
                }
                
            } else if let string = json as? String {
                
                Text("\"\(string)\"")
                    .font(.body)
                    .foregroundColor(colorForLevel(indentLevel))
                    .padding(.leading, CGFloat(indentLevel * 20))
                
            } else if let number = json as? NSNumber {
                
                Text("\(number)")
                    .font(.body)
                    .foregroundColor(colorForLevel(indentLevel))
                    .padding(.leading, CGFloat(indentLevel * 20))
                
            } else {
                
                Text("\(String(describing: json))")
                    .font(.body)
                    .foregroundColor(colorForLevel(indentLevel))
                    .padding(.leading, CGFloat(indentLevel * 20))
                
            }
            
        }
        .fontDesign(.monospaced)
        
    }
    
    func colorForLevel(_ level: Int) -> Color {
        
        let colors: [Color] = [
            Color(hex: "#1F77B4"), // Level 0 - Blue
            Color(hex: "#9467BD"), // Level 1 - Purple
            Color(hex: "#2CA02C"), // Level 2 - Green
            Color(hex: "#D62728"), // Level 3 - Red
            Color(hex: "#FF7F0E"), // Level 4 - Orange
            Color(hex: "#8C564B"), // Level 5 - Brown
            Color(hex: "#E377C2"), // Level 6 - Pink
            Color(hex: "#7F7F7F")  // Level 7 - Gray
        ]
        
        return colors[level % colors.count]
        
    }
    
}

#Preview {
    
    let sampleJSON: [String: Any] = [
        "impersonatedUser": [
            "email": "michael@example.com",
            "gender": "male",
            "external_id": 1,
            "image_url": "https://fastly.picsum.photos/id/580/200/300.jpg?hmac=ETV-og2PgiTBmJBERthfeRRRuLpWGxM4Zq_3z8pXndA",
            "name": "Other User",
            "id": 1
        ],
        "originalUser": [
            "email": "sako@me.com",
            "gender": "male",
            "external_id": 1,
            "image_url": "https://fastly.picsum.photos/id/580/200/300.jpg?hmac=ETV-og2PgiTBmJBERthfeRRRuLpWGxM4Zq_3z8pXndA",
            "name": "Sako",
            "id": 1
        ]
    ]
    
    AppCardView {
        
        JSONPreviewView(jsonData: sampleJSON)
        
    }
    .padding(.horizontal, .large)
    
}
