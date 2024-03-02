//
//  UserDistance.swift
//  IUDI
//
//  Created by LinhMAC on 29/02/2024.
//

import Foundation

// MARK: - UserDistances
struct UserDistances: Codable {
    let distances: [Distance]?
    let userID, status: Int?

    enum CodingKeys: String, CodingKey {
        case distances = "Distances"
        case userID = "UserID"
        case status
    }
}

// MARK: - Distance
struct Distance: Codable {
    let birthDate, birthTime: String?
    let distance: Double?
    let email, fullName: String?
    let gender: String?
    let lastActivityTime: String?
    let provinceID: String?
    let userID: Int?
    let avatarLink: String?

    enum CodingKeys: String, CodingKey {
        case birthDate = "BirthDate"
        case birthTime = "BirthTime"
        case distance = "Distance"
        case email = "Email"
        case fullName = "FullName"
        case gender = "Gender"
        case lastActivityTime = "LastActivityTime"
        case provinceID = "ProvinceID"
        case userID = "UserID"
        case avatarLink
    }
}
