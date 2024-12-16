//
//  PredicateExpressionConvertible.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/22/24.
//

import Foundation

/// Describes an ``Expression`` capable of both building a ``StandardPredicateExpression`` from
/// itself and decoding a provided ``PredicateExpression``.
public protocol PredicateExpressionConvertible<Root>: LeafPredicateExpressionDecoding {
    /// The type representing the attribute of this expression.
    associatedtype Attribute: ExpressionAttribute<Self>
    
    /// The type of the value associated with the attribute.
    associatedtype AttributeValue: Hashable & Sendable
    
    /// The default attribute for this expression type.
    static var defaultAttribute: Attribute { get }
    
    /// The current attribute of this expression instance.
    var attribute: Attribute { get set }
    
    /// Builds a predicate expression using the provided input variable.
    ///
    /// - Parameter input: A variable representing the root of the predicate.
    /// - Returns: An optional `StandardPredicateExpression<Bool>` representing the built predicate,
    ///   or `nil` if the predicate couldn't be built.
    func buildPredicate(
        using input: PredicateExpressions.Variable<Root>
    ) -> (any StandardPredicateExpression<Bool>)?
}

extension PredicateExpressionConvertible {
    /// A computed property that returns the current attribute as an `AnyHashable`.
    public var currentValue: AnyHashable {
        attribute
    }
}

extension PredicateExpressionConvertible where Self: KeyPathExpression {
    /// Attempts to populate the expression from a decoded key path expression.
    ///
    /// - Parameters:
    ///   - keyPathExpression: The decoded key path expression to match against.
    ///   - attribute: A closure that returns the attribute to set if the key path matches.
    /// - Returns: A new instance of `Self` with the updated attribute if the key path matches,
    ///   or `nil` if there's no match.
    func populateFromDecodedExpression(
        ifKeyPathMatches keyPathExpression: KeyPathPredicateExpression,
        attribute: @autoclosure () -> Attribute
    ) -> Self? {
        guard keyPathExpression.keyPath == keyPath else { return nil }
        var copy = self
        copy.attribute = attribute()
        return copy
    }
}
