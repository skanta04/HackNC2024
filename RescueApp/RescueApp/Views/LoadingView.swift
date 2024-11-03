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
    @Binding var progress: Double

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
                            .fill(Color("blue")) // Foreground color for progress using darkBlue asset
                            .frame(width: CGFloat(progress * 3), height: 12) // Adjust width based on progress
                            .animation(.easeInOut(duration: 0.5), value: progress) // Smooth animation
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
    
}

#Preview {
    LoadingView(progress: .constant(0.0))
}
