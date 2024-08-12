//
//  CartManager.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/8/1.
//
import UIKit

struct CartProductData {
    let title: String
    let colorHex: String
    let size: String
    let buyNum: String
    let price: String
    let imageUrl: String
    let stock: Int
}

class CartManager {
    var cartItems: [CartProductData]

    init() {
        self.cartItems = []

        let data: [(String, String, String, String, String, String, Int)] = [
            ("活力花紋長筒牛仔褲", "DDF0FF", "S", "1", "1299", "https://api.appworks-school.tw/assets/201807202157/main.jpg", 2),
            ("時尚輕鬆休閒西裝", "FFFFFF", "M", "1", "2399", "https://api.appworks-school.tw/assets/201807242216/main.jpg", 5),
            ("卡哇伊多功能隨身包", "FFDDDD", "F", "1", "1299", "https://api.appworks-school.tw/assets/201807242232/main.jpg", 1),
            ("透肌澎澎防曬襯衫", "DDFFBB", "L", "1", "599", "https://api.appworks-school.tw/assets/201807202140/main.jpg", 3),
            ("純色輕薄百搭襯衫", "DDF0FF", "XL", "1", "799", "https://api.appworks-school.tw/assets/201807242211/main.jpg", 6),
            ("夏日海灘戶外遮陽帽", "BB7744", "L", "1", "1499", "https://api.appworks-school.tw/assets/201807242228/main.jpg", 4)
        ]

        cartItems = data.map { (title, colorHex, size, buyNum, price, imageUrl, stock) in
            CartProductData(title: title, colorHex: colorHex, size: size, buyNum: buyNum, price: price, imageUrl: imageUrl, stock: stock)
        }
    }
}
