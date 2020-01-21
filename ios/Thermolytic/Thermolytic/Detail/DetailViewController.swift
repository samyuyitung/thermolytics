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
import Charts

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
    
    @IBOutlet weak var coreTempChart: LineChartView!
    @IBOutlet weak var heartRateChart: LineChartView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var notesTableView: UITableView!
    
    
    var athlete: Result? = nil {
        didSet {
            updateUserInfo()
        }
    }
    
    var data: [Result] = [] {
        didSet {
            updateData()
            updateCharts()
        }
    }
    
    var coreTempPoints: [ChartDataEntry] = []
    var heartRatePoints: [ChartDataEntry] = []
    
    var uid: Int = -10
    
    override func viewDidLoad() {
        self.title = "Player"
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)

        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        setUserQuery()
        setDataQuery()
        
    }
    
    func setUserQuery() {
        let userQuery = QueryBuilder
            .select(Athlete.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(
                BaseDocument.type.expression.equalTo(Expression.string(Athlete.TYPE))
                    .and(Athlete.number.expression.equalTo(Expression.int(uid)))
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
                    .and(BioFrame.createdAt.expression.greaterThanOrEqualTo(Expression.int64(1578507102)))
        ).orderBy(Ordering.expression(BioFrame.createdAt.expression).ascending())
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
        self.numberPositionLabel.text = "#\(athlete.int(forKey: Athlete.number.key))"
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

extension DetailViewController {
    
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

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let frame: CGRect = tableView.frame
        let button = UIButton(frame: CGRect(x: frame.size.width - 34, y: 10, width: 24, height: 24))
        button.setImage(UIImage(named: "add"), for: .normal)

        button.addTarget(self, action: #selector(addNewNote(_:)), for: .touchUpInside)

        let headerView: UIView = UIView(frame: CGRect(x: 0,y: 0, width: frame.size.width, height: frame.size.height))
        headerView.addSubview(button)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension DetailViewController: UIPopoverPresentationControllerDelegate {
    @objc func addNewNote(_ sender: Any) {

            let vc = UIViewController()
        
            
            vc.modalPresentationStyle = .popover

            vc.preferredContentSize = CGSize(width: 500, height: 200)

            let ppc = vc.popoverPresentationController
            ppc?.permittedArrowDirections = .any
            ppc?.delegate = self
            ppc?.barButtonItem = navigationItem.rightBarButtonItem
            ppc?.sourceView = sender as? UIView

            present(vc, animated: true, completion: nil)
    }
    
    

}
