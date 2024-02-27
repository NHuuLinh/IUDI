import Foundation
import SwiftyJSON
import Alamofire

enum APIError: Error {
    case server(message: String)
    case network(message: String)
}

class APIService {
    static let share = APIService()
    private init() {
        
    }
    func apiHandle<T: Decodable>(method: HTTPMethod = .post, subUrl: String, parameters: [String: Any] = [:], data: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        
        let url = Constant.baseUrl + subUrl
        
        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200...299)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                    print("success")

                case .failure(let error):
                    print(error.localizedDescription)

                    if let data = response.data {
                        do {

                            let json = try JSON(data: data)
                            let errorMessage = json["status"].stringValue
                            completion(.failure(.server(message: errorMessage)))
                        } catch {
                            print("error server")
                            completion(.failure(.server(message: "Unknown error occurred")))
                        }
                    } else {
                        print("error network")
                        completion(.failure(.network(message: error.localizedDescription)))
                    }
                }
            }
    }
    
}
