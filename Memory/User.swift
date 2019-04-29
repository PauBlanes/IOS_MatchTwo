//
//  User.swift
//  Memory
//
//  Created by Pau Blanes on 29/4/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import Foundation

class User: Codable {
    var id: String = ""
    var username: String = ""
    var scores:[Int] = []
    
    init(id: String, username: String) {
        self.id = id
        self.username = username
    }
}
