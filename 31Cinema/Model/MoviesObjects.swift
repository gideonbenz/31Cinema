//
//  DiscoverMovies.swift
//  31Cinema
//
//  Created by Gideon Benz on 06/05/19.
//  Copyright © 2019 Gideon Benz. All rights reserved.
//

import Foundation

struct MoviesObjects {
    let movieResult: [MoviesResult?]
    
    init?(json: JSON) {
        guard let result = json["results"] as? arrayJSON else { return nil }
        
        let movieResultObjects = result.map {(MoviesResult(json: $0))}
        self.movieResult = movieResultObjects
    }
}
