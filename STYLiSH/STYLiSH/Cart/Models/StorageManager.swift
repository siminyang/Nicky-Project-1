//
//  StorageManager.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/8/1.
//

import Foundation
import UIKit
import CoreData

class StorageManager {
    
    // MARK: Properties
    static let shared = StorageManager()
    private let persistentContainer: NSPersistentContainer
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: Lifecycle
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        self.persistentContainer = appDelegate.persistentContainer
    }

    
    // MARK: Methods
    func saveOrder(imageURL: String, title: String, price: String, color: String, size: String, num: String, stock: Int32, productID: Int64, colorName: String) {
        
        let order = OrderDB(context: context)
        order.imageURL = imageURL
        order.title = title
        order.price = String(price)
        order.color = color
        order.size = size
        order.num = num
        order.stock = stock
        order.productID = productID
        order.colorName = colorName
        
        print("======================================== Order created")
        saveContext()
    }
    
    func clearOrders() {
        let fetchRequest: NSFetchRequest<OrderDB> = OrderDB.fetchRequest()
        
        do {
            let orders = try context.fetch(fetchRequest)
            for order in orders {
                context.delete(order)
            }
            print("======================================== Orders cleared")
            saveContext()
            
        } catch {
            print("Failed to clear orders")
        }
    }
    
    func updateOrderNum(order: OrderDB, newNum: String) {
        order.num = newNum
        saveContext()
        print("======================================== Order num updated to \(newNum)")
    }
    
    func deleteOrder(order: OrderDB) {
        context.delete(order)
        print("======================================== Order deleted")
        saveContext()
    }
    
    func fetchOrders() -> [OrderDB] {
        let request: NSFetchRequest<OrderDB> = OrderDB.fetchRequest()
        do {
            let orders = try context.fetch(request)
            print("========================================")
            print("Fetched orders from context: \(orders)")
            return orders
        } catch {
            print("======================================== Failed to fetch orders")
            return []
        }
    }
    
    private func saveContext() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("======================================== Unable to access AppDelegate")
        }
        
        do {
            try appDelegate.saveContext()
            print("======================================== Context saved")
        } catch {
            print("======================================== Failed to save context")
        }
    }
}
