//
//  SwiftDataDemoView.swift
//  PredicateViewExample
//
//  Created by Phil Zakharchenko on 9/21/24.
//

import SwiftData
import SwiftUI
import PredicateView

struct SwiftDataDemoView: View {
    struct StatusExpressionView: CustomExpressionView {
        enum Operator: String, ExpressionOperator {
            case equal = "same as"
            case notEqual = "different from"
        }
        
        static let title = "Status"
        static var defaultValue: Item.Status.RawValue? { Item.Status.todo.rawValue }
        
        static func predicate(for value: Item.Status.RawValue?, operator op: Operator) -> Predicate<Item> {
            switch op {
            case .equal:
                return #Predicate<Item> { $0._status == value }
            case .notEqual:
                return #Predicate<Item> { $0._status != value }
            }
        }
        
        @Binding var value: Item.Status.RawValue?
        
        var body: some View {
            Picker("", selection: $value) {
                ForEach(Item.Status.allCases, id: \.rawValue) { item in
                    Text(item.rawValue)
                        .tag(item.rawValue)
                }
            }
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    @State var predicate: Predicate<Item> = .true

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                PredicateView(predicate: $predicate, rowTemplates: [
                    .init(keyPath: \.title, title: "Title"),
                    .init(StatusExpressionView.self),
                ])
            }
            
            Table(items) {
                TableColumn("Title", value: \.title)
                TableColumn("Status", value: \.status.rawValue)
                TableColumn("Timestamp", value: \.timestamp.description)
            }
        }
        .padding()
        .toolbar {
            Button("Clear", systemImage: "trash") {
                clear()
            }
            
            Button("Populate", systemImage: "plus") {
                populate(itemCount: 10)
            }
        }
    }
    
    private var items: [Item] {
        try! modelContext.fetch(.init(predicate: predicate))
    }
    
    private func populate(itemCount: Int) {
        withAnimation {
            for _ in 0..<itemCount {
                modelContext.insert(Item())
            }
            try? modelContext.save()
        }
    }
    
    private func clear() {
        withAnimation {
            try? modelContext.delete(model: Item.self)
            try? modelContext.save()
        }
    }
}
