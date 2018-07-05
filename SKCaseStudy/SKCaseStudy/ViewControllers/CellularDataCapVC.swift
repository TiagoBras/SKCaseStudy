//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

enum DataMeasurement {
    case megabyte
    case gigabyte
    
    var text: String {
        switch self {
        case .megabyte: return "MB"
        case .gigabyte: return "GB"
        }
    }
}

class CellularDataCapVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataCapValue = 200
        dataMeasurement = .megabyte
        updateDataCapLabel()
        updateUsageLabel()
    }
    
    private func updateDataCapLabel() {
        dataCapLabel.text = "\(dataCapValue)\(dataMeasurement.text)"
    }
    
    private func updateUsageLabel() {
        let monthName = usageDateFormatter.string(from: Date())
        
        usageLabel.text = "Usage for \(monthName): 0 MB"
    }
    
    var onConfirmation: (CellularDataCapVC) -> () = { _ in }
    
    var dataCapValue: Int {
        get {
            guard isViewLoaded else { return 0 }
            
            let digits = (0..<dataMeasurementComponent).map { component in
                return self.dataCapPickerView.selectedRow(inComponent: component)
            }
            
            var total = 0
            var modifier = Int(pow(10.0, Double(digits.count) - 1.0))
            
            for digit in digits {
                total += digit * modifier
                modifier /= 10
            }
            
            return total
        }
        set {
            guard isViewLoaded else { return }
            
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumIntegerDigits = dataMeasurementComponent
            
            let max = Int(String(repeating: "9", count: dataMeasurementComponent))!
            let value: Int = MathHelper.clamp(value: newValue, min: 0, max: max)
            guard let valueString = numberFormatter.string(from: NSNumber(value: value)) else { return }
            let digits = valueString.compactMap({ Int(String($0)) })
            
            for (component, digit) in digits.enumerated() {
                dataCapPickerView.selectRow(digit, inComponent: component, animated: true)
            }
        }
    }
    
    var dataMeasurement: DataMeasurement {
        get {
            guard isViewLoaded else { return kDataMeasurementsAvailable.first! }
            
            let selected = dataCapPickerView.selectedRow(inComponent: dataMeasurementComponent)
            
            return kDataMeasurementsAvailable[selected]
        }
        set {
            guard isViewLoaded, let index = kDataMeasurementsAvailable.index(of: newValue) else {
                return
            }
            
            dataCapPickerView.selectRow(index, inComponent: dataMeasurementComponent, animated: true)
        }
    }
    
    lazy var usageDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("LLLL")
        
        return dateFormatter
    }()
    
    // Mark: Private Fields
    fileprivate var dataMeasurementComponent: Int {
        return kNumberOfComponents - 1
    }
    
    fileprivate let kDataMeasurementsAvailable: [DataMeasurement] = [.megabyte, .gigabyte]
    fileprivate let kNumberOfComponents = 5
    
    // Mark: Outlets
    @IBOutlet weak var dataCapPickerView: UIPickerView!
    @IBOutlet weak var dataCapLabel: UILabel!
    @IBOutlet weak var usageLabel: UILabel!
    
    // Mark: Actions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Do you want to cancel your data cap change?",
                                      message: nil,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .destructive,
                                      handler: { _ in self.complete() }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        complete()
    }
    
    private func complete() {
        onConfirmation(self)
        
        dismiss(animated: true, completion: nil)
    }
}

extension CellularDataCapVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return kNumberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == dataMeasurementComponent ? kDataMeasurementsAvailable.count : 10
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let text = component == dataMeasurementComponent ? kDataMeasurementsAvailable[row].text : "\(row)"
        
        return NSAttributedString(string: text,
                                  attributes: [.foregroundColor: Color.pickerTextColor])
    }
}

extension CellularDataCapVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateDataCapLabel()
    }
}
