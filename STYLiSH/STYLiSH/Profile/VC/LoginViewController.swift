//
//  LoginViewController.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/8/5.
//


import UIKit
import FacebookLogin
import FBSDKLoginKit

protocol LoginDelegate {
    func hideHiddenView()
}

class LoginViewController: UIViewController {
    
    // MARK: Properties
    var loginCompletion: ((Bool) -> Void)?
    var delegate: LoginDelegate?
    
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
        
        let label1 = UILabel(frame: CGRect(x: 20, y: 40, width: view.frame.width - 40, height: 60))
        label1.font = UIFont.systemFont(ofSize: 24)
        label1.text = "請先登入會員"
        view.addSubview(label1)
        
        let label2 = UILabel(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 60))
        label2.font = UIFont.systemFont(ofSize: 20)
        label2.text = "登入會員後即可完成結帳"
        view.addSubview(label2)
        
        let lineView = UIView(frame: CGRect(x: 20, y: 200, width: view.frame.width - 40, height: 1))
        lineView.backgroundColor = .gray
        view.addSubview(lineView)
        
        view.backgroundColor = .white
        
        let loginButton = FBLoginButton()
        let loginButtonText = NSAttributedString(string: "Facebook 登入")
        loginButton.setAttributedTitle(loginButtonText, for: .normal)
        loginButton.permissions = ["public_profile", "email"]
        loginButton.center = view.center
        loginButton.frame = CGRect(x: (view.bounds.width - 350) / 2, y: 240, width: 350, height: 60)
        loginButton.delegate = self
        view.addSubview(loginButton)
        
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
extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if let error = error {
            print("Facebook login failed: \(error.localizedDescription)")
            loginCompletion?(false)
            return
        }
        
        if let token = AccessToken.current?.tokenString {
            do {
                try KeychainManager.instance.saveToken(token, forKey: "FBAccessToken")
            } catch {
                print("Failed to save token: \(error)")
            }
            
            fetchStylishToken(with: token)
            
        } else {
            loginCompletion?(false)
        }
    }
    
    
    func fetchStylishToken(with facebookToken: String) {
        
        if KeychainManager.instance.getToken(forKey: "FBAccessToken") != nil {
            print("Retrieved token")
        } else {
            print("No token found")
        }
        
        let url = URL(string: "https://api.appworks-school.tw/api/1.0/user/signin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["provider": "facebook", "access_token": facebookToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(String(describing: error))")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictionary = json as? [String: Any], let data = dictionary["data"] as? [String: Any], let token = data["access_token"] as? String {
    
                    print("==================================")
                    print("User signin =========\(dictionary)")

                    do {
                        try KeychainManager.instance.saveToken(token, forKey: "stylishToken")
                    } catch KeychainManager.KeychainError.duplicateEntry {
                        do {
                            try KeychainManager.instance.updateToken(token, forKey: "stylishToken")
                        } catch {
                            print("Failed to update token: \(error)")
                        }
                    } catch {
                        print("Failed to save token: \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }
        
        task.resume()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        
    }
}
