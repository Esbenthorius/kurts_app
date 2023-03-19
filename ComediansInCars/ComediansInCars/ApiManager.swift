//
//  ApiManager.swift
//  ComediansInCars
//
//  Created by Esben Thorius on 19/03/2023.
//

import Foundation

struct LoginRequest: Encodable {
    let user: String
    let password: String
}

struct LoginResponse: Decodable {
    // Define properties of response, if any
    let message: String
}
extension LoginResponse: Equatable {}

struct AddFriendRequest: Encodable {
    let currentUser: String
    let friend: String
}

struct AddFriendResponse: Decodable {
    let message: String
}
extension AddFriendResponse: Equatable {}

struct Friend: Codable {
    let name: String
    let active: Bool
}

struct APIResponse<T: Codable>: Codable {
    let message: String?
    let data: T?
}

class APIManager {
    let base_url = "http://127.0.0.1:8000/"
    func login(user: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let url = URL(string: base_url + "login?user=\(user)&password=\(password)")!

        let session = URLSession.shared

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            guard let responseData = data else {
                completion(.failure(APIError.invalidData))
                return
            }

            do {
                let decoder = JSONDecoder()
                let loginResponse = try decoder.decode(LoginResponse.self, from: responseData)
                print(loginResponse)
                if loginResponse.message == "success" {
                    completion(.success(loginResponse))
                    print("succss")
                } else {
                    completion(.failure(APIError.invalidData))
                    print("not found")
                }
            } catch {
                completion(.failure(error))
                print("failure")
            }
        }

        task.resume()
    }
    
    func create_user(user: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let url = URL(string: base_url + "register?user=\(user)&password=\(password)")!

        let session = URLSession.shared

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            guard let responseData = data else {
                completion(.failure(APIError.invalidData))
                return
            }

            do {
                let decoder = JSONDecoder()
                let loginResponse = try decoder.decode(LoginResponse.self, from: responseData)
                print(loginResponse)
                if loginResponse.message == "success" {
                    completion(.success(loginResponse))
                    print("succss")
                } else {
                    completion(.failure(APIError.invalidData))
                    print("not found")
                }
            } catch {
                completion(.failure(error))
                print("failure")
            }
        }

        task.resume()
    }
    

    func addFriend(friend: String, currentUser: String,completion: @escaping (Result<AddFriendResponse, Error>) -> Void) {
            let url = URL(string: base_url + "addfriend?friend=\(friend)&currentUser=\(currentUser)")!

            let session = URLSession.shared

            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }

                guard let responseData = data else {
                    completion(.failure(APIError.invalidData))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let add = try decoder.decode(AddFriendResponse.self, from: responseData)
                    print(add)
                    if add.message == "success" {
                        completion(.success(add))
                        print("succss")
                    } else {
                        completion(.failure(APIError.invalidData))
                        print("not found")
                    }
                } catch {
                    completion(.failure(error))
                    print("failure")
                }
            }

            task.resume()
        }

    func getFriends(forUser user: String, completion: @escaping (Result<[Friend], Error>) -> Void) {
        guard let url = URL(string: base_url + "getfriends?user=\(user)") else {
            completion(.failure(APIError.invalidData))
            print("failure -1")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("failure 0")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("failure 1")
                completion(.failure(APIError.invalidData))
                return
            }

            do {
                let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let message = responseDict?["message"] as? String {
                    if message == "success" {
                        if let friendsArray = responseDict?["friends"] as? [[String: Any]] {
                            let friends = friendsArray.map { friendDict -> Friend in
                                let name = friendDict["name"] as? String ?? ""
                                let active = friendDict["active"] as? Bool ?? false
                                return Friend(name: name, active: active)
                            }
                            completion(.success(friends))
                        } else {
                            completion(.failure(APIError.invalidData))
                        }
                    } else {
                        completion(.failure(APIError.invalidResponse))
                    }
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
    func setActivity(user: String, active: Bool, completion: @escaping (Result<APIResponse<String>, Error>) -> Void) {
        guard let url = URL(string: base_url + "setactivity") else {
            completion(.failure(APIError.invalidData))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["user": user, "active": active] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.invalidData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(APIResponse<String>.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }



}

enum APIError: Error {
    case invalidResponse
    case invalidData
}
