//
//  NetworkProcessor.swift
//  31Cinema
//
//  Created by Gideon Benz on 06/05/19.
//  Copyright © 2019 Gideon Benz. All rights reserved.
//

import Foundation
typealias JSON = [String : Any]
typealias arrayJSON = [[String : Any]]

public let NetworkingErrorDomain = "\(Bundle.main.bundleIdentifier!).NetworkingError"
public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError: Int = 20

class NetworkProcessor {
    let request: URLRequest
    
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session = URLSession(configuration: self.configuration)
    
    init(request: URLRequest) {
        self.request = request
    }
    
    typealias JSONHandler = (JSON?, HTTPURLResponse?, Error?) -> Void
    typealias DataHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    
    func downloadJSONFromURL (_ completion: @escaping ((JSON?) -> Void)) {
        let dataTask = session.dataTask(with: self.request) { (data, response, error) in
            if error == nil {
                if let httpResponse = response as? HTTPURLResponse{
                    switch httpResponse.statusCode {
                        
                    case 200: if let data = data {
                        do {
                            let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                            completion(jsonDictionary)
                            
                        } catch let error as NSError {
                            print("Error processing json data: \(error.localizedDescription)")}
                        }
                        
                    default: print("HTTP Response Code: \(httpResponse.statusCode)")
                    }
                }
            } else {print("Error processing dataTask: \(String(describing: error?.localizedDescription))")}
        }
        dataTask.resume()
    }
    //image
    //https://image.tmdb.org/t/p/w500/
    //
    func downloadDataFromURL (_ completion: @escaping DataHandler) {
        let dataTask = session.dataTask(with: self.request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let userInfo = [NSLocalizedDescriptionKey : NSLocalizedString("Missing HTTP Response", comment: "")]
                let error = NSError(domain: NetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error as Error)
                return
            }
            
            if data == nil {
                if let error = error {
                    completion(nil, httpResponse, error)
                }
            } else {
                switch httpResponse.statusCode {
                case 200:
                    completion(data, httpResponse, nil)
                default:
                    print("Received HTTP response code: \(httpResponse.statusCode) - was not handled in NetworkingProcessor.swift")
                }
            }
        }
        dataTask.resume()
    }
    
//    func downloadJSONWithMoya(_ completion: @escaping JSONe) {
//        userProvider.request(.discover()) { (movies) in
//            switch movies {
//            case .success(let movies):
//                do {
//                    let jsonDictionary = try JSONSerialization.jsonObject(with: movies.data, options: .mutableContainers)
//                    print(jsonDictionary)
//                    completion(jsonDictionary as? [String : Any])
//                }
//                catch let error as NSError {
//                    print("Failed JSON Serialization: \(error.localizedDescription)")
//                }
//            case .failure(let error):
//                print("Error Requesting Moya: \(error.localizedDescription)")
//            }
//        }
//    }
}
