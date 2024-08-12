//
//  AddToCartQuantityCell.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/29.
//

import Foundation
import UIKit

class AddToCartQuantityCell: UITableViewCell, UITextFieldDelegate {
    
    // MARK: Property
    @IBOutlet weak var selectQuantity: UILabel!
    @IBOutlet weak var stockNum: UILabel!
    @IBOutlet weak var substractButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    
    private var stock: Int = 0
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        setupTextField()
        setupButton()
    }
    
    // MARK: Setup Methods
    private func setupTextField() {
        quantityTextField.delegate = self
        quantityTextField.isUserInteractionEnabled = false
        quantityTextField.isEnabled = true
        quantityTextField.keyboardType = .numberPad
        quantityTextField.autocapitalizationType = .none
        quantityTextField.autocorrectionType = .no
        quantityTextField.alpha = 0.5
        selectionStyle = .default
    }
    
    private func setupButton() {
        addButton.layer.borderColor = UIColor.darkGray.cgColor
        addButton.layer.borderWidth = 1.0
        addButton.layer.masksToBounds = true
        addButton.isEnabled = false
        addButton.alpha = 0.5
        
        substractButton.layer.borderColor = UIColor.darkGray.cgColor
        substractButton.layer.borderWidth = 1.0
        substractButton.layer.masksToBounds = true
        substractButton.isEnabled = false
        substractButton.alpha = 0.5
        
        if stock == 1 {
            addButton.isEnabled = false
            addButton.alpha = 0.5
            addButton.isUserInteractionEnabled = false
            substractButton.isEnabled = false
            substractButton.alpha = 0.5
            quantityTextField.isEnabled = false
        } else {
            addButton.isEnabled = true
            addButton.alpha = 1
            addButton.isUserInteractionEnabled = true
            substractButton.isEnabled = true
            quantityTextField.isEnabled = true
        }
    }
    
    // MARK: Action
    @IBAction func addButtonTapped(_ sender: UIButton) {
        adjustQuantity(by: 1)
    }
    
    @IBAction func subtractButtonTapped(_ sender: UIButton) {
        adjustQuantity(by: -1)
    }
    
    // MARK: Methods
    func configure(with stock: Int) {
        self.stock = stock
        stockNum.text = "庫存：\(stock)"
        
        quantityTextField.text = "1"
        setupButton()
        setupTextField()
    }
    
    private func adjustQuantity(by num: Int) {

        let currentText = quantityTextField.text ?? "1"
        let currentQuantity = Int(currentText) ?? 1
        let newQuantity = currentQuantity + num
        
        // -按鈕
        if newQuantity != 1 {
            substractButton.isEnabled = true
            substractButton.alpha = 1
        } else {
            substractButton.isEnabled = false
            substractButton.alpha = 0.5
        }
        
        // +按鈕
        if newQuantity == stock {
            addButton.isEnabled = false
            addButton.alpha = 0.5
        } else {
            addButton.isEnabled = true
            addButton.alpha = 1
        }
        
        if newQuantity < 1 {
            quantityTextField.text = "1"
        } else {
            quantityTextField.text = "\(newQuantity)"
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("selectedNumHasChanged"), object: nil, userInfo: ["selectedNum": String(newQuantity)])
    }
    
    // 只允許數字輸入
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits      // 數字
        let characterSet = CharacterSet(charactersIn: string)   // character
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = quantityTextField.text, let quantity = Int(text) else {
            return
        }
        
        if quantity > stock {
            quantityTextField.text = "\(stock)"
        }
        
        adjustQuantity(by: 0)
    }
}
