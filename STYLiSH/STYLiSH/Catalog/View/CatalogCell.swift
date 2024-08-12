//
//  CatalogCell.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/22.
//

import UIKit
import Kingfisher

class CatalogCell: UICollectionViewCell {
    
    @IBOutlet weak var catalogImageView: UIImageView?
    @IBOutlet weak var productTitleLabel: UILabel?
    @IBOutlet weak var productPriceLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with currentProduct: Product) {
        productTitleLabel?.text = currentProduct.title
        productPriceLabel?.text = "\(currentProduct.price)"

        if let imageUrl = URL(string: currentProduct.mainImage) {
            catalogImageView?.kf.setImage(with: imageUrl, placeholder: UIImage(named: "Image_Placeholder"))
        }
    }
}
