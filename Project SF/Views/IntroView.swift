//
//  IntroView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct InfoCell: View {
    var title: String
    var subTitle: String
    var image: Image

    var body: some View {
        HStack(alignment: .center) {
            image
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding()

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subTitle)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top)
    }
}

struct IntroView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Spacer()
                Text("This is an app about fitness challanges")
                    .font(.headline)

                InfoCell(title: "Test title", subTitle: "Some text that we use the data phom the phone", image: Image(systemName: "iphone"))
                InfoCell(title: "This is a splash screen", subTitle: "something about using the apple watch trainings", image: Image(systemName: "applewatch.watchface"))
                InfoCell(title: "Test", subTitle: "idk maybe something else", image: Image(systemName: "pencil"))
                Spacer()

                RoundedNavigationLink("Continue", destination: Text("asd"))
            }.padding(.horizontal)
            .navigationTitle("Welcome")
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
