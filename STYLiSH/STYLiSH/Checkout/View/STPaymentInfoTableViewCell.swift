//
//  STPaymentInfoTableViewCell.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/7/26.
//  Copyright © 2019 WU CHIH WEI. All rights reserved.
//

import UIKit

// MARK: - PaymentMethod
enum PaymentMethod: String {
    
    case creditCard = "信用卡付款"
    
    case cash = "貨到付款"
}


// MARK: - Protocol
protocol STPaymentInfoTableViewCellDelegate: AnyObject {
    
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell)
    
    func didChangeUserData(
        _ cell: STPaymentInfoTableViewCell,
        payment: String,
        cardNumber: String,
        dueDate: String,
        verifyCode: String
    )
    
    func checkout(_ cell:STPaymentInfoTableViewCell)
}


// MARK: - UITableViewCell
class STPaymentInfoTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var paymentTextField: UITextField! {
        
        didSet {
        
            let shipPicker = UIPickerView()
            
            shipPicker.dataSource = self
            
            shipPicker.delegate = self
            
            paymentTextField.inputView = shipPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            paymentTextField.rightView = button
            
            paymentTextField.rightViewMode = .always
            
            paymentTextField.delegate = self
            
            paymentTextField.text = PaymentMethod.cash.rawValue
        }
    }
    
    @IBOutlet weak var cardNumberTextField: UITextField! {
        
        didSet {
            
            cardNumberTextField.delegate = self
            cardNumberTextField.isHidden = true
        }
    }
    
    @IBOutlet weak var dueDateTextField: UITextField! {
        
        didSet {
            
            dueDateTextField.delegate = self
            dueDateTextField.isHidden = true
        }
    }
    
    @IBOutlet weak var verifyCodeTextField: UITextField! {
        
        didSet {
            
            verifyCodeTextField.delegate = self
            verifyCodeTextField.isHidden = true
        }
    }
    
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var shipPriceLabel: UILabel!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var productAmountLabel: UILabel!
    
    @IBOutlet weak var topDistanceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var creditView: UIView! {
        
        didSet {
        
            creditView.isHidden = true
        }
    }
    
    @IBOutlet weak var checkOutButton: UIButton!
    
    private let paymentMethod: [PaymentMethod] = [.cash, .creditCard]
    
    weak var delegate: STPaymentInfoTableViewCellDelegate?
    
    var tpdForm : TPDForm!
    var tpdCard: TPDCard!

    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        checkOutButton.isEnabled = false
        checkOutButton.alpha = 1
        
        // Setup TapPay form
        tpdForm = TPDForm.setup(withContainer: creditView)
        
        // Setup TPDForm Text Color
        tpdForm.setErrorColor(UIColor.red)
        tpdForm.setOkColor(UIColor.blue)
        tpdForm.setNormalColor(UIColor.black)
        
        // Setup form updated callback
        tpdForm.onFormUpdated { (status) in
            status.isCanGetPrime()
        }
    }

    
    // MARK: Methods
    func getPrime(completion: @escaping (String?) -> Void) {
        tpdCard = TPDCard.setup(tpdForm)
        
        tpdCard.onSuccessCallback { (prime, cardInfo, cardIdentifier, additionalData) in
            print("Prime : \(prime!), cardInfo : \(cardInfo), cardIdentifier : \(cardIdentifier)")
            DispatchQueue.main.async {
                completion(prime)
            }
            
        }.onFailureCallback { (status, message) in
            print("status : \(status) , Message : \(message)")
            
        }.getPrime()
    }

    
    func layoutCellWith(
        productPrice: Int,
        shipPrice: Int,
        productCount: Int
    ) {
        
        productPriceLabel.text = "NT$ \(productPrice)"
        
        shipPriceLabel.text = "NT$ \(shipPrice)"
        
        totalPriceLabel.text = "NT$ \(shipPrice + productPrice)"
        
        productAmountLabel.text = "總計 (\(productCount)樣商品)"
    }
   
        
    
    // MARK: Action
    @IBAction func checkout() {
        delegate?.checkout(self)
    }
}



// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension STPaymentInfoTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int
    {
        return 2
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String?
    {
        
        return paymentMethod[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        paymentTextField.text = paymentMethod[row].rawValue
    }
    
    private func manipulateHeight(_ distance: CGFloat) {
        
        topDistanceConstraint.constant = distance
        
        delegate?.didChangePaymentMethod(self)
    }
}


// MARK: - UITextFieldDelegate
extension STPaymentInfoTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField != paymentTextField {
            
            passData()
            return
        }
        
        guard
            let text = textField.text,
            let payment = PaymentMethod(rawValue: text) else
        {
            
            passData()
            return
        }
        
        switch payment {
            
        case .cash:
            
            manipulateHeight(44)
            
            creditView.isHidden = true
            
        case .creditCard:
            
            manipulateHeight(228)
            
            creditView.isHidden = false
        }
        
        passData()
    }
    
    private func passData() {
        
        guard
            let cardNumber = cardNumberTextField.text,
            let dueDate = dueDateTextField.text,
            let verifyCode = verifyCodeTextField.text,
            let paymentMethod = paymentTextField.text else
        {
            return
        }
        
        delegate?.didChangeUserData(
            self,
            payment: paymentMethod,
            cardNumber: cardNumber,
            dueDate: dueDate,
            verifyCode: verifyCode
        )
    }
}

