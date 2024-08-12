//
//  CheckoutSuccessPageViewController.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/8/7.
//

import UIKit


class CheckoutSuccessPageViewController: UIViewController {
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationBar = self.navigationController?.navigationBar {
            let frame = CGRect(x: 0, y: 0, width: navigationBar.frame.width / 2, height: navigationBar.frame.height)
            let titleView = UIView(frame: frame)
            
            let firstLabel = UILabel()
            firstLabel.text = "結帳結果"
            firstLabel.sizeToFit()
            firstLabel.center = titleView.center
            
            titleView.addSubview(firstLabel)
            self.navigationItem.titleView = titleView
        }
        
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Methods
    @IBAction func buyAgain(_ sender: Any) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 2
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
