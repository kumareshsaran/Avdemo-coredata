//
//  Videos+CoreDataProperties.swift
//  
//
//  Created by CSS on 21/09/18.
//
//

import Foundation
import CoreData


extension Videos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Videos> {
        return NSFetchRequest<Videos>(entityName: "Videos")
    }

    @NSManaged public var url: NSData?

}
