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
    @Environment(\.modelContext) private var modelContext
    @State var predicate: Predicate<Item> = .true

    var body: some View {
        VStack(alignment: .leading) {
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
        .toolbar {
            Button("Clear", systemImage: "trash") {
                clear()
            }
            
            Button("Populate", systemImage: "plus") {
                populate(itemCount: 10)
            }
        }
    }
    
    private func predicateView(for predicate: Binding<Predicate<Item>>) -> some View {
        ScrollView(.horizontal) {
            PredicateView(predicate: predicate, rowTemplates: [
                .init(keyPath: \.title, title: "Title"),
                .init(keyPath: \.creationDate, title: "Creation date"),
                .init(keyPath: \.modificationDate, title: "Modification date"),
            ])
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
