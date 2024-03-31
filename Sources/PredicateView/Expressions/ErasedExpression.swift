//
//  ErasedExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import Foundation

public struct ErasedExpression<Root>: Identifiable {
    public typealias ExpressionCompatible = Codable & Hashable
    public typealias NumericExpressionCompatible = Numeric & Strideable & ExpressionCompatible
    public typealias EnumExpressionCompatible = CaseIterable & CustomStringConvertible & Identifiable & ExpressionCompatible
    public typealias RawExpressionCompatible = CaseIterable & RawRepresentable & ExpressionCompatible
    
    public var wrappedValue: any SimpleExpression<Root>
    public var id: UUID { wrappedValue.id }
    
    public init(keyPath: KeyPath<Root, String>, title: String) {
        self.wrappedValue = StringExpression(keyPath: keyPath, title: title)
    }
    
    public init<T>(keyPath: KeyPath<Root, T>, title: String) where T: NumericExpressionCompatible {
        self.wrappedValue = NumericExpression(keyPath: keyPath, title: title)
    }
    
    public init<T>(keyPath: KeyPath<Root, T>, title: String) where T: EnumExpressionCompatible, T.AllCases: RandomAccessCollection {
        self.wrappedValue = EnumExpression(keyPath: keyPath, title: title)
    }
    
    public init<T>(keyPath: KeyPath<Root, T>, title: String) where T: RawExpressionCompatible, T.AllCases: RandomAccessCollection, T.RawValue: StringProtocol {
        self.wrappedValue = RawRepresentableEnumExpression(keyPath: keyPath, title: title)
    }
    
    public init(keyPath: KeyPath<Root, Bool>, title: String) {
        self.wrappedValue = BoolExpression(keyPath: keyPath, title: title)
    }
    
    func copy() -> Self {
        var newInstance = self
        newInstance.wrappedValue.id = UUID()
        return newInstance
    }
}
