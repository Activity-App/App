//
//  OnboardingPrivacyView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct OnboardingPrivacyView: View {
    
    @Binding var showOnboarding: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("We value your privacy.")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 16)
            
            ScrollView {
                VStack(alignment: .leading) {
                    OnboardingInfoCell(
                        title: "Sharing",
                        subTitle: "We don't share your data with other companies",
                        imageName: "square.and.arrow.up.on.square"
                    )
                    OnboardingInfoCell(
                        title: "This is a splash screen",
                        subTitle: "something about using the apple watch trainings",
                        imageName: "applewatch.watchface"
                    )
                    OnboardingInfoCell(
                        title: "Test",
                        subTitle: "idk maybe something else",
                        imageName: "pencil"
                    )
                }
            }
            
            Spacer()

            RoundedNavigationLink("Continue", destination: OnboardingSignUpView(showOnboarding: $showOnboarding))
        }
        .padding(.horizontal)
        .navigationTitle("Privacy")
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPrivacyView(showOnboarding: .constant(true))
    }
}
