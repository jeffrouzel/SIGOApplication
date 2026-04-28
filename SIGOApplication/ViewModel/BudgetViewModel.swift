//
//  BudgetViewModel.swift
//  SIGOApplication
//
//  Created by training2 on 4/27/26.
//
import Foundation

final class BudgetViewModel {

    // MARK: - Data
    private(set) var intervals: [Interval] = []
    private(set) var expenses: [Expense] = []

    // MARK: - Computed helpers (VCs read these to update UI)
    var hasActiveInterval: Bool {
        intervals.contains { $0.isActive }
    }

    var currentInterval: Interval? {
        intervals.first { $0.isActive }
    }

    var totalSpent: Double {
        guard let current = currentInterval else { return 0 }
        return expenses(for: current).reduce(0) { $0 + $1.amount }
    }

    var remaining: Double {
        guard let current = currentInterval else { return 0 }
        return current.budget - totalSpent
    }

    var saveThreshold: Double {
        guard let current = currentInterval else { return 0 }
        return current.budget * (current.savePercentage / 100)
    }

    // MARK: BUDGET STATUS GAUGE
    var budgetStatus: BudgetStatus {
        guard hasActiveInterval else { return .noInterval }
        if remaining <= 0 { return .overBudget }
        else if remaining <= saveThreshold { return .nearingLimit }
        else { return .onBudget }
    }

    enum BudgetStatus {
        case noInterval
        case onBudget
        case nearingLimit
        case overBudget
    }

    // MARK: - UserDefaults keys
    private let defaults = UserDefaults.standard
    private let intervalsKey = "saved_intervals"
    private let expensesKey  = "saved_expenses"

    init() { load() }

// MARK: - SAVING ACTIONS
    // MARK: Interval action
    func saveInterval(startDate: Date,
                      endDate: Date,
                      budgetText: String,
                      savePercentageText: String) -> String? {

        guard let budget = Double(budgetText), budget > 0 else {
            return "Please enter a valid budget amount."
        }
        guard let savePct = Double(savePercentageText), savePct >= 0, savePct <= 100 else {
            return "Please enter a valid save percentage (0–100)."
        }
        guard endDate > startDate else {
            return "End date must be after start date."
        }
        guard !hasActiveInterval else {
            return "An interval is already active. Wait for it to end first."
        }

        let interval = Interval(
            id: UUID(),
            startDate: startDate,
            endDate: endDate,
            budget: budget,
            savePercentage: savePct
        )
        intervals.append(interval)
        save()
        return nil
    }

    // MARK: Expense action
    func saveExpense(amountText: String, details: String) -> String? {

        guard let amount = Double(amountText), amount > 0 else {
            return "Please enter a valid amount."
        }
        guard !details.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "Please enter expense details."
        }
        guard let active = currentInterval else {
            return "No active interval. Create one first."
        }

        let expense = Expense(
            id: UUID(),
            amount: amount,
            details: details,
            date: Date(),
            intervalID: active.id
        )
        expenses.append(expense)
        save()
        return nil
    }

    func expenses(for interval: Interval) -> [Expense] {
        expenses.filter { $0.intervalID == interval.id }
    }

    // MARK: - Functions for Data Persistence
    // save data every save of details
    private func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(intervals) {
            defaults.set(encoded, forKey: intervalsKey)
        }
        if let encoded = try? encoder.encode(expenses) {
            defaults.set(encoded, forKey: expensesKey)
        }
    }

    // load data every start of app
    private func load() {
        let decoder = JSONDecoder()
        if let data = defaults.data(forKey: intervalsKey),
           let decoded = try? decoder.decode([Interval].self, from: data) {
            intervals = decoded
        }
        if let data = defaults.data(forKey: expensesKey),
           let decoded = try? decoder.decode([Expense].self, from: data) {
            expenses = decoded
        }
    }
}
