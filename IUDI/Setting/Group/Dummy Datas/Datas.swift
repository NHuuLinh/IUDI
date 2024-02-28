//
//  Datas.swift
//  IUDI
//
//  Created by Quoc on 28/02/2024.
//

import Foundation

// MARK: - GroupData
struct GroupData: Codable {
    let data: [Datum]?
    let state: Int?
}

// MARK: - Datum
struct Datum: Codable {
    let createAt: String?
    let groupID: Int?
    let groupName: String?
    let userID: Int?
    let avatarLink: String?
    let userNumber: Int?

    enum CodingKeys: String, CodingKey {
        case createAt = "CreateAt"
        case groupID = "GroupID"
        case groupName = "GroupName"
        case userID = "UserID"
        case avatarLink, userNumber
    }
}

    
    
