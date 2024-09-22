//
//  NewItemMenuButton.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/21/24.
//

import SwiftUI

struct NewItemMenuButton<Content: View>: View {
    @ViewBuilder let menuItems: () -> Content
    
    var body: some View {
#if os(macOS)
        MenuButton(label: Image(systemName: "plus.circle")) {
            menuItems()
        }
        .tint(.accentColor)
        .fixedSize()
        .menuButtonStyle(BorderlessButtonMenuButtonStyle())
#else
        Menu {
            menuItems()
        } label: {
            Image(systemName: "plus.circle")
        }
        .tint(.accentColor)
        .fixedSize()
        .menuStyle(.borderlessButton)
#endif
    }
}
