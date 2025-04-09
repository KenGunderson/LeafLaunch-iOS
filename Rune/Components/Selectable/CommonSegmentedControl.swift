//
//  AppSegmentedControl.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/8/25.
//

import SwiftUI

struct CommonSegmentedControl<S: Selectable>: View {
    
    @Namespace private var selectionNamespace
    @Binding var selectedOption: S?
    var options: [S]
    
    var titleFont: AppFont = .title(.t4)
    var selectedTextColor: ColorSource = .color(ThemeManager.shared.textColor(.title))
    var unselectedTextColor: ColorSource = .color(ThemeManager.shared.textColor(.title))
    var foregroundStyle: ColorSource = .color(ThemeManager.shared.accentColor())
    var backgroundStyle: ColorSource = .color(ThemeManager.shared.background(.tertiary))
    
    var body: some View {
        
        Group {
        
            HStack(spacing: 0) {
                
                ForEach(options) { option in
                    
                    let isSelected = (self.selectedOption == option)
                    
                    Button(action: {
                        
                        withAnimation(.spring) {
                            self.selectedOption = option
                        }
                        
                    }, label: {
                        
                        Text(option.description)
                            .appFont(with: self.titleFont)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(isSelected ? self.selectedTextColor.source() : self.unselectedTextColor.source())
                        
                    })
                    .background {
                        
                        if isSelected {
                            
                            RoundedRectangle(cornerRadius: CornerRadius.extraSmall.value)
                            
                                .fill(self.foregroundStyle.source())
                                .padding(.vertical, 6)
                                .matchedGeometryEffect(id: "selection", in: self.selectionNamespace)
                            
                        }
                        
                    }
                    
                }
                
            }
            .padding(.horizontal, 6)
            
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.small.value)
                .fill(self.backgroundStyle.source())
        )
        .appShadow()
        
    }
    
}

fileprivate struct AppSegmentedControlTest: View {
    
    enum Pokemon: Selectable, CaseIterable {
        
        case charmander
        case bulbasaur
        
        var description: String {
            switch self {
            case .charmander: return "Charmander"
            case .bulbasaur: return "Bulbasaur"
            }
        }
        
        var id: String {
            return self.description
        }
        
    }
    
    @State private var selectedPokemon: Pokemon?
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack {
                
                CommonSegmentedControl(
                    selectedOption: self.$selectedPokemon,
                    options: Pokemon.allCases
                )
                
                Text("Seleted Pokemon: \(selectedPokemon?.description ?? "NO POKEMON")")
                    .contentTransition(.numericText())
                    .padding(.top, 24)
                
            }
            .padding(.horizontal, 16)
            .onAppear {
                self.selectedPokemon = Pokemon.charmander
            }
            
        }
        
    }
    
}

#Preview {
    
    AppSegmentedControlTest()
    
}

fileprivate struct AppSegmentedControlTest2: View {
    
    enum LoanType: Selectable, CaseIterable {
        
        case debt
        case creditCard
        case mortgage
        
        var description: String {
            switch self {
            case .debt: return "Debt"
            case .creditCard: return "Credit Card"
            case .mortgage: return "Mortgage"
            }
        }
        
        var id: String {
            return self.description
        }
        
    }
    
    @State private var selectedLoanType: LoanType?
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack {
                
                CommonSegmentedControl(
                    selectedOption: self.$selectedLoanType,
                    options: LoanType.allCases
                )
                
                Text("Seleted Loan Type: \(selectedLoanType?.description ?? "NO LOAN TYPE")")
                    .contentTransition(.numericText())
                    .padding(.top, 24)
                
            }
            .padding(.horizontal, 16)
            .onAppear {
                self.selectedLoanType = .creditCard
            }
            
        }
        
    }
    
}

#Preview {
    
    AppSegmentedControlTest2()
    
}
