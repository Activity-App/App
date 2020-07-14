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
    var points: Int = 0
    var people: [CompetingPerson]
    
    var place: Int {
        let user = CompetingPerson(name: "Me", points: points)
        var competing = people
        
        competing.append(user)
        competing.sort {
            $0.points > $1.points
        }
        
        let index = competing.firstIndex(of: user) ?? 0
    
        return index + 1
    }
}

struct CompetingPerson: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var points: Int = 0
}

struct CompetitionsView: View {

    @EnvironmentObject var healthKit: HealthKitController
    @State var showCreateCompetition = false
    
    // Temporary. Get these from CK when thats working.
    var competitions: [Competition] = [
        Competition(
            name: "Competition1",
            startDate: Date() - 100000,
            endDate: Date() + 100000,
            points: 5987,
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
            points: 100,
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
            points: 5987,
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
            points: 100,
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
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Move: \(healthKit.latestActivityData.moveFraction)")
                                .foregroundColor(RingType.move.color)
                                .fontWeight(.medium)
                            Text("Exercise: \(healthKit.latestActivityData.exerciseFraction)")
                                .foregroundColor(RingType.exercise.color)
                                .fontWeight(.medium)
                            Text("Stand: \(healthKit.latestActivityData.standFraction)")
                                .foregroundColor(RingType.stand.darkColor)
                                .fontWeight(.medium)
                        }
                        Spacer()
                        ActivityRingsView(values: $healthKit.latestActivityData, ringSize: .medium)
                            .padding(.vertical, 12)
                    }
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
