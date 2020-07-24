//
//  CompetitionsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct CompetitionStruct: Identifiable {
    var id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    let creatingUser: CompetingPerson
    var people: [CompetingPerson] = []
    
    var place: Int
    
    init(name: String, startDate: Date, endDate: Date, creatingUser: CompetingPerson, people: [CompetingPerson] = []) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.creatingUser = creatingUser
        self.people = people
        
        self.people.append(self.creatingUser)
        self.people.sort {
            $0.points > $1.points
        }
        
        let index = self.people.firstIndex(of: creatingUser) ?? 0
        self.place = index + 1
    }
}

struct CompetingPerson: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var points: Int = 0
    var history: [Int] = []
}

struct CompetitionsView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var healthKit: HealthKitController
    @State var showCreateCompetition = false
    
    @EnvironmentObject var alert: AlertManager
    
    @StateObject var competitionsController = CompetitionsController()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current Activity")) {
                    ActivityOverview(activity: $healthKit.latestActivityData)
                }

                Section(header: Text("Currently competing")) {
                    ForEach(competitionsController.competitions) { competition in
                        CompetitionCell(competition)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Competitions")
            .navigationBarItems(
                trailing: NavigationButton(
                    systemName: "plus",
                    action: { showCreateCompetition = true }
                )
            )
        }
        .tabItem {
            Label("Competitions", systemImage: "star.fill")
                .font(.title2)
        }
        .sheet(isPresented: $showCreateCompetition) {
            CreateCompetition()
                .environmentObject(competitionsController)
        }
        .onAppear {
            competitionsController.update()
        }
    }
}

struct CompetitionsView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionsView()
            .environmentObject(HealthKitController())
    }
}
