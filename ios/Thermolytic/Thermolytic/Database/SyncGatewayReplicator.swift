//
//  SyncGatewayReplicator.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-19.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//


import Foundation
import CouchbaseLiteSwift

class SyncGatewayReplicator {
    
    static var replicator: Replicator!
    static var changeListener: ListenerToken?
    
       // MARK: - Replication
    static func startReplication(for username:String, pw password:String? = "", database: Database) {
           guard kSyncEnabled else {
               return
           }
           
           
           let target = URLEndpoint(url: URL(string: kSyncEndpoint)!)
           let config = ReplicatorConfiguration(database: database, target: target)
           config.continuous = true
           config.authenticator = nil
           
           replicator = Replicator(config: config)
           changeListener = replicator.addChangeListener({ (change) in
               let s = change.status
               let activity = kActivities[Int(s.activity.rawValue)]
               let e = change.status.error as NSError?
               let error = e != nil ? ", error: \(e!.description)" : ""
               NSLog("[Todo] Replicator: \(activity), \(s.progress.completed)/\(s.progress.total)\(error)")
           })
           replicator.start()
       }
       
       static func stopReplication() {
           guard kSyncEnabled else {
               return
           }
           
           replicator.stop()
           replicator.removeChangeListener(withToken: changeListener!)
           changeListener = nil
       }
}
