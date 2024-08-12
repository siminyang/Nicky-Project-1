//
//  AddToCartColorCell.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/29.
//

import Foundation
import UIKit

protocol AddToCartColorCellDelegate: AnyObject {
    func colorSelected(_ color: String)
}

class AddToCartColorCell: UITableViewCell {
    
    // MARK: Property
    @IBOutlet weak var selectColor: UILabel!
    @IBOutlet weak var colorView1: UIView!
    @IBOutlet weak var colorView2: UIView!
    @IBOutlet weak var colorView3: UIView!
    @IBOutlet weak var whiteView1: UIView!
    @IBOutlet weak var whiteView2: UIView!
    @IBOutlet weak var whiteView3: UIView!
    
    weak var delegate: AddToCartColorCellDelegate?
    private var colors: [String] = []
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        setupColorUI()
        setupGestureRecognizers()
    }
    
    // MARK: Methods
    func configure(with colors: [String]) {
        self.colors = colors
        
        let colorViews = [colorView1, colorView2, colorView3]
        
        for (index, colorView) in colorViews.enumerated() {
            if index < colors.count {
                colorView?.backgroundColor = webSafeColor(colors[index])
                colorView?.isHidden = false
            } else {
                colorView?.backgroundColor = UIColor.white
                colorView?.isHidden = true
            }
        }
    }
    
    // MARK: Setup Methods
    func setupColorUI() {
        whiteView1.backgroundColor = .white
        whiteView2.backgroundColor = .white
        whiteView3.backgroundColor = .white
    }
    
    func setupGestureRecognizers() {
        let colortapGesture1 = UITapGestureRecognizer(target: self, action: #selector(colorView1Tapped))
        colorView1.addGestureRecognizer(colortapGesture1)
        colorView1.isUserInteractionEnabled = true
        
        let colortapGesture2 = UITapGestureRecognizer(target: self, action: #selector(colorView2Tapped))
        colorView2.addGestureRecognizer(colortapGesture2)
        colorView2.isUserInteractionEnabled = true
        
        let colortapGesture3 = UITapGestureRecognizer(target: self, action: #selector(colorView3Tapped))
        colorView3.addGestureRecognizer(colortapGesture3)
        colorView3.isUserInteractionEnabled = true
    }
    
    @objc private func colorView1Tapped() {
        highlightColorView(whiteView1)
        delegate?.colorSelected(colors[0])
    }
    
    @objc private func colorView2Tapped() {
        highlightColorView(whiteView2)
        delegate?.colorSelected(colors[1])
    }
    
    @objc private func colorView3Tapped() {
        highlightColorView(whiteView3)
        delegate?.colorSelected(colors[2])
    }

    func highlightColorView(_ whiteView: UIView) {
        // Reset borders for all color views
        whiteView1.layer.borderWidth = 0
        whiteView2.layer.borderWidth = 0
        whiteView3.layer.borderWidth = 0
        
        // Set border for the selected color view
        whiteView.layer.borderWidth = 1
        whiteView.layer.borderColor = UIColor.black.cgColor
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
