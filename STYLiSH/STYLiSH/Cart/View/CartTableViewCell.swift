//
//  CartTableViewCell.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/31.
//

import UIKit
import IQKeyboardManagerSwift

protocol CartTableViewDelegate: AnyObject {
    func didTapDeleteButton(cell: CartTableViewCell)
}

class CartTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var cartProductImageView: UIImageView!
    @IBOutlet weak var cartProductTitle: UILabel!
    @IBOutlet weak var cartProductColorView: UIView!
    @IBOutlet weak var cartProductSizeLabel: UILabel!
    @IBOutlet weak var cartProductSubstractButton: UIButton!
    @IBOutlet weak var cartProductBuyNumTextField: UITextField!
    @IBOutlet weak var cartProductAddButton: UIButton!
    @IBOutlet weak var cartProductDeleteButton: UIButton!
    @IBOutlet weak var cartProductPriceLabel: UILabel!
    
    weak var delegate: CartTableViewDelegate?
    var stock: Int = 0
    var order: OrderDB?
    
    @IBAction func cartSubtractButtonTapped(_ sender: Any) {
        if cartProductBuyNumTextField.text != "1" {
            adjustQuantity(by: -1)
        }
    }
    
    @IBAction func cartAddButtonTapped(_ sender: Any) {
        adjustQuantity(by: 1)
    }
    
    @IBAction func cartDeleteButtonTapped(_ sender: Any) {
        delegate?.didTapDeleteButton(cell: self)
        print("======================================== 移除成功")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupButton()
        setupTextField()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // Configure the view for the selected state
        super.setSelected(selected, animated: animated)
        self.contentView.backgroundColor = UIColor.white
    }
    
    private func setupTextField() {
        cartProductBuyNumTextField.delegate = self
        cartProductBuyNumTextField.isUserInteractionEnabled = true
        cartProductBuyNumTextField.isEnabled = true
        cartProductBuyNumTextField.keyboardType = .numberPad
        cartProductBuyNumTextField.autocapitalizationType = .none
        cartProductBuyNumTextField.autocorrectionType = .no
        selectionStyle = .default
    }
    
    private func setupButton() {
        cartProductAddButton.layer.borderColor = UIColor.black.cgColor
        cartProductAddButton.layer.borderWidth = 1.0
        cartProductAddButton.layer.masksToBounds = true
        
        cartProductSubstractButton.layer.borderColor = UIColor.black.cgColor
        cartProductSubstractButton.layer.borderWidth = 1.0
        cartProductSubstractButton.layer.masksToBounds = true
        cartProductSubstractButton.isEnabled = false
        cartProductSubstractButton.alpha = 0.5
    }
    
    private func adjustQuantity(by num: Int) {
        var currentText = cartProductBuyNumTextField.text ?? "1"
        var newQuantity = Int(currentText) ?? 1
        newQuantity += num
        
        if newQuantity != 1 {
            cartProductSubstractButton.isEnabled = true
            cartProductSubstractButton.alpha = 1
        } else {
            cartProductSubstractButton.isEnabled = false
            cartProductSubstractButton.alpha = 0.5
            newQuantity = 1
        }
        
        if newQuantity >= stock {
            cartProductAddButton.isEnabled = false
            cartProductAddButton.alpha = 0.5
        } else {
            cartProductAddButton.isEnabled = true
            cartProductAddButton.alpha = 1
        }
        
        if newQuantity < 1 {
            cartProductBuyNumTextField.text = "1"
        } else {
            cartProductBuyNumTextField.text = "\(newQuantity)"
        }
        
        if let order = order {
            StorageManager.shared.updateOrderNum(order: order, newNum: "\(newQuantity)")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = cartProductBuyNumTextField.text, let quantity = Int(text) else {
            return
        }
        
        if quantity > stock {
            cartProductBuyNumTextField.text = "\(String(describing: stock))"
        }
        
        adjustQuantity(by: 0)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits      // 數字
        let characterSet = CharacterSet(charactersIn: string)   // character
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func configure(with order: OrderDB) {
        self.order = order
        cartProductTitle.text = order.title
        cartProductColorView.backgroundColor = webSafeColor(order.color ?? "FFFFFF")
        cartProductSizeLabel.text = order.size
        cartProductBuyNumTextField.text = order.num
        cartProductPriceLabel.text = order.price
        self.stock = Int(order.stock)
        
        if let imageUrl = URL(string: order.imageURL ?? "") {
            cartProductImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "Image_Placeholder"))
        }
        
        if order.stock == 1 {
            cartProductAddButton.isEnabled = false
            cartProductAddButton.alpha = 0.5
            cartProductAddButton.isUserInteractionEnabled = false
            cartProductSubstractButton.isEnabled = false
            cartProductSubstractButton.alpha = 0.5
            cartProductBuyNumTextField.isEnabled = false
        }
        
        if cartProductBuyNumTextField.text == String(stock) {
            cartProductAddButton.isEnabled = false
            cartProductAddButton.alpha = 0.5
            cartProductSubstractButton.isEnabled = true
            cartProductSubstractButton.alpha = 1
        } else {
            cartProductAddButton.isEnabled = true
            cartProductAddButton.alpha = 1
            cartProductSubstractButton.isEnabled = true
            cartProductSubstractButton.alpha = 1
        }
    }
    
    
    func webSafeColor(_ hexString: String) -> UIColor {
        let hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard hex.count == 6 else {
            return UIColor.white
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
