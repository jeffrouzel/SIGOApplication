//
//  BudgetResponse.swift
//  SIGOApplication
//
//  Created by training2 on 4/25/26.
//
import Foundation

// MARK: Interval Model
struct Interval: Codable, Identifiable {
    let id: UUID
    var startDate: Date
    var endDate: Date
    var budget: Double
    var savePercentage: Double

    // Is the interval currently running right now?
    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
}

// MARK: Expense Model
struct Expense: Codable, Identifiable {
    let id: UUID
    var amount: Double
    var details: String
    var date: Date
    var intervalID: UUID   // links this expense to its parent Interval
}
