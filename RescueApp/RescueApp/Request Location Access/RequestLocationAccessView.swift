//
//  RequestLocationAccessView.swift
//  RescueApp
//
//  Created by Alexandra Marum on 11/2/24.
//

import SwiftUI


// gives the reason why the user should allow us to view their location and contains the button that presents the system’s location permission prompt.

struct RequestLocationAccessView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
            VStack {
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .foregroundColor(.blue)

                Text("We will use your location to retrieve and send local emergency information!")
                    .multilineTextAlignment(.center)
                    .frame(width: 350)
                    .padding(8)
                
                Button {
                    locationManager.requestLocationAccess()
                } label: {
                    Text("Allow Access")
                        .font(.headline)
                        .foregroundColor(Color(.systemBlue))
                }
            }
    }
}

#Preview {
    RequestLocationAccessView(locationManager: LocationManager())
}
