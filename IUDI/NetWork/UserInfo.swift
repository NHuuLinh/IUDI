//
//  UserInfo.swift
//  IUDI
//
//  Created by LinhMAC on 19/03/2024.
//

import Foundation
import KeychainSwift

class UserInfo{
    static let shared = UserInfo()
    let keychain = KeychainSwift()

    private init(){}
    
    func saveUserName(userName: String){
        keychain.set(userName, forKey: "username")
    }
    
    func saveUserPassword(password: String){
        keychain.set(password, forKey: "password")
    }
    
    func saveUserID(userID: String){
        keychain.set(String(userID), forKey: "userID")
    }
    
    func getUserName() -> String?{
        let userName = keychain.get("username")
        return userName
    }
    
    func getUserPassword() -> String?{
        let password = keychain.get("password")
        return password

    }
    
    func getUserID() -> String?{
        let userID = keychain.get("userID")
        return userID

    }
    
}
