//
//  CompetitionsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct CompetitionsView: View {

    @StateObject var healthKit = HealthKitController()

    var body: some View {
        NavigationView {
            List {
                Section {
                    CompetitionCell(healthKit)
                }

                Section {
                    CompetitionCell(healthKit)
                }

                Section {
                    CompetitionCell(healthKit)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Competitions")
        }
        .tabItem {
            VStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 18))
                Text("Competitions")
            }
        }
    }
}

struct CompetitionsView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionsView()
    }
}