//
//  GrantiCloudAccessView.swift
//  Project SF
//
//  Created by Roman Esin on 12.07.2020.
//

import SwiftUI

struct GrantiCloudAccessView: View {

    @Binding var showOnboarding: Bool
    @EnvironmentObject var healthKit: HealthKitController

    @State var beatingHeart = false

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "icloud.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.red)
                .padding(50)
                .padding(beatingHeart ? 10 : 0)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        self.beatingHeart.toggle()
                    }
                }
                .opacity(0.8)
            Spacer()

            RoundedButton("Grant iCloud Access") {
                healthKit.authorizeHealthKit {
                    if healthKit.authorizationState == .granted {
                        showOnboarding = false
                        healthKit.updateTodaysActivityData()
                    }
                }
            }
            .padding()
            Text("This application uses Apple's iCloud to store the competitions.")
                .padding(.horizontal, 16)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        .navigationTitle("Health Data")
        .highPriorityGesture(DragGesture())
    }
}

struct GrantiCloudAccessView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GrantDataAccessView(showOnboarding: .constant(true))
        }
    }
}
