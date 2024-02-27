import Foundation

// MARK: - Welcome
struct UserDataRegister: Codable {
    let registerData: [RegisterData]?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case registerData = "Users"
        case status
    }
}

// MARK: - User
struct RegisterData: Codable {
    let birthDate, birthTime: String?
    let email, fullName: String?
    let gender: String?
    let isLoggedIn: Bool?
    let lastActivityTime: String?
    let lastLoginIP: String?
    let password: String?
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
