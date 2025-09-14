//
//  StockDetailViewModel.swift
//  MarketPulse
//
//  Created by Kerim Karakan on 13.09.2025.
//

import Foundation
import Combine

class StockDetailViewModel: ObservableObject {
    @Published var stockDetail: StockDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAlert = false
    
    private let apiService = StockAPIService()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchStockDetail(for symbol: String) {
        isLoading = true
        errorMessage = nil
        stockDetail = nil
        
        apiService.fetchCompanyOverview(for: symbol)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showingAlert = true
                    }
                },
                receiveValue: { [weak self] overview in
                    self?.stockDetail = StockDetail(from: overview)
                }
            )
            .store(in: &cancellables)
    }
}