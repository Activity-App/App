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
    
    @State var competitions: [Competition] = []
    @EnvironmentObject var alert: AlertManager
    
    var competitionsController = CompetitionsController()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current Activity")) {
                    ActivityOverview(activity: $healthKit.latestActivityData)
                }

                Section(header: Text("Currently competing")) {
                    ForEach(competitions) { competition in
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
        }
        .onAppear {
            updateCompetitions()
        }
    }
    
    func updateCompetitions() {
        competitionsController.fetchCompetitions { result in
            switch result {
            case .success(let competitions):
                self.competitions = competitions.map { Competition(record: $0) }
            case .failure(let error):
                alert.present(
                    icon: "exclamationmark.icloud.fill",
                    message: "There was an error fetching competitions from iCloud. Please check you are connected to the internet and that your device is signed into iCloud.",
                    color: .orange,
                    buttonTitle: "Dismiss",
                    buttonAction: {
                        alert.dismiss()
                    }
                )
            }
        }
    }
}

struct CompetitionsView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionsView()
            .environmentObject(HealthKitController())
    }
}
