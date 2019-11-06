//
//  TestViewController.swift
//  Todo
//
//  Created by Sam Yuyitung on 2019-11-05.
//  Copyright © 2019 Couchbase. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift
import Charts

class TestViewController: UIViewController {
    var dataQuery: Query!
    
    @IBOutlet weak var topChart: LineChartView!
    
    var rows: [Result]? {
        didSet {
            populateTopChart()
        }
    }
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    // MARK: - Button
    @IBAction func moreData(_ sender: Any) {
        if timer?.isValid == true {
            self.timer!.invalidate()
            self.timer = nil
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { _ in
            do {
                let doc = BiometricsFrame.create(ts: Date().timeIntervalSince1970,
                                                heartRate: Float.random(in: 50...100),
                                                skinTemp: Float.random(in: 30.0...40.0),
                                                accelerometer: Accelerometer(x: 1, y: 2, z: 3))
                try DatabaseUtil.shared.saveDocument(doc)
            } catch {
                Utils.log(at: .Error, msg: "Didnt add doc \(error)")
            }
        })
    }

    // MARK: - Database
    
    func load() {
        dataQuery = QueryBuilder
            .select(BiometricsFrame.createdAt.selectResult,
                    BiometricsFrame.heartRate.selectResult,
                    BiometricsFrame.skinTemp.selectResult)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(
                BaseDocument.type.expression.equalTo(Expression.string(BiometricsFrame.TYPE))
            .and(
                BaseDocument.createdAt.expression.greaterThan(Expression.double(Date().addingTimeInterval(-10).timeIntervalSince1970))
            ))
            .orderBy(Ordering.expression(BiometricsFrame.createdAt.expression))
        dataQuery.addChangeListener({change in
            if let error = change.error {
                Utils.log(at: .Error, msg: "Error fetching data -- \(error)")
            }
            if let res = change.results {
                self.rows = res.allResults()
            }
        })
    }
    
    func populateTopChart() {
        let heartRatePts = rows?.map({ (row) -> ChartDataEntry in
            return ChartDataEntry(x: row.double(forKey: BiometricsFrame.createdAt.key),
                                  y: row.double(forKey: BiometricsFrame.heartRate.key))
        })
        let skinTempPts =  rows?.map({ (row) -> ChartDataEntry in
            return ChartDataEntry(x: row.double(forKey: BiometricsFrame.createdAt.key),
                                  y: row.double(forKey: BiometricsFrame.skinTemp.key))
        })

        let data = LineChartData()
        data.addDataSet(LineChartDataSet(entries: heartRatePts, label: "Heart Rate"))
        data.addDataSet(LineChartDataSet(entries: skinTempPts, label: "Skin Temp"))
        
        topChart.data = data

    }
}
