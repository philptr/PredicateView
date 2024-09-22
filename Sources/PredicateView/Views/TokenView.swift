//
//  TokenView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

struct TokenView<Root, Header: View, Content: View, MenuItems: View, Widget: View>: View {
    var header: Header
    var content: Content
    var menu: MenuItems
    var widget: Widget
    
    @State var isDeleted: Bool = false
    
    @Environment(\.isEnabled) private var isEnabled
    @Environment(PredicateViewConfiguration<Root>.self) private var configuration
    @FocusState private var isFocused: Bool
    
    init(
        _ type: Root.Type,
        @ViewBuilder header: (() -> Header),
        @ViewBuilder content: (() -> Content),
        @ViewBuilder menu: (() -> MenuItems),
        @ViewBuilder widget: (() -> Widget) = { EmptyView() }
    ) {
        self.header = header()
        self.content = content()
        self.menu = menu()
        self.widget = widget()
    }
    
    var body: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                content
                    .textFieldStyle(.plain)
                    .font(.headline)
                    .controlSize(.small)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
            }
            .padding(4)
            
            if isEnabled {
                widget
                
                Menu("") { menuItems }
                    .padding(6)
                    .fixedSize()
                    .menuStyle(.borderlessButton)
                    .preference(key: PredicateDeletedStatusPreferenceKey.self, value: isDeleted)
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            isFocused = true
        }
        .contextMenu {
            if isEnabled {
                menuItems
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
                .fill(Color.accentColor.opacity(isFocused ? 0.15 : 0.1))
        }
        .disabled(!isEnabled)
    }
    
    @ViewBuilder
    private var menuItems: some View {
        menu
        
        Divider()
        
        Button("Remove") {
            isDeleted = true
        }
    }
}
