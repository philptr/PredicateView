//
//  BindableView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/21/24.
//

import SwiftUI

/// A view capable of being instantiated with a binding to a value.
public protocol BindableView<Value>: View {
    associatedtype Value
    
    init(value binding: Binding<Value>)
}
