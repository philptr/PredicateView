//
//  PredicateAttributePreferenceKey.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

struct PredicateAttributePreferenceKey: PreferenceKey {
    static var defaultValue: [UUID: AnyHashable]? { nil }
    
    static func reduce(value: inout [UUID: AnyHashable]?, nextValue: () -> [UUID: AnyHashable]?) {
        if let nextValue = nextValue() {
            for (k, v) in nextValue { value?[k] = v }
        }
    }
}

struct PredicateDeletedStatusPreferenceKey: PreferenceKey {
    static var defaultValue: Bool { false }
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
