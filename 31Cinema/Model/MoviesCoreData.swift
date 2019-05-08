//
//  MoviesCoreData.swift
//  31Cinema
//
//  Created by Gideon Benz on 07/05/19.
//  Copyright © 2019 Gideon Benz. All rights reserved.
//

import Foundation

struct MoviesCoreData {
    let title: String
    let overview: String
    let voteAverage: Double
    let popularity: Double
    let originalLanguage: String
    let releaseDate: String
    let image: Data
    let id: Int16
    
    init?(movieCoreData: CurrentMovies) {
        let title = movieCoreData.title
        let overview = movieCoreData.overview
        let voteAverage = movieCoreData.voteAverage
        let popularity = movieCoreData.popularity
        let originalLanguage = movieCoreData.originalLanguage
        let releaseDate = movieCoreData.releaseDate
        let image = movieCoreData.image
        let id = movieCoreData.id
        
        self.title = title ?? ""
        self.overview = overview ?? ""
        self.voteAverage = voteAverage
        self.popularity = popularity
        self.originalLanguage = originalLanguage ?? ""
        self.releaseDate = releaseDate ?? ""
        self.image = (image ?? NSData()) as Data
        self.id = id
    }
}
