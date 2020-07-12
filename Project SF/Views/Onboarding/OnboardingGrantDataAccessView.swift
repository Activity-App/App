//
//  OnboardingGrantDataAccessView.swift
//  Project SF
//
//  Created by Roman Esin on 12.07.2020.
//

import SwiftUI

struct OnboardingGrantDataAccessView: View {

    @Binding var showOnboarding: Bool
    @EnvironmentObject var healthKit: HealthKitController
    
    @State var beatingHeart = false

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "heart.fill")
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
            
            RoundedButton("Grant Health Data Access") {
                healthKit.authorizeHealthKit {
                    if healthKit.authorizationState == .granted {
                        showOnboarding = false
                        healthKit.updateTodaysActivityData()
                    }
                }
            }
            Text("This application needs access to your health data to calculate the points in competitions.")
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

struct GrantDataAccessView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingGrantDataAccessView(showOnboarding: .constant(true))
        }
    }
}
