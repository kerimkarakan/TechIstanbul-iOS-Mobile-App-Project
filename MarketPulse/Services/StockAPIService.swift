//
//  StockAPIService.swift
//  MarketPulse
//
//  Created by Kerim Karakan on 13.09.2025.
//

import Foundation
import Combine

class StockAPIService: ObservableObject {
    private let apiKey = "UNZQA6OPUCYB4WZ1"
    private let baseURL = "https://www.alphavantage.co/query"
    private let session = URLSession.shared
    
    enum APIError: Error, LocalizedError {
        case invalidURL
        case noData
        case decodingError
        case networkError(Error)
        case apiLimitReached
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode response"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .apiLimitReached:
                return "API call limit reached. Please try again later."
            }
        }
    }
    
    // Fetch Global Quote (Price Data)
    func fetchGlobalQuote(for symbol: String) -> AnyPublisher<GlobalQuote, APIError> {
        guard let url = URL(string: "\(baseURL)?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(apiKey)") else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GlobalQuoteResponse.self, decoder: JSONDecoder())
            .map(\.globalQuote)
            .mapError { error in
                if error is DecodingError {
                    return APIError.decodingError
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Fetch Company Overview
    func fetchCompanyOverview(for symbol: String) -> AnyPublisher<CompanyOverview, APIError> {
        guard let url = URL(string: "\(baseURL)?function=OVERVIEW&symbol=\(symbol)&apikey=\(apiKey)") else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CompanyOverview.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return APIError.decodingError
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Fetch Stock Data (Combines Price and Overview)
    func fetchStockData(for symbol: String) -> AnyPublisher<Stock, APIError> {
        let quotePublisher = fetchGlobalQuote(for: symbol)
        let overviewPublisher = fetchCompanyOverview(for: symbol)
        
        return Publishers.Zip(quotePublisher, overviewPublisher)
            .map { quote, overview in
                Stock(symbol: symbol, name: overview.name, price: quote.price, changePercent: quote.changePercent)
            }
            .eraseToAnyPublisher()
    }
}
