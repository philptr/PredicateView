//
//  TokenView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

struct TokenView<Root, Header: View, Content: View, MenuItems: View, Widget: View>: View {
    enum ContentState: Hashable {
        case focused
    }
    
    var header: Header
    var content: Content
    var menu: MenuItems
    var widget: Widget
    
    @State var isDeleted: Bool = false
    
    @Environment(\.isEnabled) private var isEnabled
    @Environment(PredicateViewConfiguration<Root>.self) private var configuration
    @FocusState private var contentFocus: ContentState?
    
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
                    .fixedSize(horizontal: true, vertical: false)
                
                content
                    .textFieldStyle(.plain)
                    .font(.headline)
                    .fixedSize(horizontal: true, vertical: false)
                    .controlSize(.small)
                    .focused($contentFocus, equals: .focused)
                    .onAppear {
                        contentFocus = .focused
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
        .contextMenu(menuItems: {
            if isEnabled {
                menuItems
            }
        })
        .background {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
                .fill(Color.accentColor.opacity(0.1))
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
