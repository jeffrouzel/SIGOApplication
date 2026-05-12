//
//  BudgetViewController.swift
//  SIGOApplication
//
//  Created by training2 on 4/26/26.
//
import UIKit

class BudgetVC: UIViewController {
    
    // Interval Card
    @IBOutlet weak var intervalView: UIView!
    @IBOutlet weak var lbl_intervalDate: UILabel!
    @IBOutlet weak var lbl_activestate: UILabel!
    
    @IBOutlet weak var lbl_totalBudget: UILabel!
    @IBOutlet weak var lbl_remaining: UILabel!
    
    @IBOutlet weak var expenseProgressBar: UIProgressView!
    @IBOutlet weak var lbl_percentageUsed: UILabel!
    @IBOutlet weak var lbl_savethreshold: UILabel!
    @IBOutlet weak var lbl_totalexpense: UILabel!

    @IBOutlet weak var carryoverView: UIStackView!
    @IBOutlet weak var lbl_carryover: UILabel!
    @IBOutlet weak var budgetGauge: UILabel!
    // Buttons
    @IBOutlet weak var btn_goInterval: UIButton!
    @IBOutlet weak var btn_goExpense: UIButton!
    @IBOutlet weak var btn_goHistory: UIButton!
    
    // Data List
    @IBOutlet weak var expenseslistView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var expensesSearchBar: UISearchBar!
    

    
    var budgetViewModel: BudgetViewModel = BudgetViewModel()
    
