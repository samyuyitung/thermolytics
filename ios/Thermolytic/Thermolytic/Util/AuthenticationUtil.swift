//
//  AuthenticationUtil.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-27.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

//
// I know that this is not _that_ secure. But for the purpose of
// this project I did not really put in too much beyond basic
// offline password service.

import Foundation
import CouchbaseLiteSwift
import CommonCrypto

class AuthenticationUtil {
    
    static func generateSalt(length: Int = 8) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    static func hash(password: String, salt: String) -> String {
        let string = password + salt
        let hashed = Data(string.utf8).sha256
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    static func isAuthorized(rawPassword: String, salt: String, hashedPassword: String) -> Bool {
        return AuthenticationUtil.hash(password: rawPassword, salt: salt) == hashedPassword
    }
}

extension Data {

    var sha256: Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes({
            _ = CC_SHA256($0, CC_LONG(self.count), &digest)
        })
        return Data(digest)
    }

}
