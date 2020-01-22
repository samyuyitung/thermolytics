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
    var age: Int = -1
    var height: Float = -1
    var weight: Float = -1
    var position: Athlete.Position = .forward
}
@IBDesignable
class EditPlayerView : UIView {
    let nibName = "EditPlayerView"
    var contentView:UIView?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var offenseButton: UIButton!
    @IBOutlet weak var defenseButton: UIButton!
    
    @IBAction func didTapDefense(_ sender: Any) {
        if !defenseButton.isSelected {
            defenseButton.isSelected = true
            offenseButton.isSelected = false
        }
    }
    
    @IBAction func didTapOffense(_ sender: Any) {
        if !offenseButton.isSelected {
            offenseButton.isSelected = true
            defenseButton.isSelected = false
        }
    }
    
    
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
        
        offenseButton.isSelected = true
    }
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    
    func load(with values: EditPlayerFields) {
        nameField.text = values.name
        numberField.text = String(values.number)
        ageField.text = String(values.age)
        heightField.text = String(values.height)
        weightField.text = String(values.weight)
        
        offenseButton.isSelected = values.position == .forward
        defenseButton.isSelected = values.position == .defense
    }
    
    func getValues() -> EditPlayerFields? {
        var values = EditPlayerFields()
        var hasError = false
        
        values.position = offenseButton.state == .selected ? .forward : .defense
        
        if let name = nameField.validateString() {
            values.name = name
        } else {
            hasError = true
        }
        if let number = numberField.validateInt() {
            values.number = number
        } else {
            hasError = true
        }
        if let age = ageField.validateInt() {
            values.age = age
        } else {
            hasError = true
        }
        if let height = heightField.validateFloat() {
            values.height = height
        } else {
            hasError = true
        }
        if let weight = weightField.validateFloat() {
            values.weight = weight
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
