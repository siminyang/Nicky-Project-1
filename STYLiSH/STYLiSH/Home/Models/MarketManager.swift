//
//  MarketManager.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/18.
//

/*
 This document is for fetching data from Marketing Hots API
 */

import Foundation

// MARK: - Objects: JSON 物件架構
struct MarketingHotsResponse: Codable {
    let data: [Hot]
}

struct Hot: Codable {
    let title: String
    let products: [Product]
}

struct Product: Codable {
    let id: Int
    let category: String
    let title: String
    let description: String
    let price: Int
    let texture: String
    let wash: String
    let place: String
    let note: String
    let story: String
    let colors: [Color]
    let sizes: [String]
    let variants: [Variant]
    let mainImage: String
    let images: [String]
}

struct Color: Codable {
    let code: String
    let name: String
}

struct Variant: Codable {
    let colorCode: String
    let size: String
    let stock: Int
}

// MARK: - Category
enum MarketManagerError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}


// MARK: - Protocol
protocol MarketManagerDelegate {
    func manager(_ manager: MarketManager, didGet marketingHots: [Hot])
    func manager(_ manager: MarketManager, didFailWith error: Error)
}

// MARK: - Methods: Fetching data from API
class MarketManager {
    static let shared = MarketManager()
    var delegate: MarketManagerDelegate?
    
    func getMarketingHots() async {
        do {
            let response = try await fetchData()
            delegate?.manager(self, didGet: response.data)
        } catch {
            delegate?.manager(self, didFailWith: error)
        }
    }
    
    func fetchData() async throws -> MarketingHotsResponse {
        guard let url = URL(string: "https://api.appworks-school.tw/api/1.0/marketing/hots") else {
            throw MarketManagerError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MarketManagerError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(MarketingHotsResponse.self, from: data)
        } catch {
            throw MarketManagerError.invalidData
        }
    }
}
