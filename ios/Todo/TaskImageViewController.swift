//
//  TaskImageViewController.swift
//  Todo
//
//  Created by Pasin Suriyentrakorn on 2/9/16.
//  Copyright © 2016 Couchbase. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class TaskImageViewController: UIViewController, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    var database: Database!
    var taskID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get database:
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.database
        
        reload()
    }

    // MARK: - Action
    
    @IBAction func editAction(_ sender: AnyObject) {
        Ui.showImageActionSheet(on: self, imagePickerDelegate: self, onDelete: {
            self.deleteImage()
        })
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        dismissController()
    }
    
    func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        updateImage(image: info["UIImagePickerControllerOriginalImage"] as! UIImage)
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Database
    
    func reload() {
        let task = database.document(withID: taskID)!
        if let blob = task.blob(forKey: "image"), let content = blob.content {
            imageView.image = UIImage(data: content)
        } else {
            imageView.image = nil
        }
    }
    
    func updateImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            Ui.showMessage(on: self, title: "Error", message: "Invalid image format")
            return
        }
        
        do {
            let task = database.document(withID: taskID)!.toMutable()
            task.setValue(Blob(contentType: "image/jpg", data: imageData), forKey: "image")
            try database.saveDocument(task)
            reload()
        } catch let error as NSError {
            Ui.showError(on: self, message: "Couldn't update image", error: error)
        }
    }
    
    func deleteImage() {
        do {
            let task = database.document(withID: taskID)!.toMutable()
            task.setValue(nil, forKey: "image")
            try database.saveDocument(task)
            reload()
        } catch let error as NSError {
            Ui.showError(on: self, message: "Couldn't delete image", error: error)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
