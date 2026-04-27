//
//  IntervalVC.swift
//  SIGOApplication
//
//  Created by training2 on 4/28/26.
//
import UIKit

class IntervalVC: UIViewController {

    // Connect these in storyboard
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var savePercentageTextField: UITextField!

    var vm: BudgetViewModel!   // passed from BudgetVC via prepare(for:)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set date pickers to date-only mode
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode   = .date
        // Default end date to one week from now
        endDatePicker.date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }

    // Connect this to your "Start Interval" button in storyboard
    @IBAction func startIntervalTapped(_ sender: UIButton) {
        let budgetText  = budgetTextField.text ?? ""
        let saveText    = savePercentageTextField.text ?? ""
        let startDate   = startDatePicker.date
        let endDate     = endDatePicker.date

        if let error = vm.saveInterval(startDate: startDate,
                                       endDate: endDate,
                                       budgetText: budgetText,
                                       savePercentageText: saveText) {
            showAlert(message: error)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

