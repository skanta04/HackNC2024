//
//  LoadingView.swift
//  RescueApp
//
//  Created by Sruthy Mammen on 11/2/24.
//
//


import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var progress: Double = 0.0
    @State private var navigateToHistory = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("beige") // Background color from asset catalog
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Image("ecoalertsymbol")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300) // Increased size for emphasis
                        .padding(.top, -100) // Move image up

                    // Custom Progress Bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3)) // Background of progress bar
                            .frame(width: 300, height: 12) // Sleeker, thicker background bar

                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("darkblue")) // Foreground color for progress using darkBlue asset
                            .frame(width: CGFloat(progress * 3), height: 12) // Adjust width based on progress
                            .animation(.easeInOut(duration: 0.5), value: progress) // Smooth animation
                    }
                    .padding(.top, 20)
                }

                // Navigation Link to HistoryView
                NavigationLink(destination: HistoryView(), isActive: $navigateToHistory) {
                    EmptyView()
                }
            }
            .onAppear {
                startLoading()
            }
        }
    }
    
    func startLoading() {
        // Simulate loading progress over 3 seconds
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if self.progress < 100 {
                self.progress += 1
            } else {
                timer.invalidate()
                self.navigateToHistory = true // Transition to HistoryView
            }
        }
    }
}

#Preview {
    LoadingView()
}
