//
//  HomeDetailViewController.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/24.
//

import UIKit
import Lottie

class HomeDetailViewController: UIViewController, UIViewControllerTransitioningDelegate, AddToCartViewControllerDelegate {
    
    // MARK: Property
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var hiddenView: UIView!
    
    var product: Product?
    var shouldUnwindToHomeVC = false
    var shouldUnwindToCatalogVC = false
    private var animationView: LottieAnimationView?
    
    // MARK: Action
    @IBAction func addToCartButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showAddToCartSegue", sender: self)
        hiddenView.isHidden = false
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if shouldUnwindToHomeVC {
            performSegue(withIdentifier: "unwindToHomeVCWithSegue", sender: self)
        } else if shouldUnwindToCatalogVC {
            performSegue(withIdentifier: "unwindToCatalogVCWithSegue", sender: self)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupCollectionView()
        setupPageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        hiddenView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func didTapCloseButton() {
        hiddenView.isHidden = true
    }
    
    // 加入購物車動畫
    func showAddToCartAnimation() {
        animationView = .init(name: "add_to_cart_animation")
        animationView?.frame = view.bounds
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .playOnce
        view.addSubview(animationView!)
        
        animationView?.play { [weak self] _ in
            self?.animationView?.removeFromSuperview()
        }
        
        hiddenView.isHidden = true
    }
    
    // MARK: Setup Methods
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = product?.images.count ?? 0
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddToCartSegue" {
            let addToCartVC = segue.destination as? AddToCartViewController
            addToCartVC?.modalPresentationStyle = .custom
            addToCartVC?.transitioningDelegate = self
            addToCartVC?.product = self.product
            addToCartVC?.colors = self.product?.colors.map { $0.code } ?? []
            addToCartVC?.sizes = self.product?.sizes ?? []
            addToCartVC?.delegate = self
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeDetailDescriptionCell", for: indexPath) as? HomeDetailDescriptionCell,
              let product = self.product else {
            return UITableViewCell()
        }
        cell.configure(with: product)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UICollectionViewDataSource
extension HomeDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeDetailImageCell", for: indexPath) as! HomeDetailImageCell
        
        if let imageUrl = product?.images[indexPath.item] {
            cell.configure(with: imageUrl)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeDetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

