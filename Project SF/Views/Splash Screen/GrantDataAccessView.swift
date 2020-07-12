//
//  GrantDataAccessView.swift
//  Project SF
//
//  Created by Roman Esin on 12.07.2020.
//

import SwiftUI

struct GrantDataAccessView: View {

    @StateObject var healthKit = HealthKitController()

    var body: some View {
        VStack {
            Text("This application will need access to your health data to calculate the points in competitions.")
                .padding(.horizontal, 16)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            RoundedButton("Grant Health Data Access") {
                healthKit.authorizeHealthKit()
            }
        }
        .padding(.horizontal)
        .navigationTitle("Health Data")
    }
}

struct GrantDataAccessView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GrantDataAccessView()
        }
    }
}
