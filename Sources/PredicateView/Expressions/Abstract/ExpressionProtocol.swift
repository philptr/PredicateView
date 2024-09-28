//
//  ExpressionProtocol.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import Foundation

// MARK: - Expression

/// Defines the core requirements for an expression in the predicate builder system.
public protocol ExpressionProtocol<Root>: Identifiable {
    /// The root type that this expression operates on.
    associatedtype Root
    
    /// The view type used to represent this expression in the control's UI.
    associatedtype ExprView: ExpressionView<Self>
    
    /// The type of operator enumeration that this expression supports.
    associatedtype Operator: ExpressionOperator
    
    /// A unique identifier for the expression instance.
    var id: UUID { get set }
    
    /// The current value of the expression, wrapped as `AnyHashable`.
    var currentValue: AnyHashable { get }
    
    /// Builds a predicate expression using the provided input variable.
    ///
    /// - Parameter input: A variable representing the root of the predicate.
    /// - Returns: An optional `StandardPredicateExpression<Bool>` representing the built predicate,
    ///   or `nil` if the predicate couldn't be built.
    func buildPredicate(
        using input: PredicateExpressions.Variable<Root>
    ) -> (any StandardPredicateExpression<Bool>)?
}

public protocol ExpressionOperator: CaseIterable, Hashable, RawRepresentable where RawValue == String, AllCases: RandomAccessCollection, AllCases.Index == Int { }
