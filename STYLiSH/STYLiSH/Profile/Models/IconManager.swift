//
//  IconManager.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/20.
//

import UIKit

struct Icon {
    let image: UIImage
    let title: String
}

class IconManager {
    let icons: [[Icon]] = [
        [
            Icon(image: UIImage(named: "Icons_24px_AwaitingPayment")!, title: "待付款"),
            Icon(image: UIImage(named: "Icons_24px_AwaitingShipment")!, title: "待出貨"),
            Icon(image: UIImage(named: "Icons_24px_Shipped")!, title: "待簽收"),
            Icon(image: UIImage(named: "Icons_24px_AwaitingReview")!, title: "待評價"),
            Icon(image: UIImage(named: "Icons_24px_Exchange")!, title: "退換貨")
        ],
        [
            Icon(image: UIImage(named: "Icons_24px_Starred")!, title: "收藏"),
            Icon(image: UIImage(named: "Icons_24px_Notification")!, title: "貨到通知"),
            Icon(image: UIImage(named: "Icons_24px_Refunded")!, title: "帳戶退款"),
            Icon(image: UIImage(named: "Icons_24px_Address")!, title: "地址"),
            Icon(image: UIImage(named: "Icons_24px_CustomerService")!, title: "客服訊息"),
            Icon(image: UIImage(named: "Icons_24px_SystemFeedback")!, title: "系統回饋"),
            Icon(image: UIImage(named: "Icons_24px_RegisterCellphone")!, title: "手機綁定"),
            Icon(image: UIImage(named: "Icons_24px_Settings")!, title: "設定")
        ]
    ]
    
    func icon(for indexPath: IndexPath) -> Icon {
        return icons[indexPath.section][indexPath.item]
    }
}
