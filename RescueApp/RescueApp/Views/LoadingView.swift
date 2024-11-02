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

    var body: some View {
        VStack {
            Image("ecoalertsymbol")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear {
                    self.isAnimating = true
                }

            Text("Loading...")
                .font(.headline)
                .padding(.top, 20)
        }
    }
}
#Preview {
    LoadingView()
}