    private var currentExpenses: [Expense] = []
    private var filteredExpenses: [Expense] = []
    private var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate   = self
        expensesSearchBar.delegate   = self
        uiStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showContent()
    }
    
    private func showContent() {
        loadExpenses()
        tableView.reloadData()
        updateUI()
    }
    private func loadExpenses() {
        if let current = budgetViewModel.currentInterval {
            currentExpenses = budgetViewModel.expenses(for: current).sorted { $0.date > $1.date }
        } else {
            currentExpenses = []
        }
    }
    
    // MARK: - UI RELATED
    private func uiStyle(){
        view.setGradientBackground(isDay: true)
        intervalView.styleAsCardOrange()
        lbl_activestate.styleAsCircleLabelLightOrange()
        carryoverView.styleAsCardLightOrange()
        expenseslistView.styleAsCard()
        expensesSearchBar.styleRounded()
        btn_goInterval.styleAsFloatingButton()
        btn_goExpense.styleAsFloatingButton()
        
        budgetGauge.layer.cornerRadius = 10
        budgetGauge.clipsToBounds      = true
        expenseProgressBar.transform = CGAffineTransform(scaleX: 1, y: 3)     // Make progress bar bigger to be seen
    }
    private func updateUI() {
        // MARK: BUTTON STATES
        btn_goInterval.isEnabled = !budgetViewModel.hasActiveInterval
        btn_goInterval.alpha     = budgetViewModel.hasActiveInterval ? 0.5 : 1.0
        
        btn_goExpense.isEnabled  = budgetViewModel.hasActiveInterval
        btn_goExpense.alpha      = budgetViewModel.hasActiveInterval ? 1.0 : 0.5

        // MARK: Interval Card Info
        lbl_intervalDate.text = budgetViewModel.intervalDateRangeText
        lbl_activestate.text = budgetViewModel.hasActiveInterval ? "Active" : "Inactive"
        lbl_totalBudget.text = "₱\(String(format: "%.2f", budgetViewModel.totalBudget))"
        lbl_remaining.text = "₱\(String(format: "%.2f", budgetViewModel.remaining))"
        // Progress Bar
        expenseProgressBar.progress = Float(budgetViewModel.usedPercentage)
        // details below progress bar
        lbl_percentageUsed.text = "\(Int(budgetViewModel.usedPercentage*100))% Used"
        lbl_savethreshold.text = "\(Int(budgetViewModel.savePct))% of ₱\(String(format: "%.2f", budgetViewModel.inputBudget)) "
        lbl_totalexpense.text = "₱\(String(format: "%.2f", budgetViewModel.totalSpent)) spent"
        
        // Carryover Area
        carryoverView.isHidden = budgetViewModel.carryoverAmount <= 0
        lbl_carryover.text = "₱\(String(format: "%.2f", budgetViewModel.carryoverAmount))"
        
        switch budgetViewModel.budgetStatus {
        case .noInterval:
            budgetGauge.backgroundColor = .systemGray
            budgetGauge.text = "No Active Interval"
            
        case .onBudget:
            budgetGauge.backgroundColor = .systemGreen
            budgetGauge.text = "Still on Budget!"
            expenseProgressBar.tintColor = .systemGreen
            
        case .onSaveGoal:
            budgetGauge.backgroundColor = UIColor(red: 0.6, green: 0.8, blue: 0.0, alpha: 1)  // lime green
            budgetGauge.text = "Save Goal Reached!"
            expenseProgressBar.tintColor = UIColor(red: 0.6, green: 0.8, blue: 0.0, alpha: 1)  // lime green
            
        case .nearingBudgetLimit:
            budgetGauge.backgroundColor = .systemYellow
            budgetGauge.text = "Nearing Budget Limit!"
            expenseProgressBar.tintColor = .systemYellow
            
        case .onBudgetLimit:
            budgetGauge.backgroundColor = .systemRed
            budgetGauge.text = "Save Goal Failed!"
            expenseProgressBar.tintColor = .systemRed
            
        case .overBudget:
            budgetGauge.backgroundColor = .systemRed
            budgetGauge.text = "Over Budget!"
            expenseProgressBar.tintColor = .systemGray
        }
    }
    // MARK: - Segue (the navigation)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSetInterval",
           let dest = segue.destination as? IntervalVC {
            dest.vm = budgetViewModel
            dest.hidesBottomBarWhenPushed = true
        }
        if segue.identifier == "toAddExpense",
           let dest = segue.destination as? ExpenseVC {
            dest.vm = budgetViewModel
            dest.hidesBottomBarWhenPushed = true
        }
        if segue.identifier == "toSeeHistory",
           let dest = segue.destination as? HistoryVC {
            dest.vm = budgetViewModel
            dest.hidesBottomBarWhenPushed = true
        }
    }
    // MARK: THE NAVIGATION
    @IBAction func btn_goIntervalTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toSetInterval", sender: self)
    }

    @IBAction func btn_goExpenseTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toAddExpense", sender: self)
    }
    @IBAction func btn_goHistoryTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toSeeHistory", sender: self)
    }
}
// MARK: - TABLEVIEW DataSource & Delegate
extension BudgetVC: UITableViewDataSource, UITableViewDelegate {
    // USE FILTERED IF SEARCHING ELSE ALL
    private var activeExpenses: [Expense] {
        isSearching ? filteredExpenses : currentExpenses
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activeExpenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Use a basic cell — or connect your own custom cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let expense = activeExpenses[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text          = expense.details
        config.secondaryText = "₱\(String(format: "%.2f", expense.amount))"
        cell.contentConfiguration = config
        
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expense = activeExpenses[indexPath.row]

            // Update local arrays first
            budgetViewModel.deleteExpense(expense)
            if isSearching {
                filteredExpenses.removeAll { $0.id == expense.id }
                currentExpenses.removeAll { $0.id == expense.id }
            } else {
                currentExpenses.removeAll { $0.id == expense.id }
            }

            // Delete the row — no reloadData here
            tableView.deleteRows(at: [indexPath], with: .automatic)

            // Update everything else except the table
            updateUI()
        }
    }
}
// MARK: - SEARCH BAR Delegate
extension BudgetVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredExpenses = []
        } else {
            isSearching = true
            // Filter by details or amount
            filteredExpenses = currentExpenses.filter {
                $0.details.lowercased().contains(searchText.lowercased()) || String($0.amount).contains(searchText)
            }
        }
        tableView.reloadData()
    }

    // Clear search when cancel is tapped
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        filteredExpenses = []
        tableView.reloadData()
    }

    // Dismiss keyboard when search is tapped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
