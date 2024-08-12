/*
 This document is for Checkout Page.
 */

import UIKit

protocol CheckoutDelegate: AnyObject {
    func checkLoginStatus(completion: @escaping (Bool) -> Void)
}

class ViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    let header = ["結帳商品", "收件資訊", "付款詳情"]
    var orders: [OrderDB] = []
    var delegate: CheckoutDelegate?
    var userData: (username: String, email: String, phoneNumber: String, address: String, shipTime: String)?
    var paymentData: (payment: String, cardNumber: String, dueDate: String, verifyCode: String)?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        tableView.delegate = self
        self.delegate = (self.tabBarController as? TabBarViewController)
        
        tableView.lk_registerCellWithNib(identifier: String(describing: STOrderProductCell.self), bundle: nil)
        
        tableView.lk_registerCellWithNib(identifier: String(describing: STOrderUserInputCell.self), bundle: nil)
        
        tableView.lk_registerCellWithNib(identifier: String(describing: STPaymentInfoTableViewCell.self), bundle: nil)
        
        let headerXib = UINib(nibName: String(describing: STOrderHeaderView.self), bundle: nil)
        
        tableView.register(headerXib, forHeaderFooterViewReuseIdentifier: String(describing: STOrderHeaderView.self))
        
        fetchOrders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Action
    @IBAction func backButtonTapped2(_ sender: Any) {
        performSegue(withIdentifier: "unwindToCartVCWithSegue", sender: self)
    }
    
    // MARK: Methods
    func fetchOrders() {
        orders = StorageManager.shared.fetchOrders()
        print("Fetched orders: \(orders)")
        tableView.reloadData()
    }
    
    func fetchUserOrderNumber(prime: String, orders: [OrderDB], stylishToken: String, userData: (username: String, email: String, phoneNumber: String, address: String, shipTime: String), paymentData: (payment: String, cardNumber: String, dueDate: String, verifyCode: String)) {
        
        let url = URL(string: "https://api.appworks-school.tw/api/1.0/order/checkout")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(stylishToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (totalPrice, _, shipPrice) = calculateTotalAmount()
        
        let orderList = orders.map { order in
            return [
                "id": order.productID,
                "name": order.title ?? "",
                "price": Int(order.price ?? "0") ?? 0,
                "color": [
                    "name": order.colorName,
                    "code": order.color ?? ""
                ],
                "size": order.size ?? "",
                "qty": Int(order.num ?? "0") ?? 0
            ]
        }
        
        let recipient: [String: Any] = [
            "name": userData.username,
            "phone": userData.phoneNumber,
            "email": userData.email,
            "address": userData.address,
            "time": userData.shipTime
        ]
        
        let orderDict: [String: Any] = [
            "shipping": "delivery",
            "payment": paymentData.payment,
            "subtotal": totalPrice,
            "freight": shipPrice,
            "total": totalPrice + shipPrice,
            "recipient": recipient,
            "list": orderList
        ]
        
        let body: [String: Any] = ["prime": prime, "order": orderDict]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("JSON Body: =================================== \(jsonString)")
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(String(describing: error))")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictionary = json as? [String: Any], let data = dictionary["data"] as? [String: Any] {
                    print("User order number ========= \(data)")
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }
        
        task.resume()
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 67.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: STOrderHeaderView.self)) as? STOrderHeaderView else {
            return nil
        }
        
        headerView.titleLabel.text = header[section]
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        guard let footerView = view as? UITableViewHeaderFooterView else { return }
        
        footerView.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "cccccc")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return header.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        if section == 0 {
            count = orders.count
        } else if section == 1 {
            count =  1
        } else if section == 2 {
            count =  1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let productCell = tableView.dequeueReusableCell(withIdentifier: String(describing: STOrderProductCell.self), for: indexPath) as! STOrderProductCell
            
            let order = orders[indexPath.row]
            
            productCell.configure(with: order)
            
            return productCell
            
        } else if indexPath.section == 1 {
            
            let userInputCell = tableView.dequeueReusableCell(withIdentifier: String(describing: STOrderUserInputCell.self), for: indexPath) as! STOrderUserInputCell
            
            userInputCell.delegate = self
            
            return userInputCell
            
        } else {
            
            let paymentCell = tableView.dequeueReusableCell(withIdentifier: String(describing: STPaymentInfoTableViewCell.self), for: indexPath) as! STPaymentInfoTableViewCell
            
            let (totalPrice, totalCount, shipPrice) = calculateTotalAmount()
            
            paymentCell.layoutCellWith(productPrice: totalPrice, shipPrice: shipPrice, productCount: totalCount)

            paymentCell.delegate = self
            
            return paymentCell
        }
    }
}


