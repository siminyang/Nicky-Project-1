//
//  TabBarViewController.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/8/5.
//

import FacebookLogin

class TabBarViewController: UITabBarController {
    
    // MARK: Properties
    var hiddenView: UIView?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if let navController = viewControllers?[2] as? UINavigationController,
           let cartVC = navController.viewControllers.first as? CartViewController {
            cartVC.delegate = self
        }
    }
    
    // MARK: Methods
    func presentHiddenView() {

        if hiddenView == nil {
            hiddenView = UIView(frame: view.bounds)
            hiddenView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            hiddenView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        if let hiddenView = hiddenView {
            view.addSubview(hiddenView)
        }
    }
    
    func hideHiddenView() {
        hiddenView?.removeFromSuperview()
    }
}
    
// MARK: - UITabBarControllerDelegate
extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let navController = viewController as? UINavigationController,
           navController.viewControllers.first is ProfileViewController {
            checkLoginStatus { isLoggedIn in
                if isLoggedIn {
                    self.selectedViewController = viewController
                }
            }
            return false
        }
        return true
    }
}
    
// MARK: - CartViewDelegate, LoginDelegate, LogOutDelegate, CheckoutDelegate
extension TabBarViewController: CartViewDelegate, LoginDelegate, LogOutDelegate, CheckoutDelegate {
    func checkLoginStatus(completion: @escaping (Bool) -> Void) {
        if let token = AccessToken.current, !token.isExpired {
            completion(true)
        } else {
            presentHiddenView()
            presentLoginViewController() {
                completion(false)
            }
        }
    }
    
    func presentLoginViewController(completion: @escaping () -> Void) {
        
        let loginVC = LoginViewController()
        
        loginVC.delegate = self
        
        if #available(iOS 13.0, *) {
            
            loginVC.modalPresentationStyle = .pageSheet
            if let sheet = loginVC.sheetPresentationController {
                
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 35
            }
        }
        
        present(loginVC, animated: true, completion: nil)
    }
    
    private func presentLogOutViewController() {
        
        let logOutVC = LogOutViewController()
        
        logOutVC.delegate = self
        
        if #available(iOS 13.0, *) {
            
            logOutVC.modalPresentationStyle = .pageSheet
            if let sheet = logOutVC.sheetPresentationController {
                
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 35
            }
        }
        
        present(logOutVC, animated: true, completion: nil)
    }
    
    func logOutTapped() {
        print("===================== Tapped logouttt button...")
        presentHiddenView()
        presentLogOutViewController()
    }
}
