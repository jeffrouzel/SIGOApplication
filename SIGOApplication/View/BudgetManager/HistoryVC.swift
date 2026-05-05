//
//  HistoryVC.swift
//  SIGOApplication
//
//  Created by training2 on 4/29/26.
//
import UIKit

class HistoryVC: UIViewController {

    @IBOutlet weak var pickerViewHistory: UIPickerView!
    @IBOutlet weak var tableViewHistory: UITableView!
    @IBOutlet weak var searchBarHistory: UISearchBar!
    @IBOutlet weak var intervalsHistoryDD: UIStackView!
    
    var vm: BudgetViewModel!

    private var selectedInterval: Interval? = nil
    private var displayedExpenses: [Expense] = []
    private var filteredExpenses: [Expense] = []
    private var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerViewHistory.delegate   = self
        pickerViewHistory.dataSource = self
        tableViewHistory.dataSource  = self
        tableViewHistory.delegate    = self
        searchBarHistory.delegate    = self
        
        dropdownUI()
        
        print("vm is \(String(describing: vm))")

        // Auto select first interval if any
        if let first = vm.intervals.first {
            selectedInterval  = first
            displayedExpenses = vm.expenses(for: first)
        }

        pickerViewHistory.reloadAllComponents()
        tableViewHistory.reloadData()
    }
    // MARK: INTERVAL HISTORY DROPDOWN
    @IBAction func dropdownHistoryTapped(_ sender: UIButton) {
        pickerViewHistory.isHidden.toggle()

    }
    private func dropdownUI(){
        intervalsHistoryDD.layer.borderWidth = 1
        intervalsHistoryDD.layer.borderColor = UIColor.black.cgColor
        intervalsHistoryDD.layer.cornerRadius = 8
        intervalsHistoryDD.clipsToBounds = true
    }
}

// MARK: - UIPickerView
extension HistoryVC: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vm.intervals.isEmpty ? 1 : vm.intervals.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center

        if vm.intervals.isEmpty {
            label.text      = "No Intervals"
            label.textColor = .secondaryLabel
            return label
        }

        let interval  = vm.intervals[row]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let start = formatter.string(from: interval.startDate)
        let end   = formatter.string(from: interval.endDate)

        if interval.isActive {
            label.text      = "\(start) – \(end)   [Active]"
            label.textColor = .systemGreen
            label.font      = .boldSystemFont(ofSize: 16)
        } else {
            label.text      = "\(start) – \(end)"
            label.textColor = .label
            label.font      = .systemFont(ofSize: 16)
        }

        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard !vm.intervals.isEmpty else { return }
        selectedInterval  = vm.intervals[row]
        displayedExpenses = selectedInterval.map { vm.expenses(for: $0) } ?? []

        // Reset search when interval changes
        searchBarHistory.text   = ""
        isSearching      = false
        filteredExpenses = []

        tableViewHistory.reloadData()
    }
}

// MARK: - UITableView
extension HistoryVC: UITableViewDataSource, UITableViewDelegate {

    private var activeExpenses: [Expense] {
        isSearching ? filteredExpenses : displayedExpenses
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activeExpenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historycell", for: indexPath)
        let expense = activeExpenses[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text          = expense.details
        config.secondaryText = "₱\(String(format: "%.2f", expense.amount))"
        cell.contentConfiguration = config

        return cell
    }
}
// MARK: - UISearchBarDelegate
extension HistoryVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching      = false
            filteredExpenses = []
        } else {
            isSearching      = true
            filteredExpenses = displayedExpenses.filter {
                $0.details.lowercased().contains(searchText.lowercased()) ||
                String($0.amount).contains(searchText)
            }
        }
        tableViewHistory.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text       = ""
        searchBar.resignFirstResponder()
        isSearching          = false
        filteredExpenses     = []
        tableViewHistory.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
