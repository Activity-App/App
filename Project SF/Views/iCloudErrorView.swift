//
//  iCloudErrorView.swift
//  Project SF
//
//  Created by Roman Esin on 13.07.2020.
//

import SwiftUI

// swiftlint:disable type_name
struct iCloudErrorView: View {
    let error: String

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "icloud.slash.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.red)
                    .padding(50)
                VStack(spacing: 16) {
                    Text("There has been an error with connection to the iCloud.")
                    // TODO: Show different error description depending on the error
                    Text(error)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            }
            .foregroundColor(.secondary)
            .navigationTitle("iCloud Error")
        }
    }
}

// swiftlint:disable type_name
struct iCloudErrorView_Previews: PreviewProvider {
    static var previews: some View {
        iCloudErrorView(error: "123")
    }
}
