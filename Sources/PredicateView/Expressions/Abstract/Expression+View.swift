//
//  Expression+View.swift
//
//
//  Created by Phil Zakharchenko on 4/20/24.
//

import SwiftUI

extension Expression {
    @ViewBuilder
    public static func operatorPickerView<T: Hashable>(
        using operation: Binding<T>
    ) -> some View {
        operatorPickerView(using: operation) { option in
            Text(option.rawValue)
                .tag(option as! T)
        }
    }
    
    @ViewBuilder
    public static func operatorPickerView<T: Hashable>(
        using operation: Binding<T>,
        @ViewBuilder itemProvider: @escaping (Operator) -> some View
    ) -> some View {
        Picker("Operator", selection: operation) {
            ForEach(Operator.allCases, id: \.self) { option in
                itemProvider(option)
                    .pickerStyle(.menu)
            }
        }
        .pickerStyle(.inline)
    }
    
    public static func makeView(for expression: Binding<Self>) -> some ExpressionView {
        makeView(for: expression, parent: nil)
    }
    
    public static func makeView(for expression: Binding<Self>, parent: Binding<LogicalExpression<Root>>?) -> some ExpressionView {
        ExprView(expression: expression, parent: parent)
    }
}
