//
//  AnyExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import Foundation

public typealias ExpressionCompatible = Codable & Hashable

public struct AnyExpression<Root>: Identifiable {
    public var wrappedValue: any ValueExpression<Root>
    public var id: UUID { wrappedValue.id }
}
