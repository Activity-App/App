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
<<<<<<< HEAD
                    CompetitionCell(healthKit)
                }

                Section {
                    CompetitionCell(healthKit)
                }

                Section {
                    CompetitionCell(healthKit)
=======
                    CompetitionCell("CompetitionName", endsOn: Date() + 1000, healthKit)
                }

                Section {
                    CompetitionCell("CompetitionName", endsOn: Date() + 10000, healthKit)
                }

                Section {
                    CompetitionCell("CompetitionName", endsOn: Date() + 100000, healthKit)
>>>>>>> development
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Competitions")
        }
        .tabItem {
<<<<<<< HEAD
            Label("Competitions", systemImage: "star.fill")
=======
            VStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 18))
                Text("Competitions")
            }
>>>>>>> development
        }
    }
}

struct CompetitionsView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionsView()
    }
}
