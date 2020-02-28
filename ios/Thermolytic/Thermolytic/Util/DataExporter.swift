//
//  DataExporter.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-02-26.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class DataExporter {
    static func writeFile(named fileName: String, with data: [Result], columns: [String]) -> String? {
        let tempDir = NSTemporaryDirectory()
        let fileUrl = URL(fileURLWithPath: tempDir, isDirectory: true).appendingPathComponent(fileName)
        
        
        let header = columns.joined(separator: ",") + "\n"
        do {
            try header.write(to: fileUrl, atomically: true, encoding: .utf8)
            
            for row in data {
                let msg = columns.map { column -> String in
                    return "\(row.value(forKey: column) ?? "")"
                }.joined(separator: ",") + "\n"
                if let data = msg.data(using: .utf8) {
                    let fileHandle = try FileHandle(forWritingTo: fileUrl)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            }
            
            
            return fileUrl.path
        } catch {
            print("Failed to create file: \(error)")
            return nil
        }
    }
}
