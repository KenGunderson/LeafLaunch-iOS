//
//  ViewModel.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import Foundation

typealias ViewModelDefinition = (AnyObject & Identifiable & Hashable & Trackable & Loggable)

protocol ViewModel: ViewModelDefinition, ObservableObject {}

extension ViewModel {
    
  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs === rhs
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
    
}
