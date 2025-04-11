//
//  CollapsableCardView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 10/22/24.
//

import SwiftUI

struct CollapsableCardView<CollapsedView: View, ExpandedView: View>: View {

    private let verticalPadding: CustomTheme.SpacingKey
    private let horizontalPadding: CustomTheme.SpacingKey
    private let backgroundColor: ColorSource
    private let cornerRadius: CustomTheme.RadiusKey
    private let chevronColor: Color
    private let shouldShowChevron: Bool
    private let collapsedView: CollapsedView
    private let expandedView: ExpandedView

    @State private var isExpandedState: Bool = false
    private var isExpandedBinding: Binding<Bool>?

    private var isExpanded: Binding<Bool> {
        if let binding = isExpandedBinding {
            return binding
        } else {
            return $isExpandedState
        }
    }

    public init(
        isExpanded: Binding<Bool>? = nil,
        verticalPadding: CustomTheme.SpacingKey = .medium,
        horizontalPadding: CustomTheme.SpacingKey = .medium,
        backgroundColor: ColorSource = DesignSystem.shared.background(.secondary),
        cornerRadius: CustomTheme.RadiusKey = .small2,
        chevronColor: Color = Color(uiColor: .lightGray),
        shouldShowChevron: Bool = true,
        @ViewBuilder collapsedView: () -> CollapsedView,
        @ViewBuilder expandedView: () -> ExpandedView
    ) {

        self.isExpandedBinding = isExpanded
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.chevronColor = chevronColor
        self.shouldShowChevron = shouldShowChevron
        self.collapsedView = collapsedView()
        self.expandedView = expandedView()
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            HStack(spacing: 0) {

                self.collapsedView
                    .padding(.vertical, self.verticalPadding)

                if self.shouldShowChevron {

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .foregroundStyle(self.chevronColor)
                        .rotationEffect(.degrees(self.isExpanded.wrappedValue ? 90 : 0))
                        .animation(.bouncy, value: self.isExpanded.wrappedValue)
                    
                }

            }
            .padding(.horizontal, self.horizontalPadding)
            .background(.backgroundTappable)
            .background(self.backgroundColor.source())

            if self.isExpanded.wrappedValue {

                self.expandedView
                    .transition(.opacity)
                    .zIndex(-1000)
                
            }

        }
        .background(self.backgroundColor.source())
        .cornerRadius(self.cornerRadius)
        .clipShape(.rect(cornerRadius: DesignSystem.shared.radius(self.cornerRadius)))
        .appShadow()
        .asButton {
            self.toggleExpansion()
        }

    }

    private func toggleExpansion() {

        withAnimation(.bouncy) {
            self.isExpanded.wrappedValue.toggle()
        }

    }

}

#Preview {
    
    CollapsableCardView() {
        
        HStack {
            
            Label("Person", systemImage: "person.fill")
            Spacer(minLength: 0)
            
        }
        .foregroundStyle(DesignSystem.shared.accent.source())
        
    } expandedView: {
        
        VStack(alignment: .leading) {
            
            Text("Expanded content goes here.")
            
            Rectangle()
                .fill(.black)
            
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, .medium)
        .padding(.horizontal, .medium)
        .foregroundStyle(DesignSystem.shared.accent.source())
        .frame(maxHeight: 100)
        
    }
    .padding(.horizontal, 32)
    
}

#Preview {
    
    @Previewable @State var isExpanded: Bool = false
    
    VStack {
        
        CollapsableCardView(isExpanded: $isExpanded) {
            
            HStack {
                
                Label("When Did You Get Paid?", systemImage: "person.fill")
                Spacer(minLength: 0)
                
            }
            .foregroundStyle(DesignSystem.shared.accent.source())
            
        } expandedView: {
            
            VStack(alignment: .leading) {
                
                Text("Expanded content goes here.")
                
                Rectangle()
                    .fill(.black)
                
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, .medium)
            .padding(.horizontal, .medium)
            .foregroundStyle(DesignSystem.shared.accent.source())
            .frame(maxHeight: 100)
            
        }
        .padding(.horizontal, 32)
        
    }
    .safeAreaInset(edge: .bottom) {
        
        CommonButton(title: "Toggle") {
            
            withAnimation {
                isExpanded.toggle()
            }
            
        }
        .frame(width: 120)
        
    }
    
}
