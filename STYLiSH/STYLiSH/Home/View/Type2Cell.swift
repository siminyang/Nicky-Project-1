//
//  Type2Cell.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/18.
//

/*
 This document is for Home page's Table View Cell Type 2
 */

import UIKit
import Kingfisher

class Type2Cell: UITableViewCell {
    
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        subtitleLabel.text = product.description
        
        for (index, imageView) in imageViews.enumerated() {
            if index < product.images.count, let url = URL(string: product.images[index]) {
                imageView.kf.setImage(with: url, placeholder: UIImage(named: "Image_Placeholder"))
            } else {
                imageView.image = UIImage(named: "Image_Placeholder")
            }
        }
    }
}
