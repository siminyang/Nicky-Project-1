//
//  ViewController.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/17.
//
/*
 This document is for Home Page.
 Related to:
    - Type1Cell
    - Type2Cell
    - MarketManager
 */

import UIKit
import Kingfisher
import MJRefresh

class HomeViewController: UIViewController {
    
    // MARK: Property
    @IBOutlet weak var tableView: UITableView!
    
    var marketingHots: [Hot] = []
    var orders: [OrderDB] = []
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupPullToRefresh()
        loadInitialData()
        setupBadgeNum()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeNum(_:)), name: NSNotification.Name("CartItemCountUpdated"), object: nil)
    }
    
    // MARK: Action
    @IBAction func unwindToHomeVC(segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHomeDetail" {
            if let detailVC = segue.destination as? HomeDetailViewController,
               let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                let product = marketingHots[indexPath.section].products[indexPath.row]
                detailVC.product = product
                detailVC.shouldUnwindToHomeVC = true
                detailVC.shouldUnwindToCatalogVC = false
            }
        }
    }
    
    // MARK: Setup Methods
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    
    private func setupPullToRefresh() {
        MJRefreshConfig.default.languageCode = "en"
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.refreshData()
        })
    }
    
    private func setupBadgeNum() {
        orders = StorageManager.shared.fetchOrders()
        
        let tabBarItem = tabBarController?.tabBar.items?[2]
        tabBarItem?.badgeValue = orders.count > 0 ? "\(orders.count)" : nil
    }
    
    @objc func updateBadgeNum(_ notification: Notification) {
        if let userInfo = notification.userInfo, let itemCount = userInfo["itemCount"] as? Int {
            let tabBarItem = tabBarController?.tabBar.items?[2]
            tabBarItem?.badgeValue = itemCount > 0 ? "\(itemCount)" : nil
        }
    }
    
    // MARK: Data Loading Methods
    private func loadInitialData() {
        Task {
            await setupMarketManager()
        }
    }
    
    private func refreshData() {
        Task {
            await setupMarketManager()
            DispatchQueue.main.async {
                self.tableView.mj_header?.endRefreshing()
            }
        }
    }
    
    private func setupMarketManager() async {
        MarketManager.shared.delegate = self
        await MarketManager.shared.getMarketingHots()
    }
}


// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return marketingHots.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marketingHots[section].products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = marketingHots[indexPath.section].products[indexPath.row]
        
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Type1Cell", for: indexPath) as! Type1Cell 
            cell.configure(with: product)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Type2Cell", for: indexPath) as! Type2Cell
            cell.configure(with: product)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    // Header view 設定
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // header
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        // label
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        
        label.text = marketingHots[section].title
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([   // label在header view中的位置設定
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showHomeDetail", sender: tableView.cellForRow(at: indexPath))
        
    }
}

// MARK: - MarketManagerDelegate
extension HomeViewController: MarketManagerDelegate {
    @MainActor
    func manager(_ manager: MarketManager, didGet marketingHots: [Hot]) {
        DispatchQueue.main.async {
            self.marketingHots = marketingHots  // 更新數據
            self.tableView.reloadData()
        }
    }
    
    func manager(_ manager: MarketManager, didFailWith error: Error) {
        DispatchQueue.main.async {
            print("Error: \(error)")
        }
    }
}
