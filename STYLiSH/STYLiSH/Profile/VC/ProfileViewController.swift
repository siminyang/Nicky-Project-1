//
//  ProfileViewcontroller.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/20.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var personbackgroundView: UIView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profileName: UITextField!
    
    private let iconManager = IconManager()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPersonView()
        setupCollectionView()
        profileName.isUserInteractionEnabled = false
        
        guard let token = KeychainManager.instance.getToken(forKey: "stylishToken") else {
            return
        }
        fetchUserProfile(with: token)
    }
    
    
    // MARK: Methods
    private func setupPersonView() {
        let personBackgroundView = UIView()
        personBackgroundView.backgroundColor = .darkGray
        personBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(personBackgroundView)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self 
    }
    
    func fetchUserProfile(with token: String) {
        let url = URL(string: "https://api.appworks-school.tw/api/1.0/user/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(String(describing: error))")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictionary = json as? [String: Any], let data = dictionary["data"] as? [String: Any] {
                    
                    print("==================================")
                    print("User profile data ========= \(data)")
                    
                    if let name = data["name"] as? String,
                       let picture = data["picture"] as? String {
                        DispatchQueue.main.async {
                            
                            self.profileName.text = name
                            if let url = URL(string: picture) {
                                if let imageData = try? Data(contentsOf: url) {
                                    self.profilePhoto.image = UIImage(data: imageData)
                                }
                            }
                        }
                    }
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }
        task.resume()
    }
}



// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // cell區
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        let iconManager = IconManager()
        return section == 0 ? iconManager.icons[0].count : iconManager.icons[1].count 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as! IconCell
        let icon = iconManager.icon(for: indexPath)
        cell.configure(with: icon)
        return cell
    }
    
    // header區
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionTitleCell", for: indexPath) as? SectionTitleCell
            headerView?.titleLabel?.text = indexPath.section == 0 ? "我的訂單" : "更多服務"
            headerView?.viewAllLabel?.text = indexPath.section == 0 ? "查看全部" : ""
            
            return headerView!
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width - 32 
        let spacing: CGFloat = 10
        
        if indexPath.section == 0 {
            let width = (screenWidth - spacing * 6) / 5
            return CGSize(width: width, height: width)
        } else {
            let width = (screenWidth - spacing * 5) / 4
            return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
}
