//
//  AddPlayerViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-21.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit


class AddPlayerViewController : UIViewController {
    
    @IBOutlet weak var editPlayerView: EditPlayerView!
    
    @IBAction func pressedSubmit(_ sender: Any) {
        
        if let fields = editPlayerView.getValues() {
            let athlete = Athlete.create(from: fields)
            
            DatabaseUtil.insert(doc: athlete)
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    override func viewDidLoad() {
        self.title = "Add Player"
    }
}
