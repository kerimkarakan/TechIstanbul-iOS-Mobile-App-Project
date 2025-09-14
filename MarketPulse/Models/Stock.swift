//
//  Stock.swift
//  MarketPulse
//
//  Created by Kerim Karakan on 13.09.2025.
//

import Foundation

// Stock Model for List View
struct Stock: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: String
    let changePercent: String
    
    init(symbol: String, name: String, price: String, changePercent: String = "0.00%") {
        self.symbol = symbol
        self.name = name
        self.price = price
        self.changePercent = changePercent
    }
}

// Global Quote Response Model
struct GlobalQuoteResponse: Codable {
    let globalQuote: GlobalQuote
    
    enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
    }
}

struct GlobalQuote: Codable {
    let symbol: String
    let price: String
    let change: String
    let changePercent: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case price = "05. price"
        case change = "09. change"
        case changePercent = "10. change percent"
    }
}

// Company Overview Response Model
struct CompanyOverview: Codable {
    let symbol: String
    let name: String
    let description: String
    let marketCapitalization: String
    let peRatio: String
    let weekHigh52: String
    let weekLow52: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "Symbol"
        case name = "Name"
        case description = "Description"
        case marketCapitalization = "MarketCapitalization"
        case peRatio = "PERatio"
        case weekHigh52 = "52WeekHigh"
        case weekLow52 = "52WeekLow"
    }
}

// Stock Detail Model for Detail View
struct StockDetail: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let description: String
    let marketCapitalization: String
    let peRatio: String
    let weekHigh52: String
    let weekLow52: String
    
    init(from overview: CompanyOverview) {
        self.symbol = overview.symbol
        self.name = overview.name
        self.description = overview.description
        self.marketCapitalization = overview.marketCapitalization
        self.peRatio = overview.peRatio
        self.weekHigh52 = overview.weekHigh52
        self.weekLow52 = overview.weekLow52
    }
}
