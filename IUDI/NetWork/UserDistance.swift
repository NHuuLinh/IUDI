//
//  UserDistance.swift
//  IUDI
//
//  Created by LinhMAC on 29/02/2024.
//

import Foundation
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
    let distance: Double?
    let userID: Int?

    enum CodingKeys: String, CodingKey {
        case distance = "Distance"
        case userID = "UserID"
    }
}
