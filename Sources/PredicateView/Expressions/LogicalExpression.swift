//
//  LogicalExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

public struct LogicalExpression<Root>: CompoundExpression, PredicateExpressionDecoding {
    public typealias ExprView = LogicalExpressionView<Root>
    
    public enum Operator: String, ExpressionOperator {
        case conjunction = "all"
        case disjunction = "any"
    }
    
    public var id = UUID()
    public var children: [any ExpressionProtocol<Root>] = []
    public var attribute: CompoundAttribute<Self> = .init(operator: .conjunction)
    
    public func buildPredicate(using input: PredicateExpressions.Variable<Root>) -> (any StandardPredicateExpression<Bool>)? {
        let predicates = children.compactMap { $0.buildPredicate(using: input) }
        guard !predicates.isEmpty else { return nil }
        return reducedExpression(for: predicates)
    }
    
    public func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType,
        using decoders: [any PredicateExpressionDecoding<Root>]
    ) -> (any ExpressionProtocol<Root>)? {
        switch expression {
        case let expression as any AnyLogicalPredicateExpression:
            let subexpressions = expression.subexpressions
            var results: [any ExpressionProtocol<Root>] = []
            for subexpression in subexpressions {
                results += decoders.compactMap { $0.decode(subexpression, using: decoders) }
            }

            let op = expression.operator(for: self)
            return LogicalExpression(children: results, attribute: .init(operator: op)).flattened()
        default:
            return nil
        }
    }
    
    private func reducedExpression(for expressions: [(any StandardPredicateExpression<Bool>)]) -> any StandardPredicateExpression<Bool> {
        precondition(!expressions.isEmpty)
        switch expressions.count {
        case 1:
            return expressions[0]
        case 2:
            return tupleExpression(for: attribute, firstExpression: expressions[0], secondExpression: expressions[1])
        default:
            break
        }
        
        let subExpressions = expressions.unfoldSubSequences(limitedTo: 2).map { reducedExpression(for: Array($0)) }
        return reducedExpression(for: subExpressions)
    }
    
    private func tupleExpression<T: StandardPredicateExpression<Bool>, U: StandardPredicateExpression<Bool>>(
        for attribute: CompoundAttribute<Self>,
        firstExpression: T, secondExpression: U
    ) -> any StandardPredicateExpression<Bool> where T.Output == Bool, U.Output == Bool {
        switch attribute.operator {
        case .conjunction:
            PredicateExpressions.Conjunction(lhs: firstExpression, rhs: secondExpression)
        case .disjunction:
            PredicateExpressions.Disjunction(lhs: firstExpression, rhs: secondExpression)
        }
    }
    
    private func flattened() -> Self {
        var copy = self
        copy.children = flattenChildren(children)
        return copy
    }
    
    private func flattenChildren(_ children: [any ExpressionProtocol<Root>]) -> [any ExpressionProtocol<Root>] {
        children.flatMap { child -> [any ExpressionProtocol<Root>] in
            if let child = child as? Self, child.attribute == attribute {
                flattenChildren(child.children)
            } else {
                [child]
            }
        }
    }
}

extension Collection {
    fileprivate func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence, Index> {
        sequence(state: startIndex) { start in
            guard start < self.endIndex else { return nil }
            let end = self.index(start, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex
            defer { start = end }
            return self[start..<end]
        }
    }
}

public struct LogicalExpressionView<Root>: HierarchicalExpressionView {
    public typealias Expr = LogicalExpression<Root>
    public typealias Attribute = CompoundAttribute<Expr>
    
    public var expression: Binding<Expr>
    var parent: Binding<LogicalExpression<Root>>?
    
    @Environment(\.isEnabled) private var isEnabled
    @Environment(PredicateViewConfiguration<Root>.self) private var configuration
    
    public init(expression: Binding<LogicalExpression<Root>>) {
        self.expression = expression
    }
    
    public var body: some View {
        @Binding(projectedValue: expression) var expression
        
        TokenView(Root.self) {
            Text("Group")
        } content: {
            Text(expression.attribute.operator.rawValue.capitalized)
        } menu: {
            Menu("New") {
                menuItems
            }
            
            Divider()
            
            Expr.makeOperatorMenu(using: $expression.attribute.operator)
                .preference(
                    key: PredicateAttributePreferenceKey.self,
                    value: [expression.id: expression.currentValue]
                )
            
            Divider()
            
            if let parent,
               let index = parent.wrappedValue.children.firstIndex(where: { $0.id == expression.id }) {
                Button("Ungroup") {
                    self.parent?.wrappedValue.children.replaceSubrange(index...index, with: expression.children)
                }
            }
            
            if !expression.children.isEmpty {
                Button("Clear") {
                    expression.children.removeAll()
                }
            }
        } widget: {
            ForEach($expression.children, id: \.id) { childExpression in
                childView(for: childExpression)
                    .onPreferenceChange(PredicateDeletedStatusPreferenceKey.self) { isDeleted in
                        if isDeleted {
                            expression.children.removeAll { $0.id == childExpression.wrappedValue.id }
                        }
                    }
            }
            
            if isEnabled {
                NewItemMenuButton { menuItems }
            }
        }
    }
    
    @ViewBuilder
    private var menuItems: some View {
        @Binding(projectedValue: expression) var expression
        
        Menu("New Group") {
            ForEach(LogicalExpression<Root>.Operator.allCases, id: \.self) { option in
                Button(option.rawValue.capitalized) {
                    expression.children.append(
                        LogicalExpression<Root>(attribute: .init(operator: option))
                    )
                }
            }
        }
        
        Divider()
        
        ForEach(configuration.rowTemplates, id: \.id) { template in
            Button(template.title) {
                var copy = template
                copy.id = UUID()
                expression.children.append(copy)
            }
        }
    }
}

protocol AnyLogicalPredicateExpression: PredicateExpression<Bool> {
    var erasedLHS: any PredicateExpression<Bool> { get }
    var erasedRHS: any PredicateExpression<Bool> { get }
    func `operator`<Root>(for expression: LogicalExpression<Root>) -> LogicalExpression<Root>.Operator
}

extension AnyLogicalPredicateExpression {
    var subexpressions: [any PredicateExpression<Bool>] {
        [erasedLHS, erasedRHS]
    }
}

extension PredicateExpressions.Conjunction: AnyLogicalPredicateExpression {
    var erasedLHS: any PredicateExpression<Bool> { lhs }
    var erasedRHS: any PredicateExpression<Bool> { rhs }
    func `operator`<Root>(for expression: LogicalExpression<Root>) -> LogicalExpression<Root>.Operator { .conjunction }
}

extension PredicateExpressions.Disjunction: AnyLogicalPredicateExpression {
    var erasedLHS: any PredicateExpression<Bool> { lhs }
    var erasedRHS: any PredicateExpression<Bool> { rhs }
    func `operator`<Root>(for expression: LogicalExpression<Root>) -> LogicalExpression<Root>.Operator { .disjunction }
}
