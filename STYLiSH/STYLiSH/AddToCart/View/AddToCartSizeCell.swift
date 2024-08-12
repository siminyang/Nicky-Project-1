//
//  AddToCartSizeCell.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/29.
//

import Foundation
import UIKit

protocol AddToCartSizeCellDelegate: AnyObject {
    func sizeSelected(_ size: String)
}

class AddToCartSizeCell: UITableViewCell {
    
    // MARK: Property
    @IBOutlet weak var selectSize: UILabel!
    @IBOutlet weak var size1: UILabel!
    @IBOutlet weak var size2: UILabel!
    @IBOutlet weak var size3: UILabel!
    @IBOutlet weak var size4: UILabel!
    @IBOutlet weak var whiteViewA: UIView!
    @IBOutlet weak var whiteViewB: UIView!
    @IBOutlet weak var whiteViewC: UIView!
    @IBOutlet weak var whiteViewD: UIView!
    
    weak var delegate: AddToCartSizeCellDelegate?
    private var sizes: [String] = []
    private var outOfStockSizes: [String] = []

    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        setupUI()
        setupGestureRecognizers()
    }
    
    // MARK: Methods
    func configure(with sizes: [String], outOfStockSizes: [String]) {
        self.sizes = sizes
        self.outOfStockSizes = outOfStockSizes
        
        whiteViewA.layer.borderWidth = 0
        whiteViewB.layer.borderWidth = 0
        whiteViewC.layer.borderWidth = 0
        whiteViewD.layer.borderWidth = 0
        
        let sizeLabels = [size1, size2, size3, size4]
       
        // 哪個尺寸在這個item不支援
        for (index, sizeLabel) in sizeLabels.enumerated() {
            if index < sizes.count {
                sizeLabel?.text = sizes[index]
                sizeLabel?.isHidden = false
                sizeLabel?.isUserInteractionEnabled = true
                sizeLabel?.alpha = 1.0
                
                // 哪個尺寸沒有庫存
                if outOfStockSizes.contains(sizes[index]) {
                    sizeLabel?.isUserInteractionEnabled = false
                    sizeLabel?.alpha = 0.5
                }
            } else {
                sizeLabel?.text = ""
                sizeLabel?.isHidden = true
            }
        }
    }
    
    // MARK: Setup Methods
    func setupUI() {
        whiteViewA.backgroundColor = .white
        whiteViewB.backgroundColor = .white
        whiteViewC.backgroundColor = .white
        whiteViewD.backgroundColor = .white
    }
    
    func setupGestureRecognizers() {
        
        let sizetapGesture1 = UITapGestureRecognizer(target: self, action: #selector(size1Tapped))
        size1.addGestureRecognizer(sizetapGesture1)
        size1.isUserInteractionEnabled = true
        
        let sizetapGesture2 = UITapGestureRecognizer(target: self, action: #selector(size2Tapped))
        size2.addGestureRecognizer(sizetapGesture2)
        size2.isUserInteractionEnabled = true
        
        let sizetapGesture3 = UITapGestureRecognizer(target: self, action: #selector(size3Tapped))
        size3.addGestureRecognizer(sizetapGesture3)
        size3.isUserInteractionEnabled = true
        
        let sizetapGesture4 = UITapGestureRecognizer(target: self, action: #selector(size4Tapped))
        size4.addGestureRecognizer(sizetapGesture4)
        size4.isUserInteractionEnabled = true
    }
    
    @objc private func size1Tapped() {
        highlightSizeLabel(whiteViewA)
        delegate?.sizeSelected(sizes[0])
    }
    
    @objc private func size2Tapped() {
        highlightSizeLabel(whiteViewB)
        delegate?.sizeSelected(sizes[1])
    }
    
    @objc private func size3Tapped() {
        highlightSizeLabel(whiteViewC)
        delegate?.sizeSelected(sizes[2])
    }
    
    @objc private func size4Tapped() {
        highlightSizeLabel(whiteViewD)
        delegate?.sizeSelected(sizes[3])
    }
    
    func highlightSizeLabel(_ whiteColorView: UIView) {
        // Reset borders for all size labels
        whiteViewA.layer.borderWidth = 0
        whiteViewB.layer.borderWidth = 0
        whiteViewC.layer.borderWidth = 0
        whiteViewD.layer.borderWidth = 0
        
        // Set border for the selected size label
        whiteColorView.layer.borderWidth = 1
        whiteColorView.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: Methods
    func configure(with sizes: [String]) {
        let sizeLabels = [size1, size2, size3, size4]
        
        for (index, sizeLabel) in sizeLabels.enumerated() {
            if index < sizes.count {
                sizeLabel?.text = sizes[index]
                sizeLabel?.isHidden = false
            } else {
                sizeLabel?.text = ""
                sizeLabel?.isHidden = true
            }
        }
    }
}
