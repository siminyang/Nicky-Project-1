//
//  HomeDetailDescriptionCell.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/24.
//

import Foundation
import UIKit

class HomeDetailDescriptionCell: UITableViewCell {
    
    // MARK: Property
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var textureLabel: UILabel!
    @IBOutlet weak var washLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    @IBOutlet weak var colorView1: UIView!
    @IBOutlet weak var colorView2: UIView!
    @IBOutlet weak var colorView3: UIView!
    
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    // MARK: Methods
    func configure(with product: Product) {
        
        let allSizes = product.sizes.map {$0}.joined(separator: ", ")
        
        var totalStock = 0
        for variant in product.variants {
            totalStock += variant.stock
        }
        
        titleLabel.text = product.title
        priceLabel.text = "NT$ \(product.price)"
        idLabel.text = "\(product.id)"
        descriptionLabel.text = "\(product.story)"
        colorLabel.text = "顏色  |"
        sizeLabel.text = "尺寸  |  \(allSizes)"
        stockLabel.text = "庫存  |  \(totalStock)"
        textureLabel.text = "材質  |  \(product.texture)"
        washLabel.text = "洗滌  |  \(product.wash)"
        placeLabel.text = "產地  |  \(product.place)"
        noteLabel.text = "備註  |  \(product.note)"
        
        let colorViews = [colorView1, colorView2, colorView3]
        
        for (index, colorView) in colorViews.enumerated() {
            if index < product.colors.count {
                colorView?.backgroundColor = webSafeColor(product.colors[index].code)
                colorView?.layer.borderWidth = 1
            } else {
                colorView?.backgroundColor = UIColor.white
                colorView?.layer.borderWidth = 0
            }
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

