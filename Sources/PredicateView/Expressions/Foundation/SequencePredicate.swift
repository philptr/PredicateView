//
//  SequencePredicate.swift
//
//
//  Created by Phil Zakharchenko on 4/21/24.
//

import Foundation

extension PredicateExpressions {
    enum CollectionOperation: Codable {
        case contains
        case allSatisfy
    }
    
    struct SequencePredicate<
        LHS: PredicateExpression,
        RHS: PredicateExpression
    >: PredicateExpression where LHS.Output: Sequence, RHS.Output == Bool {
        typealias Element = LHS.Output.Element
        typealias Output = Bool
        
        let sequence: LHS
        let test: RHS
        let variable: Variable<Element>
        let operation: CollectionOperation
        
        func evaluate(_ bindings: PredicateBindings) throws -> Output {
            var mutableBindings = bindings
            let evaluatedBindings = try sequence.evaluate(bindings)
            return try apply(operation, to: evaluatedBindings) {
                mutableBindings[variable] = $0
                return try test.evaluate(mutableBindings)
            }
        }
        
        private func apply(_ operation: CollectionOperation, to output: LHS.Output, condition: (Self.Element) throws -> Bool) rethrows -> Bool {
            switch operation {
            case .contains:
                try output.contains(where: condition)
            case .allSatisfy:
                try output.allSatisfy(condition)
            }
        }
    }
}

extension PredicateExpressions.SequencePredicate: StandardPredicateExpression where LHS: StandardPredicateExpression, RHS: StandardPredicateExpression { }

extension PredicateExpressions.SequencePredicate: Codable where LHS: Codable, RHS: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(sequence)
        try container.encode(test)
        try container.encode(variable)
        try container.encode(operation)
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        sequence = try container.decode(LHS.self)
        test = try container.decode(RHS.self)
        variable = try container.decode(PredicateExpressions.Variable<Element>.self)
        operation = try container.decode(PredicateExpressions.CollectionOperation.self)
    }
}
