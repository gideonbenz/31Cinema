//
//  CurrentMovie+CoreDataClass.swift
//  31Cinema
//
//  Created by Gideon Benz on 07/05/19.
//  Copyright © 2019 Gideon Benz. All rights reserved.
//

import Foundation
import CoreData

public class CurrentMovies: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentMovies> {
        return NSFetchRequest<CurrentMovies>(entityName: "CurrentMovie")
    }
    
    @NSManaged public var title: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var originalLanguage: String?
    @NSManaged public var overview: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var popularity: Double
    @NSManaged public var image: NSData?
    @NSManaged public var id: Int16
}
