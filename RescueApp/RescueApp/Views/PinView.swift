//
//  PinView.swift
//  RescueApp
//
//  Created by Alexandra Marum on 11/3/24.
//

import SwiftUI

struct FloodPin: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("flooding")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .background() {
                    Circle()
                        .offset(x: -0.20, y: -0.5)
                        .frame(width: 33, height: 33)
                }
                .padding(.bottom, 6)
//            Image(systemName: "triangle.fill")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 10, height: 10)
//                .rotationEffect(Angle(degrees: 180))
//                .offset(y: -4)
//                .foregroundStyle(Color("blue"))
//                .padding(.bottom)
        }
    }
}

struct ShelterPin: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("home")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .background() {
                    Circle()
                        .offset(x: 0.25, y: 0.5)
                        .frame(width: 33, height: 33)
                }
                .padding(.bottom, 6)
        }
    }
}

struct RoadPin: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("road-closure")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .background() {
                    Circle()
                        .offset(x: 0.8, y: -0.8)
                        .frame(width: 33, height: 33)
                }
                .padding(.bottom, 6)
        }
    }
}

struct SosPin: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "sos.circle.fill")
                .resizable()
                .foregroundStyle(Color("red"))
                .scaledToFit()
                .frame(width: 35, height: 35)
                .background() {
                    Circle()
                        .frame(width: 33, height: 33)
                }
                .padding(.bottom, 6)
        }
    }
}

struct ResourcePin: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "bag.circle")
                .resizable()
                .foregroundStyle(Color("blue"))
                .scaledToFit()
                .frame(width: 35, height: 35)
                .background() {
                    Circle()
                        .frame(width: 33, height: 33)
                }
                .padding(.bottom, 6)
        }
    }
}

struct OtherPin: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("more")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .background() {
                    Circle()
                        .offset(x: -0.52, y: -0.5)
                        .frame(width: 33, height: 33)
                }
                .padding(.bottom, 6)
        }
    }
}

#Preview {
    OtherPin()
        .preferredColorScheme(.dark)
}
