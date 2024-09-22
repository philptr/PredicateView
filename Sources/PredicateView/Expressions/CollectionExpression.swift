//
//  CollectionExpression.swift
//  
//
//  Created by Phil Zakharchenko on 4/20/24.
//

import Foundation
import SwiftUI

public typealias CollectionExpressionCompatible = Sequence & Hashable

extension AnyExpression {
    public init<C>(keyPath: KeyPath<Root, C>, title: String, rowTemplates: [AnyExpression<C.Element>]) where C: CollectionExpressionCompatible {
        self.init(wrappedValue: CollectionExpression(keyPath: keyPath, title: title, rowTemplates: rowTemplates))
    }
}

public struct CollectionExpression<Root, C>: SimpleExpression, StaticPredicateExpression where C: CollectionExpressionCompatible {
    struct CurrentValue: Hashable {
        var op: Operator
        var metadata: AnyHashable
    }
    
    public typealias Value = C
    public typealias AttributeValue = Int
    public typealias ExprView = CollectionExpressionView<Root, C>
    public typealias Attribute = MetadataAttribute<Self, LogicalExpression<C.Element>>
    
    public enum Operator: String, ExpressionOperator {
        case contains = "contains"
        case doesNotContain = "does not contain"
        case allSatisfy = "all elements satisfy"
    }
    
    public static var defaultAttribute: Attribute {
        .init(operator: .contains, value: 0, metadata: LogicalExpression<C.Element>())
    }
    
    public var id = UUID()
    public var attribute: Attribute = Self.defaultAttribute
    
    public let keyPath: KeyPath<Root, C>
    public let title: String
    
    public var rowTemplates: [AnyExpression<C.Element>]
    
    public var currentValue: AnyHashable {
        CurrentValue(op: attribute.operator, metadata: attribute.metadata.currentValue)
    }
    
    public static func buildPredicate<V: StandardPredicateExpression<C>>(
        for variable: V,
        using attribute: Attribute
    ) -> (any StandardPredicateExpression<Bool>)? {
        guard let sequencePredicate = sequencePredicate(for: variable, childExpression: attribute.metadata, op: attribute.operator) else {
            return nil
        }
        
        return switch attribute.operator {
        case .contains, .allSatisfy:
            sequencePredicate
        case .doesNotContain:
            sequencePredicate.negated()
        }
    }
    
    private static func sequencePredicate<V: StandardPredicateExpression<C>>(
        for sequenceVariable: V,
        childExpression: LogicalExpression<C.Element>,
        op: Operator
    ) -> (any StandardPredicateExpression<Bool>)? {
        func makeExpression<U: StandardPredicateExpression<Bool>>(
            using elementTest: U
        ) -> (any StandardPredicateExpression<Bool>)? {
            let expressionOperation: PredicateExpressions.CollectionOperation = switch op {
            case .contains, .doesNotContain: .contains
            case .allSatisfy: .allSatisfy
            }
            
            return PredicateExpressions.SequencePredicate(sequence: sequenceVariable, test: elementTest, variable: elementVariable, operation: expressionOperation)
        }
        
        let elementVariable = PredicateExpressions.Variable<C.Element>()
        guard let elementTest = childExpression.buildPredicate(using: elementVariable) else { return nil }
        
        return makeExpression(using: elementTest)
    }
}

public struct CollectionExpressionView<Root, C>: HierarchicalExpressionView where C: CollectionExpressionCompatible {
    public typealias Expr = CollectionExpression<Root, C>
    
    public var expression: Binding<Expr>
    var parent: Binding<LogicalExpression<Root>>?
    
    @Environment(\.isEnabled) private var isEnabled
    @Bindable private var configuration: PredicateViewConfiguration<C.Element>
    
    public init(expression: Binding<CollectionExpression<Root, C>>) {
        self.expression = expression
        let templates = expression.wrappedValue.rowTemplates.map(\.wrappedValue)
        self.configuration = PredicateViewConfiguration(rowTemplates: templates)
    }
    
    public var body: some View {
        @Binding(projectedValue: expression) var expression
        
        TokenView(Root.self) {
            Text(expression.title)
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
            
            if !expression.attribute.metadata.children.isEmpty {
                Button("Clear") {
                    expression.attribute.metadata.children.removeAll()
                }
            }
        } widget: {
            ForEach($expression.attribute.metadata.children, id: \.id) { childExpression in
                childView(for: childExpression)
                    .environment(configuration)
                    .onPreferenceChange(PredicateDeletedStatusPreferenceKey.self) { isDeleted in
                        if isDeleted {
                            expression.attribute.metadata.children.removeAll {
                                $0.id == childExpression.wrappedValue.id
                            }
                        }
                    }
            }
            
            if isEnabled {
                MenuButton(label: Image(systemName: "plus.circle")) {
                    menuItems
                }
                .tint(.accentColor)
                .fixedSize()
                .menuButtonStyle(BorderlessButtonMenuButtonStyle())
            }
        }
    }
    
    @ViewBuilder
    private var menuItems: some View {
        @Binding(projectedValue: expression) var expression
        
        Menu("New Group") {
            ForEach(LogicalExpression<C.Element>.Operator.allCases, id: \.self) { option in
                Button(option.rawValue.capitalized) {
                    expression.attribute.metadata.children.append(
                        LogicalExpression<C.Element>(attribute: .init(operator: option))
                    )
                }
            }
        }
        
        Divider()
        
        ForEach(expression.rowTemplates, id: \.id) { template in
            Button(template.title) {
                expression.attribute.metadata.children.append(template.copy().wrappedValue)
            }
        }
    }
}
