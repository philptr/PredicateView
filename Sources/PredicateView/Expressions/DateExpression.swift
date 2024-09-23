//
//  DateExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/22/24.
//

import SwiftUI

extension AnyExpression {
    public init(keyPath: KeyPath<Root, Date>, title: String) {
        self.init(wrappedValue: DateExpression(keyPath: keyPath, title: title))
    }
    
    public init(keyPath: KeyPath<Root, Date?>, title: String) {
        self.init(wrappedValue: OptionalExpression<Root, DateExpression>(keyPath: keyPath, title: title))
    }
}

struct DateExpression<Root>: ContentExpression, WrappablePredicateExpression {
    typealias AttributeValue = Date
    
    enum Operator: String, ExpressionOperator {
        case before = "is before"
        case after = "is after"
        case sameDay = "is same day"
        case sameWeek = "is same week"
        case sameMonth = "is same month"
        
        var comparisonOperator: PredicateExpressions.ComparisonOperator? {
            switch self {
            case .before: .lessThan
            case .after: .greaterThan
            default: nil
            }
        }
        
        init?(_ comparisonOperator: PredicateExpressions.ComparisonOperator) {
            switch comparisonOperator {
            case .lessThan, .lessThanOrEqual: self = .before
            case .greaterThan, .greaterThanOrEqual: self = .after
            @unknown default: return nil
            }
        }
    }
    
    static var defaultAttribute: StandardAttribute<Self> { .init(operator: .before, value: .now) }
    
    var id = UUID()
    let keyPath: KeyPath<Root, Date>
    let title: String
    var attribute: StandardAttribute<Self> = Self.defaultAttribute
    
    static func buildPredicate<V>(
        for variable: V,
        using attribute: StandardAttribute<Self>
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value> {
        switch attribute.operator {
        case .before, .after:
            return PredicateExpressions.Comparison(
                lhs: variable,
                rhs: PredicateExpressions.Value(attribute.value),
                op: attribute.operator.comparisonOperator ?? .lessThan
            )
        case .sameDay, .sameWeek, .sameMonth:
            let interval: DateInterval
            switch attribute.operator {
            case .sameDay:
                interval = .init(
                    start: attribute.value.startOfDay,
                    end: attribute.value.endOfDay
                )
            case .sameWeek:
                interval = .init(
                    start: attribute.value.startOfWeek,
                    end: attribute.value.endOfWeek
                )
            case .sameMonth:
                interval = .init(
                    start: attribute.value.startOfMonth,
                    end: attribute.value.endOfMonth
                )
            default:
                return nil
            }
            
            return PredicateExpressions.Conjunction(
                lhs: PredicateExpressions.Comparison(
                    lhs: variable,
                    rhs: PredicateExpressions.Value(interval.start),
                    op: .greaterThanOrEqual
                ),
                rhs: PredicateExpressions.Comparison(
                    lhs: variable,
                    rhs: PredicateExpressions.Value(interval.end),
                    op: .lessThan
                )
            )
        }
    }
    
    func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> (any Expression<Root>)? {
        switch expression {
        case let expression as PredicateExpressions.Comparison<KeyPathPredicateExpression, ValuePredicateExpression>:
            DateExpression(
                keyPath: expression.lhs.keyPath,
                title: title,
                attribute: .init(operator: .init(expression.op) ?? .before, value: expression.rhs.value)
            )
        case let expression as PredicateExpressions.Conjunction<Comparison, Comparison>:
            nil
        default:
            nil
        }
    }
    
    static func makeContentView(_ value: Binding<Date>) -> some View {
        DatePicker("", selection: value, displayedComponents: .date)
    }
    
    private typealias Comparison = PredicateExpressions.Comparison<KeyPathPredicateExpression, ValuePredicateExpression>
}

private extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        startOfDay.addingTimeInterval(3600 * 24 - 1)
    }
    
    var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.weekday, .year, .month, .weekOfYear], from: self)
        components.weekday = calendar.firstWeekday
        return calendar.date(from: components) ?? self
    }
    
    var endOfWeek: Date {
        Calendar.current.date(byAdding: .second, value: 604799, to: startOfWeek) ?? startOfWeek
    }
    
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: startOfDay)) ?? self
    }
    
    var endOfMonth: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)?.addingTimeInterval(-1) ?? self
    }
    
    var startOfYear: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year], from: startOfDay)) ?? self
    }
}
