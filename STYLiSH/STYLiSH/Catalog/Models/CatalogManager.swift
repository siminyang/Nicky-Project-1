//
//  CatalogManager.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/23.
//

import Foundation
import Alamofire

// MARK: - Objects: JSON物件架構
struct ProductResponse: Codable {
    let data: [Product]
    let nextPaging: Int?
}

class CacheWrapper: NSObject {
    let productResponse: ProductResponse
    
    init(productResponse: ProductResponse) {
        self.productResponse = productResponse
    }
}

// MARK: - Protocol
protocol CatalogManagerDelegate {
    func manager(_ manager: CatalogManager, didGetProducts productsData: [Product], nextPaging: Int?)
    func manager(_ manager: CatalogManager, didFailWith error: Error)
}

// MARK: - Methods: Fetching data from different 3 APIs
class CatalogManager {
    static let shared = CatalogManager()
    
    var delegate: CatalogManagerDelegate?
    private var currentTasks: Set<DataRequest> = []
    private let cache = NSCache<NSString, CacheWrapper>()   // <key type, value type>
    private init() {}
    
    func fetchWomenProducts(paging: Int?) {
        fetchData(category: "women", paging: paging)
    }
    
    func fetchMenProducts(paging: Int?) {
        fetchData(category: "men", paging: paging)
    }
    
    func fetchAccessoriesProducts(paging: Int?) {
        fetchData(category: "accessories", paging: paging)
    }
    
    func fetchData(category: String, paging: Int?) {
        cancelAllTasks()  
        
        var url = "https://api.appworks-school.tw/api/1.0/products/\(category)"
        if let paging = paging {
            url += "?paging=\(paging)"
        }
        
        // 建立緩存key
        let cacheKey = NSString(string: url)

        // 先檢查有沒有緩存資料，有的話直接取出來回傳
        if let cachedWrapper = cache.object(forKey: cacheKey) {
            let cachedResponse = cachedWrapper.productResponse
            DispatchQueue.main.async {
                self.delegate?.manager(self, didGetProducts: cachedResponse.data, nextPaging: cachedResponse.nextPaging)
            }
            
            return  // 結束fetchData()
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let task = AF.request(url).responseDecodable(of: ProductResponse.self, decoder: decoder) { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let productResponse):
                // 成功拿到資料後進行緩存
                let cacheWrapper = CacheWrapper(productResponse: productResponse)
                self.cache.setObject(cacheWrapper, forKey: cacheKey)
                
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didGetProducts: productResponse.data, nextPaging: productResponse.nextPaging)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didFailWith: error)
                }
            }
        }
        
        currentTasks.insert(task)
    }
    
    private func cancelAllTasks() {
        for task in currentTasks {
            task.cancel()
        }
        currentTasks.removeAll()
    }
}
