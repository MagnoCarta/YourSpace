//
//  Person+CoreDataProperties.swift
//  MiniTutorialCoreData
//
//  Created by Gilberto Magno on 10/26/20.
//
//

import Foundation
import CoreData
import UIKit

extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var colors: [UIColor]?
    @NSManaged public var favoriteColor: UIColor?
    @NSManaged public var name: String?
    @NSManaged public var paintedBoard: UIImageView?
    @NSManaged public var tempPaintedBoard: UIImageView?

}

extension Person : Identifiable {

}


extension UIColor: NSSecureCoding {}

extension UIImageView: NSSecureCoding {
    public static var supportsSecureCoding: Bool {
        <#code#>
    }
}
