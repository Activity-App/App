//
//  OnboardingView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct OnboardingView: View {
    
    @Binding var showOnboarding: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("This is an app about fitness challanges.")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        OnboardingInfoCell(
                            title: "Test title",
                            subTitle: "Some text that we use the data phom the phone",
                            imageName: "iphone"
                        )
                        OnboardingInfoCell(
                            title: "This is a splash screen",
                            subTitle: "something about using the apple watch trainings",
                            imageName: "applewatch.watchface"
                        )
                        OnboardingInfoCell(
                            title: "Lightning fast",
                            subTitle: "I hope everything will work as fast as possible..",
                            imageName: "bolt"
                        )
                        OnboardingInfoCell(
                            title: "Lightning fast",
                            subTitle: "I hope everything will work as fast as possible..",
                            imageName: "bolt"
                        )
                    }
                }
                
                Spacer()

                RoundedNavigationLink("Continue", destination: PrivacyView(showOnboarding: $showOnboarding))
            }
            .padding(.horizontal)
            .navigationTitle("Welcome")
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showOnboarding: .constant(true))
    }
}
