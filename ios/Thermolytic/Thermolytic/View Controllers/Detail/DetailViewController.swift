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
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var coreTempChart: LineChartView!
    @IBOutlet weak var heartRateChart: LineChartView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var notesTableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    
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
    
    var notes: [Result] = [] {
        didSet {
            notesTableView.reloadData()
        }
    }
    
    var coreTempPoints: [ChartDataEntry] = []
    var heartRatePoints: [ChartDataEntry] = []
    
    var uid: String = ""
    
    override func viewDidLoad() {
        self.title = "Player"

        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        setUserQuery()
        setDataQuery()
        setNotesQuery()
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize = CGSize(width: self.contentView.frame.width, height: self.contentView.frame.height)
    }
    
    func setUserQuery() {
        let userQuery = QueryBuilder
            .select(Athlete.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(
                BaseDocument.type.expression.equalTo(Expression.string(Athlete.TYPE))
                    .and(Athlete.id.expression.equalTo(Expression.string(uid)))
        )
        userQuery.simpleListener({rows in
            if let first = rows.first {
                self.athlete = first
            }
        })
    }
    
    func setDataQuery() {
        
        var sessionName = RecordingSessionManager.shared.sessionName
            
        if sessionName == nil  {
            do {
                let row = try QueryBuilder
                    .select(BioFrame.session.selectResult)
                    .from(DataSource.database(DatabaseUtil.shared))
                    .where(BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE))
                        .and(BioFrame.uid.expression.equalTo(Expression.string(uid))))
                    .orderBy(Ordering.expression(BioFrame.createdAt.expression).ascending())
                    .limit(Expression.int(1))
                .execute()
                
                sessionName = row.allResults().first?.string(forKey: BioFrame.session.key)
            } catch {
                Utils.log(msg: error.localizedDescription)
            }
        }
        
        guard sessionName != nil else {
            Utils.log(at: .Error, msg: "Nil session name")
            return
        }
        
        let dataQuery = QueryBuilder
            .select(BioFrame.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(
                BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE))
                    .and(BioFrame.uid.expression.equalTo(Expression.string(uid)))
                    .and(BioFrame.session.expression.equalTo(Expression.string(sessionName)))
        ).orderBy(Ordering.expression(BioFrame.createdAt.expression).ascending())
        dataQuery.simpleListener({ rows in
            self.data = rows
        })
    }
    
    func setNotesQuery() {
        QueryBuilder
            .select(PlayerNote.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Expression.string(PlayerNote.TYPE))
                .and(PlayerNote.uid.expression.equalTo(Expression.string(uid))))
            .orderBy(Ordering.expression(PlayerNote.createdAt.expression).descending())
            .simpleListener { rows in
                self.notes = rows
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add" {
            let vc = segue.destination as! AddNoteModalViewController
            vc.uid = self.uid
        }
    }
}

extension DetailViewController {
    func updateUserInfo() {
        guard let athlete = self.athlete else {
            return
        }
        self.nameLabel.text = athlete.string(forKey: Athlete.name.key) ?? ""
        self.numberPositionLabel.text = "#\(athlete.int(forKey: Athlete.number.key)) \(athlete.string(forKey: Athlete.position.key) ?? "")"
        self.classificationLabel.text = "Classification: \(athlete.float(forKey: Athlete.classification.key))"
        self.weightLabel.text = "Max HR: \(athlete.int(forKey: Athlete.maxHr.key))"
        self.ageLabel.text = "Thershold Core: \(athlete.float(forKey: Athlete.thresholdTemp.key))℃"
    }
}


extension DetailViewController {
    func updateData() {
        if let latest = self.data.last {
            self.upateMainCard(with: latest)
        }
    }
    
    func upateMainCard(with latest: Result) {
        
        self.coreTempLabel.text = "\(latest.float(forKey: BioFrame.predictedCoreTemp.key).print(to: 1))℃"
        
        let hr = latest.float(forKey: BioFrame.heartRate.key)
        let maxHr = latest.float(forKey: Athlete.maxHr.key)
        
        let percentHr = hr * 100.0 / (maxHr != 0 ? maxHr : Float(Athlete.maxHrDefault))
        
        self.hrPercentLabel.text = "\(Int(percentHr))%"
        self.hrBpmLabel.text = "[ \(latest.int(forKey: BioFrame.heartRate.key)) bpm ]"
    }
}

extension DetailViewController {
    
    func setupLine(for entries: [ChartDataEntry]) -> LineChartDataSet {
        let line = LineChartDataSet(entries: entries, label: "")
        line.drawCirclesEnabled = false
        line.drawValuesEnabled = false
        line.drawFilledEnabled = true
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
        
        guard !data.isEmpty, data.count >= coreTempPoints.count else {
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
        coreTempChart.leftAxis.axisMinimum = 34
        coreTempChart.leftAxis.axisMaximum = 36
        coreTempChart.leftAxis.drawGridLinesEnabled = false
        

        configureChart(chart: heartRateChart, data: heartRatePoints)
        heartRateChart.leftAxis.addLimitLine(ChartLimitLine(limit: 150))
        heartRateChart.leftAxis.axisMaximum = 200
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerNoteTabelViewCell") as! PlayerNoteTabelViewCell
        cell.configure(for: notes[indexPath.row])
        return cell
    }
}
