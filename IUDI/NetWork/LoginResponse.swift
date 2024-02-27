import Foundation

// MARK: - Welcome
struct UserDataLogin: Codable {
    let jwt, message: String?
    let status: Int?
    let loginData: LoginData?
}

// MARK: - User
struct LoginData: Codable {
    let users: [UserElement]?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case users = "Users"
        case status
    }
}

// MARK: - UserElement
struct UserElement: Codable {
    let birthDate, birthTime: String?
    let email, fullName: String?
    let gender: String?
    let isLoggedIn: Bool?
    let lastActivityTime: String?
    let lastLoginIP, password: String?
    let phone, provinceID: String?
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