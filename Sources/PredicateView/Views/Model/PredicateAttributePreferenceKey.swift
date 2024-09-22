//
//  PredicateAttributePreferenceKey.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

public struct PredicateAttributePreferenceKey: PreferenceKey {
    public static var defaultValue: [UUID: AnyHashable]? { nil }
    
    public static func reduce(value: inout [UUID: AnyHashable]?, nextValue: () -> [UUID: AnyHashable]?) {
        if let nextValue = nextValue() {
            for (k, v) in nextValue { value?[k] = v }
        }
    }
}

public struct PredicateDeletedStatusPreferenceKey: PreferenceKey {
    public static var defaultValue: Bool { false }
    
    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
