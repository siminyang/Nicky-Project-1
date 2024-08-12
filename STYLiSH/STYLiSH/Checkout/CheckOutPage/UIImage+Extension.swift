//
//  UIImage+Extension.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/8/12.
//

import UIKit

enum ImageAsset: String {
    
    //Drop down
    case Icons_24px_DropDown
}

// swiftlint:enable identifier_name

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }
}
