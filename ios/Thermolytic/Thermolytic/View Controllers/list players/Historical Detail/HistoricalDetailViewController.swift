//
//  HistoricalDetailViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-21.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift
import Charts

class HistoricalDetailViewController: TLViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var maxHrLabel: UILabel!
    @IBOutlet weak var coreTempThresholdLabel: UILabel!
    
    @IBOutlet weak var editPlayerButton: UIBarButtonItem!
    
    var athlete: Result? = nil {
        didSet {
            updateUserInfo()
        }
    }
    
    var data: [Result] = [] {
        didSet {
//            updateData()
//            updateCharts()
        }
    }
    
    var coreTempPoints: [ChartDataEntry] = []
    var heartRatePoints: [ChartDataEntry] = []
    
    var uid: String = ""
    
    override func viewDidLoad() {
        
        permissions.append(
            Permissioned(view: editPlayerButton as! UIView, effect: .hide, minLevel: .physiologist)
        )
        self.title = "Historical Player Data"
        
        self.tabBarController?.toolbarItems
//        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)
        
        setUserQuery()
        setDataQuery()
        
    }
    
    func setUserQuery() {
        let userQuery = QueryBuilder
            .select(Athlete.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(
                BaseDocument.type.expression.equalTo(Expression.string(Athlete.TYPE))
                    .and(Athlete.id.expression.equalTo(Expression.string(uid)))
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
//        let dataQuery = QueryBuilder
//            .select(BioFrame.selectAll)
//            .from(DataSource.database(DatabaseUtil.shared))
//            .where(
//                BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE))
//                    .and(BioFrame.uid.expression.equalTo(Expression.int(uid)))
//                    .and(BioFrame.createdAt.expression.greaterThanOrEqualTo(Expression.int64(1578507102)))
//        ).orderBy(Ordering.expression(BioFrame.createdAt.expression).ascending())
//        dataQuery.addChangeListener({change in
//            if let error = change.error {
//                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
//            }
//            if let res = change.results {
//                self.data = res.allResults()
//            }
//        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! EditPlayerViewController
        vc.id = athlete?.getId() ?? ""
    }
}

extension HistoricalDetailViewController {
    func updateUserInfo() {
        guard let athlete = self.athlete else {
            return
        }

        self.nameLabel.text = athlete.string(forKey: Athlete.name.key) ?? ""
        self.positionLabel.text = athlete.string(forKey: Athlete.position.key) ?? "unknown"
        self.classificationLabel.text = "Classification: \(athlete.float(forKey: Athlete.classification.key))"
        self.weightLabel.text = "Weight: \(athlete.float(forKey: Athlete.weight.key))"
        let dob = Date(timeIntervalSince1970: athlete.double(forKey: Athlete.dob.key))
        self.ageLabel.text = "Age: \(dob.yearsFromNow)"
    }
}

/*
extension HistoricalDetailViewController {
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

extension HistoricalDetailViewController {
    
    func setupLine(for entries: [ChartDataEntry]) -> LineChartDataSet {
        let line = LineChartDataSet(entries: entries, label: "")
        line.drawCirclesEnabled = false
        line.drawValuesEnabled = false
        return line
    }
    
    func setupChart(for chart: LineChartView) {
        chart.backgroundColor = .white
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chart.legend.enabled = false
        chart.xAxis.drawGridLinesEnabled = false
        chart.rightAxis.enabled = false
    }
    
    func configureChart(chart: LineChartView, data: [ChartDataEntry]) {
        let line = setupLine(for: data)
        setupChart(for: chart)
        let data = LineChartData()
        data.addDataSet(line)
        chart.data = data
    }
    
    func updateCharts() {
        // Only append the new points
        guard data.count >= coreTempPoints.count else {
            return
        }
        let first = data.first!.int64(forKey: BioFrame.createdAt.key)
        for i in coreTempPoints.count..<data.count {
            let time = Double(data[i].int64(forKey: BioFrame.createdAt.key) - first) / (60)
            coreTempPoints.append(ChartDataEntry(x: time,
                                                 y: data[i].double(forKey: BioFrame.predictedCoreTemp.key)))
            heartRatePoints.append(ChartDataEntry(x: time,
                                                  y: data[i].double(forKey: BioFrame.heartRate.key)))
        }
        
        configureChart(chart: coreTempChart, data: coreTempPoints)
        coreTempChart.leftAxis.addLimitLine(ChartLimitLine(limit: 35.8))
        coreTempChart.leftAxis.axisMaximum = 36
        
        configureChart(chart: heartRateChart, data: heartRatePoints)
        heartRateChart.leftAxis.addLimitLine(ChartLimitLine(limit: 150))
        heartRateChart.leftAxis.axisMaximum = 200
    }
}
 */
