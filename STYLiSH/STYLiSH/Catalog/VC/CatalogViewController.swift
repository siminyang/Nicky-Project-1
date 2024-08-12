//
//  CatalogViewController.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/22.
//

import UIKit
import MJRefresh

class CatalogViewController: UIViewController {
    
    // MARK: - Property
    @IBOutlet weak var womenButton: UIButton!
    @IBOutlet weak var menButton: UIButton!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var catalogCollectionView: UICollectionView!
    @IBOutlet weak var underlineLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineBackgroundView: UIView!
    var currentProducts: [Product] = []
    var nextPaging: Int?
    var currentCategory: ProductCategory = .women
    var marketingHots: [Hot] = []
    var orders: [OrderDB] = []
    
    
    // MARK: - Category
    enum ProductCategory {
        case women, men, accessories
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(for: womenButton)    
        setupCollectionView()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadInitialData()
    }
    
    // MARK: - Action
    @IBAction func tabButtonTapped(_ sender: UIButton) {
        setupUI(for: sender)
    }
    
    @IBAction func unwindToCatalogVC(segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCatalogDetail" {
            if let detailVC = segue.destination as? HomeDetailViewController,
               let cell = sender as? UICollectionViewCell,
               let indexPath = catalogCollectionView.indexPath(for: cell) {
                let product = currentProducts[indexPath.item]
                detailVC.product = product
                detailVC.shouldUnwindToHomeVC = false
                detailVC.shouldUnwindToCatalogVC = true
            }
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI(for sender: UIButton) {
        updateTintColor(for: sender)
        updateUnderline(for: sender)
        updateContent(for: sender)
    }
    
    
    // 按鈕文字顏色
    private func updateTintColor(for sender: UIButton) {
        [womenButton, menButton, accessoryButton].forEach { button in
            button?.tintColor = (button == sender) ? .black : .gray
        }
    }
    
    // 動畫
    private func updateUnderline(for sender: UIButton) {
        let buttonWidth = sender.frame.width
        let buttonMinX = sender.frame.minX
        
        underlineLeadingConstraint.constant = buttonMinX
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.underlineLeadingConstraint.constant = buttonMinX
            self.underlineView.frame.size.width = buttonWidth
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // 頁面內容更新
    private func updateContent(for sender: UIButton) {
        if sender == womenButton {
            currentCategory = .women
        } else if sender == menButton {
            currentCategory = .men
        } else if sender == accessoryButton {
            currentCategory = .accessories
        }

        loadInitialData()
    }
    
    private func setupCollectionView() {
        catalogCollectionView.dataSource = self
        catalogCollectionView.delegate = self
        CatalogManager.shared.delegate = self
    }
    
    private func setupRefreshControl() {
        MJRefreshConfig.default.languageCode = "en"
        catalogCollectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadInitialData()
        })
        
        catalogCollectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadMoreData()
        })
    }
    
    // MARK: - Data Loading Methods
    private func loadInitialData() {
        nextPaging = nil  // 重置 nextPaging
        currentProducts = []
        catalogCollectionView.reloadData()

        catalogCollectionView.performBatchUpdates({     // 批次更新
            catalogCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: { _ in
            switch self.currentCategory {
            case .women:
                CatalogManager.shared.fetchWomenProducts(paging: 0)
            case .men:
                CatalogManager.shared.fetchMenProducts(paging: 0)
            case .accessories:
                CatalogManager.shared.fetchAccessoriesProducts(paging: 0)
            }
        })
    }
    
    private func loadMoreData() {
        guard let nextPaging = nextPaging else {
            catalogCollectionView.mj_footer?.endRefreshingWithNoMoreData()
            return
        }
        
        switch currentCategory {
        case .women:
            CatalogManager.shared.fetchWomenProducts(paging: nextPaging)
        case .men:
            CatalogManager.shared.fetchMenProducts(paging: nextPaging)
        case .accessories:
            CatalogManager.shared.fetchAccessoriesProducts(paging: nextPaging)
        }
    }
}


// MARK: - UICollectionViewDataSource
extension CatalogViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCell", for: indexPath) as! CatalogCell
        cell.configure(with: currentProducts[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CatalogViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth: CGFloat = UIScreen.main.bounds.width - 32
        let spacing: CGFloat = 16
        let width = (screenWidth - spacing) / 2
        return CGSize(width: width, height: width * 2)
    }
}

// MARK: - CatalogManagerDelegate
extension CatalogViewController: CatalogManagerDelegate {
    func manager(_ manager: CatalogManager, didGetProducts productsData: [Product], nextPaging: Int?) {
        
        DispatchQueue.main.async {
            
            if self.nextPaging == nil {   // case: 初始頁面或下拉刷新
                self.currentProducts = productsData
            } else {    // case: 加載更多
                self.currentProducts += productsData
            }
            
            self.nextPaging = nextPaging
            
            self.catalogCollectionView.performBatchUpdates({
                self.catalogCollectionView.reloadSections(IndexSet(integer: 0))
            }, completion: { _ in
                self.catalogCollectionView.mj_header?.endRefreshing()
                
                if nextPaging == nil {
                    self.catalogCollectionView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.catalogCollectionView.mj_footer?.endRefreshing()
                }
            })
        }
    }
    
    func manager(_ manager: CatalogManager, didFailWith error: Error) {
        
        DispatchQueue.main.async {
            print("Error: \(error)")
            self.catalogCollectionView.mj_header?.endRefreshing()
            self.catalogCollectionView.mj_footer?.endRefreshing()
        }
    }
}

