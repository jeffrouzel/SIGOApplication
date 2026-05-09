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
    
    // MARK: - UserDefaults keys
    private let defaults = UserDefaults.standard
    private let intervalsKey = "saved_intervals"
    private let expensesKey  = "saved_expenses"
    
    // Load data whenever app launches
    init() { loadData() }

// MARK: - SAVING ACTIONS
    // MARK: Interval action
    func saveInterval(startDate: Date,
                      endDate: Date,
                      budgetText: String,
                      savePercentageText: String,
                      ) -> String? {

        guard let budget = Double(budgetText), budget > 0 else {
            return "Please enter a valid budget amount."
        }
        guard let savePct = Double(savePercentageText), savePct >= 0, savePct <= 100 else {
            return "Please enter a valid save percentage (0–100)."
        }
        guard endDate > startDate else {
            return "End date must be after start date."
        }
        // Incase of accidental access to setting interval again
        guard !hasActiveInterval else {
            return "An interval is already active. Wait for it to end first."
        }
        
        let finalBudget = budget + carryoverAmount

        let interval = Interval(
            id: UUID(),
            startDate: startDate,
            endDate: endDate,
            inputBudget: budget,
            totalBudget: finalBudget,
            savePercentage: savePct
        )
        intervals.append(interval)
        saveData()
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
        saveData()
        return nil
    }
    
    // For deleting individual expenses
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveData()
    }

    // return only the expenses of the active interval
    func expenses(for interval: Interval) -> [Expense] {
        expenses.filter { $0.intervalID == interval.id }
    }
// MARK: - Functions for Data Persistence
    // save data every save of details
    private func saveData() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(intervals) {
            defaults.set(encoded, forKey: intervalsKey)
        }
        if let encoded = try? encoder.encode(expenses) {
            defaults.set(encoded, forKey: expensesKey)
        }
    }

    // load data every start of app
    private func loadData() {
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
    // MARK: - UI RELATED
    var hasActiveInterval: Bool {
        intervals.contains { $0.isActive }
    }

    var currentInterval: Interval? {
        intervals.first { $0.isActive }
    }
    
    var totalBudget: Double {
        guard let current = currentInterval else { return 0 }
        return current.totalBudget
    }

    var totalSpent: Double {
        guard let current = currentInterval else { return 0 }
        return expenses(for: current).reduce(0) { $0 + $1.amount }  // starting from amount 0, each loop adds to the expense
    }

    var remaining: Double {
        guard let current = currentInterval else { return 0 }
        return current.totalBudget - totalSpent
    }
    
    var inputBudget: Double{
        guard let current = currentInterval else { return 0 }
        return current.inputBudget
    }
    
    var savePct: Double{
        guard let current = currentInterval else { return 0 }
        return current.savePercentage
    }

    // MARK: BUDGET STATUS GAUGE
    var saveThreshold: Double {
        guard let current = currentInterval else { return 0 }
        return current.inputBudget * (current.savePercentage / 100)
    }
    
    var saveRemaining: Double {
        guard let current = currentInterval else { return 0 }
        return current.inputBudget - totalSpent
    }
    
    var budgetStatus: BudgetStatus {
        guard hasActiveInterval else { return .noInterval }
        if remaining < 0 && totalSpent > totalBudget { return .overBudget }
        else if totalSpent == inputBudget { return .onBudgetLimit }
        else if saveRemaining < saveThreshold  { return .nearingBudgetLimit }
        else if saveRemaining == saveThreshold { return .onSaveGoal }
        else { return .onBudget }
    }

    enum BudgetStatus {
        case noInterval
        case onBudget
        case onSaveGoal
        case nearingBudgetLimit
        case onBudgetLimit
        case overBudget
    }
    
    var intervalDateRangeText: String {
        guard let current = currentInterval else { return "No Active Interval" }
        return formatDateRangeText(startDate: current.startDate, endDate: current.endDate)
    }
    var usedPercentage: Double {
        guard hasActiveInterval, totalBudget > 0 else { return 0 }
        return totalSpent / totalBudget
    }
    // MARK: - FOR CARRYOVER OF BUDGET
    var lastEndedInterval: Interval? {
        intervals
            .filter { !$0.isActive && $0.endDate < Date() }
            .sorted { $0.endDate > $1.endDate }
            .first
    }
    var carryoverAmount: Double {
        guard let last = lastEndedInterval else { return 0 }
        let spent = expenses(for: last).reduce(0) { $0 + $1.amount }
        let leftover = last.totalBudget - spent
        return max(0, leftover)  // never carry over a negative
    }
    
}
