//
//  DetailViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-20.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift

class DetailViewController: UIViewController {
    // User Card IBOutlets
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var numberPositionLabel: UITextField!
    @IBOutlet weak var classificationLabel: UITextField!
    @IBOutlet weak var weightLabel: UITextField!
    @IBOutlet weak var ageLabel: UITextField!
    
    // Main Stats IBOutlets
    @IBOutlet weak var coreTempLabel: UILabel!
    @IBOutlet weak var hrPercentLabel: UILabel!
    @IBOutlet weak var hrBpmLabel: UILabel!
    @IBOutlet weak var timeOnCourtLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    @IBOutlet weak var accelerationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    var athlete: Result? = nil {
        didSet {
            updateUserInfo()
        }
    }
    
    var data: [Result] = [] {
        didSet {
            updateData()
        }
    }
    var uid: Int = -10
    
    override func viewDidLoad() {
        self.title = "Player"
        setUserQuery()
        setDataQuery()
    }
    
    func setUserQuery() {
        let userQuery = QueryBuilder
            .select(Athlete.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(
                BaseDocument.type.expression.equalTo(Expression.string(Athlete.TYPE))
                    .and(Athlete.uid.expression.equalTo(Expression.int(uid)))
        )
        userQuery.addChangeListener({change in
            if let error = change.error {
                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
            }
            if let res = change.results?.allResults().first {
                self.athlete = res
            }
        })
    }
    
    func setDataQuery() {
                let dataQuery = QueryBuilder
                    .select(BioFrame.selectAll)
                    .from(DataSource.database(DatabaseUtil.shared))
                    .where(
                        BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE))
                            .and(BioFrame.uid.expression.equalTo(Expression.int(uid)))
                ).orderBy(Ordering.expression(BioFrame.createdAt.expression).descending())
                dataQuery.addChangeListener({change in
                    if let error = change.error {
                        Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
                    }
                    if let res = change.results {
                        self.data = res.allResults()
                    }
                })
    }
}

extension DetailViewController {
    func updateUserInfo() {
        guard let athlete = self.athlete else {
            return
        }
        self.nameLabel.text = athlete.string(forKey: Athlete.name.key) ?? ""
        self.numberPositionLabel.text = "\(athlete.int(forKey: Athlete.uid.key))"
        self.classificationLabel.text = "Classification: <>"
        self.weightLabel.text = "Weight: \(athlete.float(forKey: Athlete.weight.key))"
        self.ageLabel.text = "Age: <>"
    }
}


extension DetailViewController {
    func updateData() {
        if let latest = self.data.last {
            self.upateMainCard(with: latest)
        }
    }
    
    func upateMainCard(with latest: Result) {
        self.coreTempLabel.text = "\(latest.double(forKey: BioFrame.predictedCoreTemp.key).print(to: 1))℃"
        self.hrBpmLabel.text = "[ \(latest.int(forKey: BioFrame.heartRate.key)) bpm ]"
    }
}
