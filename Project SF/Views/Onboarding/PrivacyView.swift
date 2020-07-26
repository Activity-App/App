//
//  PrivacyView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct PrivacyView: View {
    
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
                        title: "Your data is yours.",
                        subTitle: "We don't sell or collect data because it belongs to you. Full stop.",
                        imageName: "key.fill"
                    )
                    OnboardingInfoCell(
                        title: "You choose what you share.",
                        subTitle: "All users will be able to see your username and that's it. You can explicitly state whether you want to expose your name, bio or profile picture with other users.",
                        imageName: "lock.shield.fill"
                    )
                    OnboardingInfoCell(
                        title: "Data is only shared with specific individuals.",
                        subTitle: "Your activity and competition data will only be seen by you, people in a competition with you and people you are friends with. Not even we can see it.",
                        imageName: "figure.walk"
                    )
                }
            }
            
            Spacer()

            RoundedNavigationLink("Continue", destination: SignUpView(showOnboarding: $showOnboarding))
        }
        .padding(.horizontal)
        .navigationTitle("Privacy")
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView(showOnboarding: .constant(true))
    }
}
