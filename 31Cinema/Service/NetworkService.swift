//
//  NetworkService.swift
//  31Cinema
//
//  Created by Gideon Benz on 06/05/19.
//  Copyright © 2019 Gideon Benz. All rights reserved.
//

import Foundation

enum UserService {
    case discover()
}

enum NetworkingError: Error {
    case httpsNotFounded
    case requestFailed
}

class NetworkService {
    //Sample URL https://api.themoviedb.org/3/discover/movie?api_key=951351069b0280915d1febceffa9cd0f&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1
    let movieAPI: String
    let movieBaseURL: URL?
    
    init() {
        movieAPI = "951351069b0280915d1febceffa9cd0f"
        movieBaseURL = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(movieAPI)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1")
    }
    
    func getMovieService(completion: @escaping (MoviesObjects?) -> Void) {
        guard let movieBaseURL = movieBaseURL else { return }
        let request = URLRequest(url: movieBaseURL)
        let networkProcessor = NetworkProcessor(request: request)
        networkProcessor.downloadJSONFromURL { (json) in
            if let json = json {
                let moviesObjects = MoviesObjects(json: json)
                completion(moviesObjects)
            }
        }
    }
}
