//
//  CustomExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/21/24.
//

import CompoundPredicate
import SwiftUI

extension AnyExpression {
    public init<CustomView>(_ view: CustomView.Type = CustomView.self) where CustomView: CustomExpressionView, Root == CustomView.Root, CustomView.Value: Sendable {
        self.init(wrappedValue: CustomExpression<Root, CustomView>())
    }
}

// MARK: - CustomExpression

struct CustomExpression<Root, Content>: ContentExpression, KeyPathExpression where Content: CustomExpressionView, Root == Content.Root, Content.Value: Sendable {
    typealias AttributeValue = Content.Value
    typealias Operator = Content.Operator
    
    static var defaultAttribute: StandardAttribute<Self> {
        .init(operator: Content.Operator.allCases.first!, value: Content.defaultValue)
    }
    
    var id = UUID()
    var title: String { Content.title }
    var keyPath: KeyPath<Root, Content.Value> { Content.keyPath }
    var attribute: StandardAttribute<Self> = Self.defaultAttribute
    
    public func buildPredicate(
        using input: PredicateExpressions.Variable<Root>
    ) -> (any StandardPredicateExpression<Bool>)? {
        let predicate = Content.predicate(for: attribute.value, operator: attribute.operator)
        guard let compatibleExpression = predicate.expression as? any VariableReplacing else { return nil }
        return compatibleExpression.replacing(predicate.variable, with: input) as? any StandardPredicateExpression<Bool>
    }

    static func makeContentView(_ value: Binding<AttributeValue>) -> some View {
        Content(value: value)
    }
    
    public func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> (any ExpressionProtocol<Root>)? {
        guard let result = Content.decode(expression) else { return nil }
        return populateFromDecodedExpression(
            ifKeyPathMatches: result.keyPathExpression,
            attribute: .init(operator: result.operator, value: result.value)
        )
    }
}
