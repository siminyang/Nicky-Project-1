//
//  OrderDB+CoreDataProperties.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/8/1.
//
//

import Foundation
import CoreData


extension OrderDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderDB> {
        return NSFetchRequest<OrderDB>(entityName: "OrderDB")
    }

    @NSManaged public var title: String?
    @NSManaged public var price: String?
    @NSManaged public var size: String?
    @NSManaged public var color: String?
    @NSManaged public var colorName: String?
    @NSManaged public var num: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var stock: Int32
    @NSManaged public var productID: Int64

}

extension OrderDB : Identifiable {

}
