//
//  MoviesResult.swift
//  31Cinema
//
//  Created by Gideon Benz on 06/05/19.
//  Copyright © 2019 Gideon Benz. All rights reserved.
//

import Foundation

struct MoviesResult {
    let title: String
    let voteAverage: Double
    let popularity: Double
    let releaseDate: String
    let originalLanguage: String
    let overview: String
    let imageString: String
    
    private struct resultKeys {
        static let title = "original_title"
        static let voteAverage = "vote_average"
        static let releaseDate = "release_date"
        static let originalLanguage = "original_language"
        static let overview = "overview"
        static let imageString = "poster_path"
        static let popularity = "popularity"
    }
    
    init?(json: JSON) {
        guard let title = json[resultKeys.title] as? String,
            let voteAverage = json[resultKeys.voteAverage] as? Double,
            let popularity = json[resultKeys.popularity] as? Double,
            let releaseDate = json[resultKeys.releaseDate] as? String,
            let originalLanguage = json[resultKeys.originalLanguage] as? String,
            let overview = json[resultKeys.overview] as? String,
            let imageString = json[resultKeys.imageString] as? String
            else { return nil }
        
        self.title = title
        self.voteAverage = voteAverage
        self.popularity = popularity
        self.releaseDate = releaseDate
        self.originalLanguage = originalLanguage
        self.overview = overview
        self.imageString = imageString
    }
}
