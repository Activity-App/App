//
//  OnboardingInfoCell.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct OnboardingInfoCell: View {
    var title: String
    var subTitle: String
    var imageName: String

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundColor(.accentColor)
                .padding()
                .frame(width: 60, height: 60)
                .aspectRatio(contentMode: .fit)

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

struct InfoCell_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingInfoCell(title: "dsafs", subTitle: "112rqwff", imageName: "pencil")
    }
}
