//
//  StockListViewModel.swift
//  MarketPulse
//
//  Created by Kerim Karakan on 13.09.2025.
//

import Foundation
import Combine

class StockListViewModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAlert = false
    
    private let apiService = StockAPIService()
    private var cancellables = Set<AnyCancellable>()
    
    // Popular stock symbols to track
    private let stockSymbols = ["AAPL", "MSFT", "GOOGL", "AMZN", "TSLA", "NVDA", "META"]
    
    init() {
        fetchAllStocks()
    }
    
    func fetchAllStocks() {
        isLoading = true
        errorMessage = nil
        stocks.removeAll()
        
        let publishers = stockSymbols.map { symbol in
            apiService.fetchStockData(for: symbol)
                .map(Optional.some)
                .catch { error -> AnyPublisher<Stock?, Never> in
                    print("Error fetching \(symbol): \(error.localizedDescription)")
                    return Just(nil).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] stocksArray in
                    self?.stocks = stocksArray.compactMap { $0 }.sorted { $0.symbol < $1.symbol }
                    if self?.stocks.isEmpty == true {
                        self?.errorMessage = "Failed to load stock data. Please try again."
                        self?.showingAlert = true
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshStocks() {
        fetchAllStocks()
    }
}
