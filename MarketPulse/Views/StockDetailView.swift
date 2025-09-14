//
//  StockDetailView.swift
//  MarketPulse
//
//  Created by Kerim Karakan on 13.09.2025.
//

import SwiftUI

struct StockDetailView: View {
    let symbol: String
    @StateObject private var viewModel = StockDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading stock details...")
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else if let stockDetail = viewModel.stockDetail {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(stockDetail.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        
                        Text(stockDetail.symbol)
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal)
                    
                    // Key Metrics Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Metrics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            MetricCardView(
                                title: "Market Cap",
                                value: formatMarketCap(stockDetail.marketCapitalization),
                                icon: "building.2"
                            )
                            
                            MetricCardView(
                                title: "P/E Ratio",
                                value: stockDetail.peRatio == "-" ? "N/A" : stockDetail.peRatio,
                                icon: "chart.bar"
                            )
                            
                            MetricCardView(
                                title: "52-Week High",
                                value: "$\(formatPrice(stockDetail.weekHigh52))",
                                icon: "arrow.up.circle"
                            )
                            
                            MetricCardView(
                                title: "52-Week Low",
                                value: "$\(formatPrice(stockDetail.weekLow52))",
                                icon: "arrow.down.circle"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Company Description Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Text(stockDetail.description.isEmpty ? "No description available." : stockDetail.description)
                            .font(.body)
                            .lineSpacing(4)
                            .padding(.horizontal)
                    }
                } else {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        Text("Failed to load stock details")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            viewModel.fetchStockDetail(for: symbol)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                }
            }
        }
        .navigationTitle(symbol)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchStockDetail(for: symbol)
        }
        .alert("Error", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
            Button("Retry") {
                viewModel.fetchStockDetail(for: symbol)
            }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func formatMarketCap(_ marketCap: String) -> String {
        guard let value = Double(marketCap) else { return "N/A" }
        
        if value >= 1_000_000_000_000 {
            return String(format: "%.2fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "%.2fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "%.2fM", value / 1_000_000)
        } else {
            return String(format: "%.0f", value)
        }
    }
    
    private func formatPrice(_ price: String) -> String {
        if let doublePrice = Double(price) {
            return String(format: "%.2f", doublePrice)
        }
        return price
    }
}

struct MetricCardView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        StockDetailView(symbol: "AAPL")
    }
}