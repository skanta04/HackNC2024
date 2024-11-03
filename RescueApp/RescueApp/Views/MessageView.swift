//
//  MessageView.swift
//  RescueApp
//
//  Created by Alexandra Marum on 11/3/24.
//

import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct MessageView: View {
    var currentLocation: CLLocationCoordinate2D
    var message: Message
    
    @ViewBuilder
    var pin: some View {
        switch message.category {
        case .roadClosure:
            RoadBadge()
        case .flooding:
            FloodBadge()
        case .shelter:
            ShelterBadge()
        case .resource:
            ResourceBadge()
        case .sos:
            SosBadge()
        case .other:
            OtherBadge()
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 15) {
                VStack {
                    pin
                        .padding(.horizontal)
                    Text(message.status.rawValue)
                        .italic()
                        .font(.callout)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(message.category.rawValue)
                        .bold()
                        .font(.title2)
                        .fontDesign(.rounded)
                    
                    Text(message.content)
                        .fontDesign(.rounded)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    
                    Text("\(message.latitude), \(message.longitude)")
                        .font(.callout)
                        .fontDesign(.rounded)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(width: 320)
            .background(
                message.category == .sos ? Color("red") : Color("lightblue"),
                in: RoundedRectangle(cornerRadius: 15, style: .continuous)
            )
            .shadow(radius: 8, y: 4)
            .padding(.bottom, 15)
        }
    }
    
    private func calcDistance() -> Int {
        let distanceInMeters = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            .distance(from: CLLocation(latitude: message.latitude, longitude: message.longitude))
        let distanceInFeet = distanceInMeters * 3.28084
        return Int(distanceInFeet)
    }
}

struct FloodBadge: View {
    var body: some View {
        Image("flooding")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }
}

struct ShelterBadge: View {
    var body: some View {
        Image("home")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }
}

struct RoadBadge: View {
    var body: some View {
        Image("road-closure")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }
}

struct SosBadge: View {
    var body: some View {
        Image(systemName: "sos.circle.fill")
            .resizable()
            .foregroundStyle(.white)
            .scaledToFit()
            .frame(width: 50, height: 50)
    }
}

struct ResourceBadge: View {
    var body: some View {
        Image(systemName: "bag.circle.fill")
            .resizable()
            .foregroundStyle(Color("blue"))
            .scaledToFit()
            .frame(width: 50, height: 50)
    }
}

struct OtherBadge: View {
    var body: some View {
        Image("more")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }
}

#Preview {
    MessageView(currentLocation: CLLocationCoordinate2D(latitude: 10.0, longitude: 10.0), message: Message.example1)
}
