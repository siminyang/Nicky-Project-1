//
//  IconCell.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/20.
//

import UIKit

class IconCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    
    func configure(with icon: Icon) {
        iconImageView?.image = icon.image
        titleLabel?.text = icon.title
    }
}
