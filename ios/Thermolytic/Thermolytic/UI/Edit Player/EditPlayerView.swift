//
//  EditPlayerView.swift
//
//
//  Created by Sam Yuyitung on 2020-01-21.
//

import UIKit

struct EditPlayerFields {
    var name: String = ""
    var number: Int = -1
    var dob: Date = Date()
    var classification: Athlete.Classification = .one
    var weight: Float = -1
    var position: Athlete.Position = .forward
    var height: Float = -1
    var maxHr: Int = 160
    var thresholdTemp: Float = 39.5
    var maxSpeed: Float = 10.0
}

protocol EditPlayerViewDelegate {
    func onClosePressed()
    func onAddPlayerPressed(with fields: EditPlayerFields?)
}


@IBDesignable
class EditPlayerView : UIView {
    
    var delegate: EditPlayerViewDelegate? = nil
    let nibName = "EditPlayerView"
    var contentView: UIView?
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.delegate?.onClosePressed()
    }
    
    @IBAction func addPlayerPressed(_ sender: Any) {
        let fields = self.getValues()
        self.delegate?.onAddPlayerPressed(with: fields)
    }
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var classificationField: UITextField!
    @IBOutlet weak var positionField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var maxHrField: UITextField!
    @IBOutlet weak var thresholdTempField: UITextField!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    let dateFormatter: DateFormatter = {
        let d = DateFormatter()
        d.dateFormat = "MM/dd/yyyy"
        
        return d
    }()
    
    
    lazy var dobDatePickerView: UIDatePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .date
        view.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        return view
    }()
    
    lazy var classificationPickerView: UIPickerView = {
        let view = UIPickerView()
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    lazy var positionPickerView: UIPickerView = {
        let view = UIPickerView()
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
        
        dobField.inputView = dobDatePickerView
        classificationField.inputView = classificationPickerView
        positionField.inputView = positionPickerView
        
        thresholdTempField.text = "\(Athlete.thresholdTempDefault)"
        maxHrField.text = "\(Athlete.maxHrDefault)"
        
        addButton.layer.cornerRadius = 8
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        dobField.text = dateFormatter.string(from: sender.date)
    }
    
    func setupForType(isAdding: Bool) {
        
        title.isHidden = !isAdding
        addButton.isHidden = !isAdding
        closeButton.isHidden = !isAdding
    }
    
    
    func load(with values: EditPlayerFields) {
        let nameParts = values.name.components(separatedBy: " ")
        firstNameField.text = nameParts.first ?? ""
        lastNameField.text = nameParts.last ?? ""
        numberField.text = String(values.number)
        dobField.text = dateFormatter.string(from: values.dob)
        dobDatePickerView.date = values.dob
        weightField.text = String(values.weight)
        
        let classification = values.classification.val()
        classificationField.text = String(classification)
        classificationPickerView.selectRow(Int(classification / 0.5 - 1), inComponent: 0, animated: false)
        
        let pos = values.position
        positionField.text = pos.rawValue
        positionPickerView.selectRow(pos == .forward ? 0 : 1, inComponent: 0, animated: false)
        
        heightField.text = String(values.height)
        maxHrField.text = String(values.maxHr)
        thresholdTempField.text = String(values.thresholdTemp)
    }
    
    func getValues() -> EditPlayerFields? {
        var values = EditPlayerFields()
        var hasError = false
        
        if let classificationNum = classificationField.validateFloat(),
            let classification = Athlete.Classification.init(rawValue: classificationNum) {
            values.classification = classification
        } else {
            hasError = true
        }
        
        if let positionString = positionField.validateString(),
            let position = Athlete.Position.init(rawValue: positionString) {
            values.position = position
        } else {
            hasError = true
        }
        
        if let name = firstNameField.validateString() {
            values.name = name
        } else {
            hasError = true
        }
        if let name = lastNameField.validateString() {
            values.name = "\(values.name) \(name)"
        } else {
            hasError = true
        }
        
        if let number = numberField.validateInt() {
            values.number = number
        } else {
            hasError = true
        }
        if let dob = dobField.validateString(), let date = dateFormatter.date(from: dob) {
            values.dob = date
        } else {
            hasError = true
        }
        if let weight = weightField.validateFloat() {
            values.weight = weight
        } else {
            hasError = true
        }
        
        if let height = heightField.validateFloat() {
            values.height = height
        } else {
            hasError = true
        }
        
        if let maxHr = maxHrField.validateInt() {
            values.maxHr = maxHr
        } else {
            hasError = true
        }
        
        if let temp = thresholdTempField.validateFloat() {
            values.thresholdTemp = temp
        } else {
            hasError = true
        }
        
        
        
        if hasError {
            return nil
        } else {
            return values
        }
    }
}

extension EditPlayerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == classificationPickerView {
            return Athlete.Classification.allCases.count
        } else if pickerView == positionPickerView {
            return Athlete.Position.allCases.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == classificationPickerView {
            return Athlete.Classification.allCases[row].rawValue.print(to: 1)
        } else if pickerView == positionPickerView {
            return Athlete.Position.allCases[row].rawValue
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == classificationPickerView {
            classificationField.text = Athlete.Classification.allCases[row].rawValue.print(to: 1)
        } else if pickerView == positionPickerView {
            positionField.text = Athlete.Position.allCases[row].rawValue
        }
    }
}

extension UITextField {
    
    func validateString() -> String? {
        clearError()
        if let text = text, !text.isEmpty {
            return text
        }
        setError()
        return nil
    }
    
    func validateInt() -> Int? {
        clearError()
        if let num = Int(text ?? "") {
            return num >= 0 ? num : nil
        }
        setError()
        return nil
    }
    
    func validateFloat() -> Float? {
        clearError()
        if let num = Float(text ?? "") {
            return num >= 0 ? num : nil
        }
        setError()
        return nil
    }
    
    func setError() {
        self.backgroundColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: 0.1)
    }
    
    func clearError() {
        self.backgroundColor = .clear
    }
}
