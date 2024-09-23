//
//  OptionalExpression.swift
//  
//
//  Created by Phil Zakharchenko on 4/20/24.
//

import SwiftUI

struct OptionalExpression<Root, WrappedExpression>: ExpressionWrapper where WrappedExpression: ContentExpression<Root> & WrappablePredicateExpression {
    typealias ExprView = OptionalExpressionView<Root, WrappedExpression>
    
    enum Operator: String, ExpressionOperator {
        case exists = "exists"
        case doesNotExist = "has no value"
        
        var exists: Bool { self == .exists }
    }
    
    var id = UUID()
    let keyPath: KeyPath<Root, WrappedExpression.Value?>
    var title: String
    var attribute: WrappedExpression.Attribute? = WrappedExpression.defaultAttribute
    var `operator`: Operator = .exists {
        willSet { attribute = nil }
    }
    
    static func buildPredicate<V>(
        for variable: V,
        using wrappedAttribute: WrappedExpression.Attribute?,
        operator: Operator
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value> {
        func nilCoalesced<T: StandardPredicateExpression<Bool>>(
            expression: T
        ) -> any StandardPredicateExpression<Bool> where T.Output == Bool {
            PredicateExpressions.NilCoalesce(
                lhs: PredicateExpressions.OptionalFlatMap(variable) { _ in expression },
                rhs: PredicateExpressions.Value(false)
            )
        }
        
        switch `operator` {
        case .exists:
            let forceUnwrapped = PredicateExpressions.ForcedUnwrap(variable)
            guard let wrappedAttribute,
                  let expression = WrappedExpression.buildPredicate(for: forceUnwrapped, using: wrappedAttribute) else {
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
    
    public func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> (any Expression<Root>)? {
        // TODO: Needs implementation.
        nil
    }
}

struct OptionalExpressionView<Root, WrappedExpression>: ExpressionView where WrappedExpression: ContentExpression<Root> & WrappablePredicateExpression {
    typealias Expression = OptionalExpression<Root, WrappedExpression>
    
    var expression: Binding<Expression>
    
    var body: some View {
        @Binding(projectedValue: expression) var expression
        
        TokenView(Root.self, header: {
            if expression.operator.exists, let attr = expression.attribute {
                Text("\(expression.title) \(attr.operator.rawValue)")
            } else {
                Text(expression.title)
            }
        }, content: {
            if expression.operator.exists, let attr = expression.attribute {
                WrappedExpression.makeContentView(.init(get: {
                    attr.value
                }, set: {
                    expression.attribute?.value = $0
                }))
            } else {
                Text(expression.operator.rawValue)
            }
        }, menu: {
            Expression.makeOperatorMenu(using: $expression.operator) { option in
                if option.exists {
                    VStack {
                        Button(option.rawValue) { }
                        
                        WrappedExpression.makeOperatorMenu(using: .init(get: {
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
