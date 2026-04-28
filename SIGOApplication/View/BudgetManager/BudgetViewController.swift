//
//  BudgetViewController.swift
//  SIGOApplication
//
//  Created by training2 on 4/26/26.
//
import UIKit

class BudgetVC: UIViewController {
    
    @IBOutlet weak var budgetGauge: UILabel!
    @IBOutlet weak var btn_goInterval: UIButton!
    @IBOutlet weak var btn_goExpense: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var budgetViewModel: BudgetViewModel = BudgetViewModel()
    
    private var currentExpenses: [Expense] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    // MARK: - UI RELATED
    private func updateUI() {
        // Reload expenses for the current interval
        if let current = budgetViewModel.currentInterval {
            currentExpenses = budgetViewModel.expenses(for: current).sorted { $0.date > $1.date }
        } else {
            currentExpenses = []
        }
        tableView.reloadData()

        // MARK: BUTTON STATES
        btn_goInterval.isEnabled = !budgetViewModel.hasActiveInterval
        btn_goInterval.alpha     = budgetViewModel.hasActiveInterval ? 0.5 : 1.0
        
        btn_goExpense.isEnabled  = budgetViewModel.hasActiveInterval
        btn_goExpense.alpha      = budgetViewModel.hasActiveInterval ? 1.0 : 0.5

        // MARK: GAUGE BANNER STATES
        switch budgetViewModel.budgetStatus {
        case .noInterval:
            budgetGauge.backgroundColor = .systemGray
            budgetGauge.text = "No Active Interval"
            
        case .onBudget:
            budgetGauge.backgroundColor = .systemGreen
            budgetGauge.text = "Still on Budget!"
            
        case .nearingLimit:
            budgetGauge.backgroundColor = .systemYellow
            budgetGauge.text = "Nearing Limit!"
            
        case .overBudget:
            budgetGauge.backgroundColor = .systemRed
            budgetGauge.text = "Over Budget!"
        }
    }
    // MARK: - Segue (the navigation)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSetInterval",
           let dest = segue.destination as? IntervalVC {
            dest.vm = budgetViewModel   // pass the same ViewModel
        }
        if segue.identifier == "toAddExpense",
           let dest = segue.destination as? ExpenseVC {
            dest.vm = budgetViewModel   // pass the same ViewModel
        }
    }
    // MARK: THE NAVIGATION
    @IBAction func btn_goIntervalTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toSetInterval", sender: self)
    }

    @IBAction func btn_goExpenseTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toAddExpense", sender: self)
    }
}
// MARK: - UITableViewDataSource & Delegate
extension BudgetVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentExpenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Use a basic cell — or connect your own custom cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let expense = currentExpenses[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text          = expense.details
        config.secondaryText = "₱\(String(format: "%.2f", expense.amount))"
        cell.contentConfiguration = config
        return cell
    }
}
