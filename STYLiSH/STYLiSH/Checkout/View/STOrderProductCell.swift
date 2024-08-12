//
//  STOrderProductCell.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/7/25.
//  Copyright © 2019 WU CHIH WEI. All rights reserved.
//

import UIKit

class STOrderProductCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var productTitleLabel: UILabel!
    
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var productSizeLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var orderNumberLabel: UILabel!
    
    var order: OrderDB?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func configure(with order: OrderDB) {
        self.order = order
        
        productTitleLabel.text = order.title
        colorView.backgroundColor = UIColor.hexStringToUIColor(hex: order.color ?? "FFFFFF")
        productSizeLabel.text = order.size
        priceLabel.text = order.price
        orderNumberLabel.text = order.num
        
        
        if let imageUrl = URL(string: order.imageURL ?? "") {
            productImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "Image_Placeholder"))
        }
    }
}
