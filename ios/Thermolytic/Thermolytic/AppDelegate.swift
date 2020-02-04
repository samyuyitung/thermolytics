
import UIKit
import UserNotifications
import CouchbaseLiteSwift


// Configuration:
let kLoggingEnabled = true
let kSyncEnabled = false
let kSyncEndpoint = "ws://localhost:4984/todo"

// Constants:
let kActivities = ["Stopped", "Offline", "Connecting", "Idle", "Busy"]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        if kLoggingEnabled {
            Database.log.console.level = .verbose
        }
        
        do {
            try startSession(username: "Sam")
        } catch let error as NSError {
            NSLog("Cannot start a session: %@", error)
            return false
        }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        do {
            try DatabaseUtil.closeDatabase();
        } catch {
            Utils.log(at: .Error, msg: "Could not close database \(error)")
        }
    }
    
    // MARK: - Session
    
    func startSession(username:String, withPassword password:String? = nil) throws {
        App.userDB = try DatabaseUtil.openDatabase(name: DatabaseUtil.USER_DB)
        
//        SyncGatewayReplicator.startReplication(for: username, database: DatabaseUtil.shared)
        showApp()
    }
    
    func showApp() {
        guard let root = window?.rootViewController, let storyboard = root.storyboard else {
            return
        }
        
        let controller = storyboard.instantiateInitialViewController()
        window!.rootViewController = controller
    }
}
