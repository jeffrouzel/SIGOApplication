//
//  ExpenseVC.swift
//  SIGOApplication
//
//  Created by training2 on 4/28/26.
//
import UIKit

class ExpenseVC: UIViewController {

    // Connect these in storyboard
    @IBOutlet weak var lbl_remaining: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!

    var vm: BudgetViewModel!   // passed from BudgetVC via prepare(for:)

    override func viewDidLoad() {
        super.viewDidLoad()
        updateRemainingLabel()
    }

    private func updateRemainingLabel() {
        lbl_remaining.text = "₱\(String(format: "%.0f", vm.remaining))"

        // Change color based on budget status
        switch vm.budgetStatus {
        case .overBudget:   lbl_remaining.textColor = .systemRed
        case .nearingLimit: lbl_remaining.textColor = .systemOrange
        default:            lbl_remaining.textColor = .label
        }
    }

    // Connect this to your "+ Add Expense" button in storyboard
    @IBAction func addExpenseTapped(_ sender: UIButton) {
        let amountText  = amountTextField.text ?? ""
        let detailsText = detailsTextField.text ?? ""

        if let error = vm.saveExpense(amountText: amountText, details: detailsText) {
            showAlert(message: error)
        } else {
            // Clear fields and update the remaining label
            amountTextField.text  = ""
            detailsTextField.text = ""
            updateRemainingLabel()
            navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
