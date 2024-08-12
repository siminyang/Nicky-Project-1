//
//  CartViewController.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/31.
//

import Foundation
import UIKit

protocol CartViewDelegate: AnyObject {
    func logOutTapped()
}

class CartViewController: UIViewController, CartTableViewDelegate {
    
    // MARK: Property
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var checkoutButton: UIButton!
    
    var orders: [OrderDB] = []
    var delegate: CartViewDelegate?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartTableView.dataSource = self
        cartTableView.delegate = self
        cartTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchOrders), name: NSNotification.Name("OrderSaved"), object: nil)
        
        fetchOrders()
        updateBadgeNum()
    }
    
    // MARK: Methods
    @objc func fetchOrders() {
        orders = StorageManager.shared.fetchOrders()
        print("========================================")
        print("Cart fetched orders: \(orders)")
        cartTableView.reloadData()
    }
    
    func didTapDeleteButton(cell: CartTableViewCell) {
        guard let indexPath = cartTableView.indexPath(for: cell) else { return }
        
        StorageManager.shared.deleteOrder(order: orders[indexPath.row])
        orders.remove(at: indexPath.row)
        cartTableView.deleteRows(at: [indexPath], with: .automatic)
        cartTableView.reloadData()
        print("======================================== 購物車剩下\(orders.count)件商品")
        
        updateBadgeNum()
    }
    
    private func updateBadgeNum() {
        let itemCount = orders.count
        NotificationCenter.default.post(name: NSNotification.Name("CartItemCountUpdated"), object: nil, userInfo: ["itemCount": orders.count])
        
        if let tabBarController = self.tabBarController {
            let tabBarItem = tabBarController.tabBar.items?[2]
            tabBarItem?.badgeValue = itemCount > 0 ? "\(itemCount)" : nil
        }
        
        updateCheckOutButtonState()
    }
    
    private func updateCheckOutButtonState() {
        checkoutButton.isUserInteractionEnabled = !orders.isEmpty
        checkoutButton.alpha = !orders.isEmpty ? 1 : 0.5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCheckOutPage" {
            if let checkOutVC = segue.destination as? ViewController {
                checkOutVC.orders = self.orders
            }
        }
    }
    
    // MARK: Action
    @IBAction func checkOutButton(_ sender: Any) {
        if !orders.isEmpty {
            performSegue(withIdentifier: "showCheckOutPage", sender: self)
        }
    }
    
    @IBAction func unwindToCartVC(segue: UIStoryboardSegue) {
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        delegate?.logOutTapped()
    }
}


// MARK: - UITableViewDelegate
extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cartTableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        let order = orders[indexPath.row]
        
        cell.configure(with: order)
        cell.delegate = self
        return cell
    }
}