// MARK: - STPaymentInfoTableViewCellDelegate
extension ViewController: STPaymentInfoTableViewCellDelegate {
    
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell) {
        
        tableView.reloadData()
    }
    
    func didChangeUserData(
        _ cell: STPaymentInfoTableViewCell,
        payment: String,
        cardNumber: String,
        dueDate: String,
        verifyCode: String
    ) {
        print(payment, cardNumber, dueDate, verifyCode)
        paymentData = (payment, cardNumber, dueDate, verifyCode)
    }
    
    func checkout(_ cell:STPaymentInfoTableViewCell) {
        
        guard let paymentText = cell.paymentTextField.text, let paymentMethod = PaymentMethod(rawValue: paymentText) else {
            return
        }

        print("======================================== User did tap checkout button")
        
        
        let checkoutSuccessVC = CheckoutSuccessPageViewController(nibName: "CheckoutSuccessPageViewController", bundle: nil)
        
        if paymentMethod == .creditCard {
            cell.getPrime { prime in
                guard prime != nil else {
                    print("Failed to get prime")
                    return
                }
                
                self.delegate?.checkLoginStatus { isLoggedIn in
                    if isLoggedIn {
                        self.navigationController?.pushViewController(checkoutSuccessVC, animated: true)
                        guard let stylishToken = KeychainManager.instance.getToken(forKey: "stylishToken"),
                              let userData = self.userData,
                              let paymentData = self.paymentData else { return }
        
                        self.fetchUserOrderNumber(prime: prime ?? "", orders: self.orders, stylishToken: stylishToken, userData: userData, paymentData: paymentData)
                        print("======================================== 訂單已發送server")
                        StorageManager.shared.clearOrders()
                    } else {
                        (self.tabBarController as? TabBarViewController)?.presentHiddenView()
                        (self.tabBarController as? TabBarViewController)?.presentLoginViewController(completion: {
                            self.navigationController?.pushViewController(checkoutSuccessVC, animated: true)
                            guard let stylishToken = KeychainManager.instance.getToken(forKey: "stylishToken"),
                                  let userData = self.userData,
                                  let paymentData = self.paymentData else { return }
            
                            self.fetchUserOrderNumber(prime: prime ?? "", orders: self.orders, stylishToken: stylishToken, userData: userData, paymentData: paymentData)
                            print("======================================== 訂單已發送server")
                            StorageManager.shared.clearOrders()
                        })
                    }
                }
            }
        }
    }

    func calculateTotalAmount() -> (Int, Int, Int) {
        var totalPrice = 0
        var totalCount = 0
        let shipPrice = 60
        
        for order in orders {
            if let price = Int(order.price!), let num = Int(order.num!) {
                totalPrice += price * num
            }
            
            if let num = Int(order.num!) {
                totalCount += num
            }
        }
        
        return (totalPrice, totalCount, shipPrice)
    }
}

// MARK: - STOrderUserInputCellDelegate
extension ViewController: STOrderUserInputCellDelegate {
    func didChangeUserData(
        _ cell: STOrderUserInputCell,
        username: String,
        email: String,
        phoneNumber: String,
        address: String,
        shipTime: String
    ) {
        print("==== 收件人姓名：\(username), Email: \(email), 手機號碼：\(phoneNumber), 地址：\(address), 配送時間：\(shipTime)")
        userData = (username, email, phoneNumber, address, shipTime)
    }
    
    func checkoutButtonShouldBeEnabled(_ enabled: Bool) {
        
        if let paymentCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? STPaymentInfoTableViewCell {
            
            paymentCell.checkOutButton.isEnabled = enabled
            paymentCell.checkOutButton.alpha = enabled ? 1.0 : 0.5
        }
    }
}

