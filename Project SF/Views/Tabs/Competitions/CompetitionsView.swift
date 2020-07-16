//
//  CompetitionsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI

struct Competition: Identifiable {
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
    
    // Temporary. Get these from CK when thats working.
    var competitions: [Competition] = [
        Competition(
            name: "Competition1",
            startDate: Date() - 100000,
            endDate: Date() + 100000,
            creatingUser: CompetingPerson(name: "Me", points: 300),
            people: [
                CompetingPerson(name: "Person1", points: 100),
                CompetingPerson(name: "Person2", points: 200),
                CompetingPerson(name: "Person3", points: 6000)
            ]
        ),
        Competition(
            name: "Competition2",
            startDate: Date(),
            endDate: Date() + 1000000,
            creatingUser: CompetingPerson(name: "Me", points: 5500),
            people: [
                CompetingPerson(name: "Person1", points: 5000),
                CompetingPerson(name: "Person2", points: 200),
                CompetingPerson(name: "Person3", points: 500)
            ]
        )
    ]

    var recentCompetitions: [Competition] = [
        Competition(
            name: "Competition1",
            startDate: Date() - 100000,
            endDate: Date() - 1000,
            creatingUser: CompetingPerson(name: "Me", points: 50),
            people: [
                CompetingPerson(name: "Person1", points: 100),
                CompetingPerson(name: "Person2", points: 200),
                CompetingPerson(name: "Person3", points: 6000)
            ]
        ),
        Competition(
            name: "Competition2",
            startDate: Date() - 100000,
            endDate: Date() - 10000,
            creatingUser: CompetingPerson(name: "Me", points: 300),
            people: [
                CompetingPerson(name: "Person1", points: 5000),
                CompetingPerson(name: "Person2", points: 200),
                CompetingPerson(name: "Person3", points: 500)
            ]
        )
    ]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current Activity")) {
                    ActivityOverview(activity: $healthKit.latestActivityData)
                }

                Section(header: Text("Currently competing")) {
                    ForEach(competitions.indices) { index in
                        CompetitionCell(competitions[index])
                    }
                }

                Section(header: Text("Recent competitions")) {
                    ForEach(recentCompetitions.indices) { index in
                        CompetitionCell(competitions[index])
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
        }
        .sheet(isPresented: $showCreateCompetition) {
            CreateCompetition()
        }

    }
}

struct CompetitionsView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionsView()
            .environmentObject(HealthKitController())
    }
}
