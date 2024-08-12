//
//  Type1Cell.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/18.
//

/*
 This document is for Home page's Table View Cell Type 1
 */

import UIKit
import Kingfisher

class Type1Cell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        subtitleLabel.text = product.description
        
        if let imageUrl = URL(string: product.mainImage) {
            cellImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "Image_Placeholder"))
        }
    }
}
