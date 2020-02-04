//
//  User.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2020-01-27.
//  Copyright © 2020 Sam Yuyitung. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class User : BaseDocument {
    
    enum Role: String, CaseIterable {
        case admin = "Admin"
        case physiologist = "Physiologist"
        case player = "Player"
        
        init?(id: Int) {
            switch id {
            case 0: self = .admin
            case 1: self = .physiologist
            case 2: self = .player
            default: return nil
            }
        }
    }
    
    static let TYPE = "user"
    
    static let username = BasicProperty(key: "username")
    static let salt = BasicProperty(key: "salt")
    static let password = BasicProperty(key: "password")
    
    static let athleteId = BasicProperty(key: "athlete-id") // nullable
    static let team = BasicProperty(key: "team")
    static let role = BasicProperty(key: "role")
    
    static let selectAll = [
        type.selectResult,
        createdAt.selectResult,
        username.selectResult,
        salt.selectResult,
        password.selectResult,
        athleteId.selectResult,
        team.selectResult,
        role.selectResult
    ]
    
    static func create(username: String, rawPassword: String, team: String, role: Role) -> MutableDocument {
        let now = Date().timeIntervalSince1970
        let doc = MutableDocument()
        doc.setString(TYPE, forKey: self.type.key)
        doc.setDouble(now, forKey: self.createdAt.key)
        
        doc.setString(username, forKey: self.username.key)
        
        let salt = AuthenticationUtil.generateSalt()
        doc.setString(salt, forKey: self.salt.key)
        
        let hashedPassword = AuthenticationUtil.hash(password: rawPassword, salt: salt)
        doc.setString(hashedPassword, forKey: self.password.key)
        doc.setString(team, forKey: self.team.key)
        doc.setString(role.rawValue, forKey: self.role.key)
        
        return doc
    }
    
    static func getUserBy(username: String) -> Result? {
        do {
            let rows = try QueryBuilder
                .select(User.selectAll)
                .from(DataSource.database(App.userDB))
                .where(User.username.expression.equalTo(Expression.string(username)))
                .execute()
            return rows.next()
        } catch {
            return nil
        }
    }
    
}
