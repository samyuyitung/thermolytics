//
//  NameSessionModalViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-25.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit

class NameSessionModalViewController: UIViewController {
    
    @IBAction func backgroundPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    lazy var typePicker: UIPickerView = {
        let view = UIPickerView()
        view.delegate = self
        view.dataSource = self
        view.selectRow(0, inComponent: 0, animated: false)
        return view
    }()

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sessionTypeField: UITextField!
    
    @IBAction func startSessionPressed(_ sender: Any) {
        if let name = textField.validateString(),
            let type = sessionTypeField.validateString(),
            let typeEnum = BioFrame.SessionType.init(rawValue: type){
            RecordingSessionManager.shared.startSession(named: name, type: typeEnum)
            self.dismiss(animated: true)
        }
    }
    
    override func viewDidLoad() {
        sessionTypeField.inputView = typePicker
    }
}


extension NameSessionModalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return BioFrame.SessionType.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sessionTypeField.text = BioFrame.SessionType.allCases[row].rawValue
    }
}
