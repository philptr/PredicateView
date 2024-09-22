//
//  DefaultExpressionValueConvertible.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/21/24.
//

import Foundation

public protocol DefaultExpressionValueConvertible {
    static var defaultExpressionValue: Self { get }
}

extension String: DefaultExpressionValueConvertible {
    public static var defaultExpressionValue: Self { "" }
}

extension Date: DefaultExpressionValueConvertible {
    public static var defaultExpressionValue: Self { .now }
}

extension Optional: DefaultExpressionValueConvertible {
    public static var defaultExpressionValue: Self { nil }
}
