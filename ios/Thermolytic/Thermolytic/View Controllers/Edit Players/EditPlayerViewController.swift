//
//  EditPlayerViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-21.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class EditPlayerViewController: UIViewController {
    
    @IBOutlet weak var editPlayerView: EditPlayerView!
    
    @IBAction func pressedSubmit(_ sender: Any) {
        
        if let fields = editPlayerView.getValues(), let athlete = athlete {
            Athlete.update(doc: athlete, with: fields)
            DatabaseUtil.insert(doc: athlete)
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func pressedDelete(_ sender: Any) {
        if let athlete = self.athlete {
            let name = athlete.string(forKey: Athlete.name.key) ?? ""
            let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete \(name)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (UIAlertAction) in
                do {
                    Athlete.deleteAllData(for: athlete.id)
                    try DatabaseUtil.deleteDocumentWith(id: athlete.id)
                    self.navigationController?.popToRootViewController(animated: true)
                } catch {
                    Utils.log(at: .Error, msg: "Oof")
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    
    var id: String = ""
    var athlete: MutableDocument? = nil
    
    override func viewDidLoad() {
        self.title = "Edit Player"
        self.athlete = DatabaseUtil.shared.document(withID: id)?.toMutable()
        if let doc = athlete {
            let fields = Athlete.toEditFields(from: doc)
            editPlayerView.load(with: fields)
        }
        editPlayerView.setupForType(isAdding: false)
    }
}
