//
//  IntervalVC.swift
//  SIGOApplication
//
//  Created by training2 on 4/28/26.
//
import UIKit

class IntervalVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var titleView: UIView!
    @IBOutlet var inputViews: [UIView]!
    @IBOutlet weak var saveAmountView: UIView!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var savePercentagePicker: UIPickerView!   // ← changed to picker
    @IBOutlet weak var lbl_saveAmount: UILabel!              // ← shows calculated amount
    @IBOutlet weak var btn_StartInterval: UIButton!
    
    var vm: BudgetViewModel!

    // Percentage options 0-100 in steps of 5
    private let percentageOptions = stride(from: 0, through: 100, by: 5).map { $0 }
    private var selectedPercentage: Int = 20  // default 20%

    override func viewDidLoad() {
        super.viewDidLoad()
        assignDelegatesandDataSources()
        inputsSetup()
        updateUI()
    }
    // MARK: - Setup
    private func assignDelegatesandDataSources() {
        savePercentagePicker.delegate   = self
        savePercentagePicker.dataSource = self
        budgetTextField.delegate        = self
    }
    private func inputsSetup(){
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode   = .date
        endDatePicker.date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

        // Set picker to default 20% — find its index
        if let defaultIndex = percentageOptions.firstIndex(of: 20) {
            savePercentagePicker.selectRow(defaultIndex, inComponent: 0, animated: false)
        }
        // Number only keyboard for budget
        budgetTextField.keyboardType = .decimalPad
        
        updateSaveAmount()
    }
    // MARK: - UI Modifications
    private func updateUI(){
        view.setGradientBackground(isDay: true)
        titleView.styleAsCardOrange()
        inputViews.forEach{$0.styleAsCard()}
        saveAmountView.styleAsCardOrange()
        
        btn_StartInterval.styleAsFloatingButton()
    }
    // MARK: - Update calculated save amount label
    private func updateSaveAmount() {
        guard let budgetText = budgetTextField.text,
              let budget = Double(budgetText), budget > 0 else {
            lbl_saveAmount.text = "₱0.00"
            return
        }
        let saveAmount = budget * (Double(selectedPercentage) / 100)
        lbl_saveAmount.text = "₱\(String(format: "%.2f", saveAmount))"
    }

    // MARK: - Create interval
    @IBAction func startIntervalTapped(_ sender: UIButton) {
        let budgetText = budgetTextField.text ?? ""
        let saveText   = String(selectedPercentage)
        let startDate  = startDatePicker.date
        let endDate    = endDatePicker.date

        if let error = vm.validateInterval(startDate: startDate,
                                           endDate: endDate,
                                           budgetText: budgetText,
                                           savePercentageText: saveText) {
            showAlert(message: error)
            return
        }

        showConfirmation(budget: budgetText,
                         saveText: saveText,
                         startDate: startDate,
                         endDate: endDate)
    }

    private func showConfirmation(budget: String, saveText: String, startDate: Date, endDate: Date) {
        let startDateText = formatDate(startDate)
        let endDateText   = formatDate(endDate)
        let amount = Double(budget) ?? 0
        let save   = amount * (Double(selectedPercentage) / 100)

        let message = """
        Start: \(startDateText)
        End: \(endDateText)
        Budget: ₱\(String(format: "%.2f", amount))
        Save goal: \(selectedPercentage)% (₱\(String(format: "%.2f", save)))

        Is this correct?
        """

        let alert = UIAlertController(title: "Confirm Interval", message: message, preferredStyle: .alert)
        
        let confirmButton = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self else { return }
            // SAVE IF OKAY
            _ = self.vm.saveInterval(startDate: startDate,
                                     endDate: endDate,
                                     budgetText: budget,
                                     savePercentageText: saveText)
            self.navigationController?.popViewController(animated: true)
        }
        confirmButton.setValue(UIColor.systemGreen, forKey: "titleTextColor")
        
        let cancelButton = UIAlertAction(title: "Edit", style: .cancel)
        cancelButton.setValue(UIColor.systemRed, forKey: "titleTextColor")
        
        alert.addAction(confirmButton)
        alert.addAction(cancelButton)
        present(alert, animated: true)
    }
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerView
extension IntervalVC: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return percentageOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(percentageOptions[row])%"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPercentage = percentageOptions[row]
        updateSaveAmount()   // recalculate every time percentage changes
    }
}

// MARK: - UITextFieldDelegate
extension IntervalVC: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Numbers and one decimal point only
        if string.isEmpty { return true }
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        guard string.rangeOfCharacter(from: allowedCharacters) != nil else { return false }
        let currentText = textField.text ?? ""
        if string == "." && currentText.contains(".") { return false }
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateSaveAmount()   // recalculate every time budget changes
    }
}
