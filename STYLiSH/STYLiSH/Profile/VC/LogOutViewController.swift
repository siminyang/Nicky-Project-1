//
//  LogOutViewController.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/8/6.
//


import UIKit
import FacebookLogin
import FBSDKLoginKit

protocol LogOutDelegate {
    func hideHiddenView()
}

class LogOutViewController: UIViewController {
    
    // MARK: Properties
    var logOutCompletion: ((Bool) -> Void)?
    var delegate: LogOutDelegate?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.hideHiddenView()
    }
    
    // MARK: Methods
    private func setupUI() {
        
        view.backgroundColor = .white
        
        let logOutButton = FBLoginButton()
        let logOutButtonText = NSAttributedString(string: "登出 Facebook")
        logOutButton.setAttributedTitle(logOutButtonText, for: .normal)
        logOutButton.permissions = ["public_profile", "email"]
        logOutButton.center = view.center
        logOutButton.frame = CGRect(x: (view.bounds.width - 350) / 2, y: 240, width: 350, height: 60)
        logOutButton.delegate = self
        view.addSubview(logOutButton)
        
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: view.frame.width - 60, y: 40, width: 50, height: 50)
        closeButton.setImage(UIImage(named: "Icons_24px_Close"), for: .normal)
        closeButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    @objc private func dismissButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.hideHiddenView()
        }
    }
}


// MARK: - LoginButtonDelegate
extension LogOutViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: (any Error)?) {
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        dismiss(animated: true) {
            self.delegate?.hideHiddenView()
        }
        
        do {
            try KeychainManager.instance.deleteToken(forKey: "FBAccessToken")
            print("FBAccessToken has been deleted")
        } catch KeychainManager.KeychainError.itemNotFound {
            print("FBAccessToken not found in Keychain.")
        } catch {
            print("Failed to delete token: \(error)")
        }
        
        do {
            try KeychainManager.instance.deleteToken(forKey: "StylishToken")
            print("StylishToken has been deleted")
        } catch KeychainManager.KeychainError.itemNotFound {
            print("StylishToken not found in Keychain.")
        } catch {
            print("Failed to delete Stylish token: \(error)")
        }
        
        print("==================================")
        print("===================== Log out completed")
    }
}
