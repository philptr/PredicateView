//
//  ContentView.swift
//  PredicateViewExample
//
//  Created by Phil Zakharchenko on 9/21/24.
//

import SwiftUI
import SwiftData
import PredicateView

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink("Simple") {
                    PredicateDemoView()
                        .navigationTitle("PredicateView")
                        .toolbarTitleDisplayMode(.inline)
                }
                
                NavigationLink("SwiftData") {
                    SwiftDataDemoView()
                        .navigationTitle("SwiftData")
                        .toolbarTitleDisplayMode(.inline)
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        } detail: {
            Text("Select an item")
        }
    }

//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
