//
//  OptionalExpression.swift
//  
//
//  Created by Phil Zakharchenko on 4/20/24.
//

import SwiftUI

struct OptionalExpression<Root, WrappedExpression>: ExpressionWrapper where WrappedExpression: ContentExpression<Root> {
    typealias ExprView = OptionalExpressionView<Root, WrappedExpression>
    
    enum Operator: String, CaseIterable {
        case exists = "exists"
        case doesNotExist = "has no value"
        
        var usesWrappedValue: Bool {
            switch self {
            case .exists: true
            case .doesNotExist: false
            }
        }
    }
    
    var id = UUID()
    let keyPath: KeyPath<Root, WrappedExpression.Value?>
    var title: String
    var attribute: ExpressionAttribute<WrappedExpression>? = WrappedExpression.defaultAttribute
    var `operator`: Operator = .exists {
        willSet { attribute = nil }
    }
    
    static func buildPredicate<V>(
        for variable: V,
        using value: WrappedExpression.Value?,
        wrappedOperation: WrappedExpression.Operator?,
        operation: Operator
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value> {
        func nilCoalesced<T: StandardPredicateExpression<Bool>>(
            expression: T
        ) -> any StandardPredicateExpression<Bool> where T.Output == Bool {
            PredicateExpressions.NilCoalesce(
                lhs: PredicateExpressions.OptionalFlatMap(variable) { _ in expression },
                rhs: PredicateExpressions.Value(false)
            )
        }
        
        switch operation {
        case .exists:
            let forceUnwrapped = PredicateExpressions.ForcedUnwrap(variable)
            guard let value,
                  let wrappedOperation,
                  let expression = WrappedExpression.buildPredicate(for: forceUnwrapped, using: value, operation: wrappedOperation) else {
                return PredicateExpressions.NotEqual(
                    lhs: variable,
                    rhs: PredicateExpressions.NilLiteral()
                )
            }
            
            return nilCoalesced(expression: expression)
        case .doesNotExist:
            return PredicateExpressions.Equal(
                lhs: variable,
                rhs: PredicateExpressions.NilLiteral()
            )
        }
    }
}

struct OptionalExpressionView<Root, WrappedExpression: ContentExpression<Root>>: ExpressionView {
    typealias Expression = OptionalExpression<Root, WrappedExpression>
    
    var expression: Binding<Expression>
    
    var body: some View {
        @Binding(projectedValue: expression) var expression
        
        TokenView(Root.self, header: {
            if expression.operator.usesWrappedValue, let attr = expression.attribute {
                Text("\(expression.title) \(attr.operator.rawValue)")
            } else {
                Text(expression.title)
            }
        }, content: {
            if expression.operator.usesWrappedValue, let attr = expression.attribute {
                WrappedExpression.makeContentView(.init(get: {
                    attr.value
                }, set: {
                    expression.attribute?.value = $0
                }))
            } else {
                Text(expression.operator.rawValue)
            }
        }, menu: {
            Expression.operatorPickerView(using: $expression.operator) { option in
                if option.usesWrappedValue {
                    VStack {
                        Button(option.rawValue) { }
                        
                        WrappedExpression.operatorPickerView(using: .init(get: {
                            expression.attribute?.operator
                        }, set: { newValue in
                            guard let newValue else { return }
                            
                            expression.operator = option
                            if expression.attribute == nil {
                                expression.attribute = WrappedExpression.defaultAttribute
                            }
                            
                            expression.attribute?.operator = newValue
                        }))
                    }
                } else {
                    Text(option.rawValue)
                        .tag(option)
                }
            }
        })
    }
}

