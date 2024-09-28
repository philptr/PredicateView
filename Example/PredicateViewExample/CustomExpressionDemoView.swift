//
//  CustomExpressionDemoView.swift
//  PredicateViewExample
//
//  Created by Phil Zakharchenko on 9/28/24.
//

import SwiftData
import SwiftUI
import PredicateView

// MARK: - StatusExpressionView

/// A custom expression view for handling status predicates in a predicate builder.
struct StatusExpressionView: CustomExpressionView {
    /// Defines the operators available for status comparisons.
    enum Operator: String, ExpressionOperator {
        case equal = "is"
        case notEqual = "is not"
    }
    
    /// The title of the expression view.
    static let title = "Status"
    
    /// The key path to the status property of an ``Item``.
    static var keyPath: KeyPath<Item, Item.Status.RawValue?> { \._status }
    
    /// The default value for the status.
    /// This will be the value picked automatically when the user inserts this view into an expression.
    static var defaultValue: Item.Status.RawValue? { Item.Status.todo.rawValue }
    
    /// Creates a predicate for a given status value and operator.
    ///
    /// - Parameters:
    ///   - value: The status value to compare against.
    ///   - op: The operator to use for comparison.
    /// - Returns: A `Predicate<Item>` representing the status condition.
    static func predicate(for value: Item.Status.RawValue?, operator op: Operator) -> Predicate<Item> {
        switch op {
        case .equal:
            return #Predicate<Item> { $0._status == value }
        case .notEqual:
            return #Predicate<Item> { $0._status != value }
        }
    }
    
    /// Decodes a predicate expression into a `DecodedKeyPathExpression`.
    ///
    /// - Parameter expression: The predicate expression to decode.
    /// - Returns: A `DecodedKeyPathExpression<Self>` if the expression can be decoded, otherwise `nil`.
    static func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> DecodedKeyPathExpression<Self>? {
        switch expression {
        case let expression as PredicateExpressions.Equal<KeyPathPredicateExpression, ValuePredicateExpression>:
            .init(keyPathExpression: expression.lhs, operator: .equal, value: expression.rhs.value)
        case let expression as PredicateExpressions.NotEqual<KeyPathPredicateExpression, ValuePredicateExpression>:
            .init(keyPathExpression: expression.lhs, operator: .notEqual, value: expression.rhs.value)
        default:
            nil
        }
    }
    
    /// The binding to the current status value.
    @Binding var value: Item.Status.RawValue?
    
    /// The body of the view, which creates a picker for selecting the status.
    var body: some View {
        Picker("", selection: $value) {
            ForEach(Item.Status.allCases, id: \.rawValue) { item in
                Text(item.rawValue)
                    .tag(item.rawValue)
            }
        }
    }
}

// MARK: - CustomExpressionDemoView

struct CustomExpressionDemoView: View {
    @Environment(\.modelContext) private var modelContext
    @State var predicate: Predicate<Item> = #Predicate<Item> {
        $0.title.localizedStandardContains("Item")
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("This demo provides a sample implementation of the `CustomExpressionView` protocol that allows you to build custom expression views for key paths not covered by the standard set of built-in expressions. In this example, the status picker is a custom expression view that maps between an `Optional<String>` model representation and an enum value.")
            
            predicateView(for: $predicate)
            
            Table(items) {
                TableColumn("Title", value: \.title)
                TableColumn("Status", value: \.status.rawValue)
                TableColumn("Created") { value in
                    Text(value.creationDate, style: .date)
                }
                TableColumn("Modified") { value in
                    Text(value.modificationDate, style: .date)
                }
            }
        }
        .padding()
    }
    
    private var items: [Item] {
        try! modelContext.fetch(.init(predicate: predicate))
    }
    
    private func predicateView(for predicate: Binding<Predicate<Item>>) -> some View {
        ScrollView(.horizontal) {
            PredicateView(predicate: predicate, rowTemplates: [
                .init(keyPath: \.title, title: "Title"),
                .init(keyPath: \.creationDate, title: "Creation date"),
                .init(keyPath: \.modificationDate, title: "Modification date"),
                .init(StatusExpressionView.self),
            ])
        }
    }
}
