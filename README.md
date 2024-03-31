# PredicateView

A SwiftUI control for viewing and editing Swift Predicates

![PredicateView on macOS](Resources/MacDemo.png "PredicateView on macOS")

## Motivation

[`NSPredicateEditor`](https://developer.apple.com/documentation/appkit/nspredicateeditor) is amazing, but doesn't (and likely won't) have support for Foundation's new [Swift Predicates](https://forums.swift.org/t/pitch-swift-predicates/62000) feature ([proposal link](https://gist.github.com/jmschonfeld/6821392a968a1a1a42aba3c96d333239)).

In addition – not that it matters – as an AppKit control, `NSPredicateEditor` doesn't support other platforms.

This repo is an experiment on designing and implementing a cross-platform SwiftUI-native control for viewing and editing Swift Predicates. In addition, `PredicateView` has a more compact UI representation, especially when editing more complex predicates.

## Getting Started

A `PredicateView` can be initialized using a binding to a [`Predicate`](https://developer.apple.com/documentation/foundation/predicate) and a collection of row templates. Note: it purposefully uses the same terminology for row templates as `NSPredicateEditor`.

```swift
/// A sample model type.
struct Model: Identifiable {
    enum EmploymentStatus: String, CaseIterable, Codable {
        case employed
        case unemployed
        case selfEmployed
        case student
        case other
    }
    
    let id = UUID()
    let firstName: String
    let age: Int
    let employmentStatus: EmploymentStatus
    let isRegistered: Bool
}

/// A sample predicate.
@State var predicate: Predicate<Model> = .true

/// A predicate view that supports filtering through first names, age, employment, and registration status.
PredicateView(predicate: $predicate, rowTemplates: [
    .init(keyPath: \.firstName, title: "First Name"),
    .init(keyPath: \.age, title: "Age"),
    .init(keyPath: \.employmentStatus, title: "Employment Status"),
    .init(keyPath: \.isRegistered, title: "Registration Status")
])
```

See the built-in `PredicateDemoView` for a complete sample use case.

## Features

- [x] Easy setup
- [x] Type safety
- [x] Rich representations for supported data types

## Not Features

As an experimental control, `PredicateView` does not support the following capabilities. It would, however, be great to see them implemented in the future.

- [ ] Fully custom appearance and custom token views
- [ ] A rich text experience using text attachments
- [ ] Support for all built-in `PredicateExpression`s

## Compatibility

Compatibility matches that of the [Swift predicates](https://forums.swift.org/t/pitch-swift-predicates/62000) feature; namely macOS 14.0+, iOS 17.0+, watchOS 10.0+.
