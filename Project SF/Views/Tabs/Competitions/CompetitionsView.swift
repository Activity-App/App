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
                    CompetitionCell("CompetitionName", endsOn: Date() + 1000, healthKit)
                }

                Section {
                    CompetitionCell("CompetitionName", endsOn: Date() + 10000, healthKit)
                }

                Section {
                    CompetitionCell("CompetitionName", endsOn: Date() + 100000, healthKit)
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
