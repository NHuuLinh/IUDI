import Foundation

// MARK: - UserData
struct UserData: Codable {
    let jwt, message: String?
    let status: Int?
    let user: User?
}

// MARK: - User
struct User: Codable {
    let users: [Users]?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case users = "Users"
        case status
    }
}

// MARK: - UserElement
struct Users: Codable {
    let birthDate, birthTime, email, fullName: String?
    let gender: String?
    let isLoggedIn: Bool?
    let lastActivityTime, lastLoginIP, password, phone: String?
    let provinceID: Int?
    let registrationIP: String?
    let role: Bool?
    let userID: Int?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case birthDate = "BirthDate"
        case birthTime = "BirthTime"
        case email = "Email"
        case fullName = "FullName"
        case gender = "Gender"
        case isLoggedIn = "IsLoggedIn"
        case lastActivityTime = "LastActivityTime"
        case lastLoginIP = "LastLoginIP"
        case password = "Password"
        case phone = "Phone"
        case provinceID = "ProvinceID"
        case registrationIP = "RegistrationIP"
        case role = "Role"
        case userID = "UserID"
        case username = "Username"
    }
}


// MARK: - UserElement
struct UserElements: Codable {
    let birthDate, birthTime, email, fullName: String?
    let gender: String?
    let isLoggedIn: Bool?
    let lastActivityTime, lastLoginIP, password, phone: String?
    let provinceID: Int?
    let registrationIP: String?
    let role: Bool?
    let userID: Int?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case birthDate = "BirthDate"
        case birthTime = "BirthTime"
        case email = "Email"
        case fullName = "FullName"
        case gender = "Gender"
        case isLoggedIn = "IsLoggedIn"
        case lastActivityTime = "LastActivityTime"
        case lastLoginIP = "LastLoginIP"
        case password = "Password"
        case phone = "Phone"
        case provinceID = "ProvinceID"
        case registrationIP = "RegistrationIP"
        case role = "Role"
        case userID = "UserID"
        case username = "Username"
    }
}

