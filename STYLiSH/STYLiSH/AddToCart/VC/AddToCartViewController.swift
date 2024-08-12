//
//  AddToCartViewController.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/29.
//

import Foundation
import UIKit
import Lottie
import CoreData

protocol AddToCartViewControllerDelegate: AnyObject {
    func didTapCloseButton()
    func showAddToCartAnimation()
}

class AddToCartViewController: UIViewController {
    
    // MARK: Property
    @IBOutlet weak var addToCartTableView: UITableView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var addToCartButton2: UIButton!

    var productID: Int?
    var product: Product?
    var colors: [String] = []
    var selectedColorName: String?
    var sizes: [String] = []
    var stock: Int = 0
    var currentStock: Int? = 0
    var selectedColor: String?
    var selectedSize: String?
    var selectedNum: String? = "1"
    var outOfStockSizes: [String] = []
    var orders: [OrderDB] = []
    weak var delegate: AddToCartViewControllerDelegate?

    
    // MARK: Action
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
        delegate?.didTapCloseButton()
        
    }
    
    @IBAction func addToCartButton2Tapped(_ sender: Any) {
        delegate?.showAddToCartAnimation()
        dismiss(animated: true)
        
        guard let title = product?.title,
              let price = product?.price,
              let color = selectedColor,
              let colorName = selectedColorName,
              let size = selectedSize,
              let num = self.selectedNum,
              let stock = self.currentStock,
              let imageURL = product?.mainImage,
              let productID = product?.id else {
            print("========================================= Failed to unwrap product properties")
            return
        }
        
        StorageManager.shared.saveOrder(imageURL: imageURL, title: title, price: String(price), color: color, size: size, num: num, stock: Int32(stock), productID: Int64(productID), colorName: colorName)
        
        NotificationCenter.default.post(name: NSNotification.Name("OrderSaved"), object: nil)
        
        updateBadgeNum()
    }
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitle()
        setupTableView()
        setupButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchOrders), name: NSNotification.Name("OrderSaved"), object: nil)
    }
    
    @objc func fetchOrders() {
        orders = StorageManager.shared.fetchOrders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector( updateSelectedNum(_:)), name: NSNotification.Name("selectedNumHasChanged"), object: nil)
    }
    
    @objc func updateSelectedNum(_ notification: Notification) {
        if let userInfo = notification.userInfo, let selectedNum = userInfo["selectedNum"] as? String {
            self.selectedNum = selectedNum
        }
    }
    
    // MARK: Setup Methods
    private func setupTitle() {
        guard let product = product else { return }
        productTitleLabel.text = product.title
        productPriceLabel.text = "NT$ \(product.price)"
    }
    
    private func setupTableView() {
        addToCartTableView.dataSource = self
        addToCartTableView.delegate = self
        addToCartTableView.isUserInteractionEnabled = true
        addToCartTableView.isScrollEnabled = true
    }
    
    private func setupButton() {
        addToCartButton2.setTitle("加入購物車", for: .normal)
        addToCartButton2.setTitleColor(UIColor.white, for: .disabled)
        addToCartButton2.isEnabled = false
        addToCartButton2.alpha = 0.5
    }
    
    func updateSizes(for color: String) {
        // 重置UI
        setupButton()
        selectedSize = nil
        currentStock = 0
        self.outOfStockSizes = []
        
        guard let variant = product?.variants.filter({ $0.colorCode == color }) else { return }
        guard let colorCodeName = product?.colors.first(where: { $0.code == color }) else { return }
        
        selectedColor = color
        selectedColorName = colorCodeName.name
        
        let outOfStockSizes = variant.filter { $0.stock == 0 }.map { $0.size }
        self.outOfStockSizes = outOfStockSizes
        
        var imageURL = product?.mainImage
        
        addToCartTableView.reloadRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .automatic)
    }
    
    func updateStock(for size: String) {
        
        guard let color = selectedColor,
              let variant = product?.variants.first(where: { $0.colorCode == color && $0.size == size}) else { return }
        selectedSize = size
        let stock = variant.stock

        self.currentStock = stock
        
        addToCartTableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        
        // 加入購物車按鈕活化
        if (selectedColor != nil) && (selectedSize != nil) && (currentStock != 0){
            addToCartButton2.alpha = 1
            addToCartButton2.isEnabled = true
        } else {
            addToCartButton2.alpha = 0.5
            addToCartButton2.isEnabled = false
        }
    }
    
    private func updateBadgeNum() {
        let itemCount = orders.count
        NotificationCenter.default.post(name: NSNotification.Name("CartItemCountUpdated"), object: nil, userInfo: ["itemCount": orders.count])
        
        if let tabBarController = self.tabBarController {
            let tabBarItem = tabBarController.tabBar.items?[2]
            tabBarItem?.badgeValue = itemCount > 0 ? "\(itemCount)" : nil
        }
    }
}

// MARK: - UITableViewDelegate
extension AddToCartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - UITableViewDataSource
extension AddToCartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {     // color
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddToCartColorCell", for: indexPath) as? AddToCartColorCell else {
                return UITableViewCell()
            }
            cell.configure(with: colors)
            cell.delegate = self
            removeSeparator(for: cell)
            
            return cell
        } else if indexPath.row == 1 {      // size
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddToCartSizeCell", for: indexPath) as? AddToCartSizeCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: sizes, outOfStockSizes: outOfStockSizes)
            cell.delegate = self
            
            removeSeparator(for: cell)
            
            return cell
        } else if indexPath.row == 2 {      // quantity
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddToCartQuantityCell", for: indexPath) as? AddToCartQuantityCell else {
                return UITableViewCell()
            }
            cell.configure(with: currentStock ?? 0)
            
            // 沒選顏色＆＆尺寸兩者的話庫存label先暫時不顯示
            if selectedColor == nil || selectedSize == nil {
                cell.quantityTextField.text = "1"
                cell.quantityTextField.isUserInteractionEnabled = false
                cell.stockNum.isHidden = true
                cell.addButton.isEnabled = false
                cell.addButton.alpha = 0.5
            } else {
                cell.stockNum.isHidden = false
                cell.quantityTextField.isUserInteractionEnabled = true
                cell.addButton.isEnabled = true
                cell.addButton.alpha = 1
                cell.quantityTextField.alpha = 1
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    private func removeSeparator(for cell: UITableViewCell) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
    }
}


extension AddToCartViewController: AddToCartColorCellDelegate {
    func colorSelected(_ color: String) {
        updateSizes(for: color)
    }
}

extension AddToCartViewController: AddToCartSizeCellDelegate {
    func sizeSelected(_ size: String) {
        updateStock(for: size)
    }
}
