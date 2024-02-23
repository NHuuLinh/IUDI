//
//  UserNetWorkManager.swift
//  IUDI
//
//  Created by LinhMAC on 23/02/2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class UserNetWorkManager {
    static let share = UserNetWorkManager()
    
    func fetchWeatherData(url: String, parameters: [String:Any], completion: @escaping (UserData?) -> Void) {
        let mainUrl = Constant.baseUrl + url
        
        AF.request(mainUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200...299)
            .responseDecodable(of: UserData.self) { response in
                switch response.result {
                    // Xử lý dữ liệu nhận được từ phản hồi (response)
                case .success(let data):
                    let userData = data.self
                    print("success")
                    completion(userData)
                case .failure(let error):
                    completion(nil)
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            let errorMessage = json["message"].stringValue
                            print(errorMessage)
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                        }
                    }
                }
            }
    }
    
}
