//
//  FAQItemView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/13/25.
//

import SwiftUI

public struct FAQItemView: View {
    
    @State private var isExpanded: Bool = false
    
    private let question: String
    private let answer: String
    private let icon: String
    
    public init(question: String,
                answer: String,
                icon: String = "questionmark.circle.fill") {
        
        self.question = question
        self.answer = answer
        self.icon = icon
        
    }
    
    public var body: some View {
        
        CollapsibleView(isExpanded: $isExpanded, backgroundColor: .background(.primary)) {
            collapsedView()
        } expandedView: {
            expandedView()
        }
        .animation(.snappy, value: self.isExpanded)
        
    }
    
    private func collapsedView() -> some View {
        
        VStack {
            
            HStack {
                
                Text(self.question)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(.text(.title))
                
                Spacer(minLength: 0)
                Image(systemName: "plus")
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
                
            }
            
            Divider()
                .background(.background(.border))
                .frame(maxWidth: .infinity)
                .frame(height: 1)
            
        }
        .foregroundStyle(.text(.title))
        .compositingGroup()
        
    }
    
    
    private func expandedView() -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(self.answer)
                .appFont(with: .BODY_2)
                .foregroundStyle(.text(.body))
                .fixedSize(horizontal: false, vertical: true)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .compositingGroup()
        
    }
    
}

#Preview {
    
    let question = "What is the first day of the year?"
    let answer = """
    The first day of the year is Janurary First. It has special meaning in the calendar as the first day of the yearThe first day of the year is Janurary First. It has special meaning in the calendar as the first day of the yearThe first day of the year is Janurary First. It has special meaning in the calendar as the first day of the year The first day of the year is Janurary First. It has special meaning in the calendar as the first day of the year The first day of the year is Janurary First. It has special meaning in the calendar as the first day of the year
    """
    
    AppBaseView {
        
        VStack(spacing: 8) {
            
            FAQItemView(question: question, answer: answer)
            FAQItemView(question: question, answer: answer)
            FAQItemView(question: question, answer: answer)
            FAQItemView(question: question, answer: answer)
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}
