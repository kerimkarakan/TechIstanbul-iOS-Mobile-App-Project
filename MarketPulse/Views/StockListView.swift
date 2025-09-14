//
//  StockListView.swift
//  MarketPulse
//
//  Created by Kerim Karakan on 13.09.2025.
//

import SwiftUI

struct StockListView: View {
    @StateObject private var viewModel = StockListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background for stock market feel
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom header with MP logo
                    HeaderView()
                        .padding(.top)
                    
                    Group {
                        if viewModel.isLoading {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Loading stock data...")
                                    .foregroundColor(.gray)
                                    .padding(.top)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewModel.stocks.isEmpty {
                            VStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("No stock data available")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                Button("Retry") {
                                    viewModel.refreshStocks()
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(viewModel.stocks) { stock in
                                NavigationLink(destination: StockDetailView(symbol: stock.symbol)) {
                                    StockRowView(stock: stock)
                                }
                                .listRowBackground(Color.black)
                            }
                            .listStyle(PlainListStyle())
                            .scrollContentBackground(.hidden)
                            .refreshable {
                                viewModel.refreshStocks()
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $viewModel.showingAlert) {
                Button("OK") { }
                Button("Retry") {
                    viewModel.refreshStocks()
                }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 20) {
            // MP Logo centered at the top
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                
                Text("MP")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

struct StockRowView: View {
    let stock: Stock
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(formattedPrice(stock.price))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                // Percentage change with color coding
                Text(formattedPercentage(stock.changePercent))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(percentageColor(stock.changePercent))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(percentageColor(stock.changePercent).opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formattedPrice(_ price: String) -> String {
        if let doublePrice = Double(price) {
            return String(format: "%.2f", doublePrice)
        }
        return price
    }
    
    private func formattedPercentage(_ percentage: String) -> String {
        // Remove any existing % and clean the string
        let cleanPercentage = percentage.replacingOccurrences(of: "%", with: "")
        if let doublePercentage = Double(cleanPercentage) {
            let sign = doublePercentage >= 0 ? "+" : ""
            return "\(sign)\(String(format: "%.2f", doublePercentage))%"
        }
        return percentage
    }
    
    private func percentageColor(_ percentage: String) -> Color {
        let cleanPercentage = percentage.replacingOccurrences(of: "%", with: "")
        if let doublePercentage = Double(cleanPercentage) {
            return doublePercentage >= 0 ? .green : .red
        }
        return .gray
    }
}

#Preview {
    StockListView()
}
