//
//  CompetitionsView.swift
//  Project SF
//
//  Created by Roman Esin on 11.07.2020.
//

import SwiftUI
import CloudKit

struct CompetitionsView: View {

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var healthKit: HealthKitController
    @State var showCreateCompetition = false
    
    @EnvironmentObject var alert: AlertManager
    @EnvironmentObject var friendController: FriendController
    
    @StateObject var competitionsController = CompetitionsController()
    let friends = FriendRequestManager()

    var body: some View {
        NavigationView {
            List {
//                Button("access") {
//                    friends.requestDiscoveryPermission { _ in }
//                }
//                Button("search") {
//                    friends.discoverFriends { result in print(result) }
//                }
                Button("Allow Notifications") {
                    NotificationManager.shared.requestPermission { error in
                        print(error ?? "success")
                    }
                }
                Button("Subscribe to changes") {
                    friends.subscribeToFriendRequests { error in
                        print(error ?? "success")
                    }
                }
                Button("Invite user") {
                    friends.invite(users: ["_ca83d0962e8569057e2d4bece6c0a335"]) { error in
                        print(error ?? "success")
                    }
                }
                
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
                .environmentObject(friendController)
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
