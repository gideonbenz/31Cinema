//
//  FavoritedMovie+CoreDataClass.swift
//  
//
//  Created by Gideon Benz on 07/05/19.
//
//

import Foundation
import CoreData


public class FavoritedMovie: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritedMovie> {
        return NSFetchRequest<FavoritedMovie>(entityName: "FavoritedMovie")
    }
    
    @NSManaged public var id: Int16
    @NSManaged public var title: String?
    @NSManaged public var overview: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var originalLanguage: String?
    @NSManaged public var image: NSData?
}
