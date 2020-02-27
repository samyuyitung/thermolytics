//
//  DebugViewController.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-30.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift
import MessageUI


class DebugViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func didClickDelete(_ sender: Any) {
        DatabaseUtil.clearAllOf(type: BioFrame.TYPE)
    }
    
    
    func getAllRows() -> String? {
        let userAlias = "athlete"
        let frameAlias = "frame"
        let query = QueryBuilder
            .select(
                 BioFrame.selectAll(from: frameAlias) + Athlete.selectAll(from: userAlias)
        )
            .from(DataSource.database(DatabaseUtil.shared).as(frameAlias))
            .join(
                Join.join(DataSource.database(DatabaseUtil.shared).as(userAlias))
                    .on(
                        BioFrame.uid.expression(from: frameAlias)
                            .equalTo(Athlete.id.expression(from: userAlias))
                )
        )
            .where(
                BaseDocument.type.expression(from: frameAlias).equalTo(Expression.string(BioFrame.TYPE))
                    .and(BaseDocument.type.expression(from: userAlias).equalTo(Expression.string(Athlete.TYPE)))
        ).orderBy(Ordering.expression(BioFrame.createdAt.expression(from: frameAlias)).descending())
        
        do {
            let rows = try query.execute()
            
            let columns = [
                BioFrame.createdAt,
                BioFrame.session,
                BioFrame.heartRate,
                BioFrame.armSkinTemp,
                BioFrame.legSkinTemp,
                BioFrame.avgSkinTemp,
                BioFrame.xAcceleration,
                BioFrame.yAcceleration,
                BioFrame.ambientTemp,
                BioFrame.ambientHumidity,
                BioFrame.predictedCoreTemp,
                Athlete.name,
                Athlete.classification,
                Athlete.weight,
            ].map { it in it.key }
            return DataExporter.writeFile(named: "test.csv", with: rows.allResults(), columns: columns)
        } catch {
            Utils.log(at: .Error, msg: error.localizedDescription)
            return nil
        }
    }
    
    
    
    
    @IBAction func didAddRows(_ sender: Any) {
        if let filePath = getAllRows() {
            //Check to see the device can send email.
            if( MFMailComposeViewController.canSendMail() ) {
                
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                // Configure the fields of the interface.
                composeVC.setSubject("Thermolytics Data")
                composeVC.setMessageBody("", isHTML: false)
                
                if let fileData = NSData(contentsOfFile: filePath) {
                    composeVC.addAttachmentData(fileData as Data, mimeType: "text/csv", fileName: "test")
                }
                self.present(composeVC, animated: true, completion: nil)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    var rows: [Result] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        QueryBuilder
            .select(BioFrame.selectAll)
            .from(DataSource.database(DatabaseUtil.shared))
            .where(BaseDocument.type.expression.equalTo(Expression.string(BioFrame.TYPE)))
            .orderBy(Ordering.expression(BioFrame.createdAt.expression).descending())
            .limit(Expression.int(50))
            .simpleListener { res in
                self.rows = res
        }
    }
}

extension DebugViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BioFrameDebuggerCell") as! BioFrameDebuggerCell
        cell.configure(with: rows[indexPath.row])
        return cell
    }
}
