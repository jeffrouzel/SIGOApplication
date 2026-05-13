//
//  ExpenseVC.swift
//  SIGOApplication
//
//  Created by training2 on 4/28/26.
//
import UIKit

class ExpenseVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var remainingBalView: UIView!
    @IBOutlet weak var lbl_remaining: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!

    @IBOutlet weak var btn_addExpense: UIButton!
    var vm: BudgetViewModel!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    private func updateUI() {
        view.setGradientBackground(isDay: true)
        remainingBalView.styleAsCard()
        remainingBalView.layer.borderWidth = 5
        remainingBalView.layer.borderColor = UIColor.systemOrange.cgColor
        
        lbl_remaining.text = "₱\(String(format: "%.2f", vm.remaining))"

        // Change text color of remaining bal based on budget status
        switch vm.budgetStatus {
        case .noInterval:
            lbl_remaining.textColor = .systemGray
        case .onBudget:
            lbl_remaining.textColor = .systemGreen
        case .onSaveGoal:
            lbl_remaining.textColor = UIColor(red: 0.6, green: 0.8, blue: 0.0, alpha: 1)  // lime green
        case .nearingBudgetLimit:
            lbl_remaining.textColor = .systemYellow
        case .onBudgetLimit:
            lbl_remaining.textColor = .systemRed
        case .overBudget:
            lbl_remaining.textColor = .systemGray
        }
        
        btn_addExpense.styleAsFloatingButton()
    }

    // MARK: - ADD AN EXPENSE ACTION (Button)
    @IBAction func addExpenseTapped(_ sender: UIButton) {
        let amountText  = amountTextField.text ?? ""
        let detailsText = detailsTextField.text ?? ""

        if let error = vm.saveExpense(amountText: amountText, details: detailsText) {
            showAlert(message: error)
        } else {
            // Clear fields and update the remaining label
            amountTextField.text  = ""
            detailsTextField.text = ""
            updateUI()
            navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
