//
//  HomeDetailImageCell.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/24.
//

import Foundation
import UIKit
import Kingfisher

class HomeDetailImageCell: UICollectionViewCell {
    
    // MARK: Property
    @IBOutlet weak var imageView: UIImageView!
    
    var product: Product?
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    // MARK: Methods
    func configure(with imageURL: String) {
        
        if let url = URL(string: imageURL) {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "Image_Placeholder"))
        } else {
            imageView.image = UIImage(named: "Image_Placeholder")
        }
    }
}
