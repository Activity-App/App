//
//  FriendDetailView.swift
//  Project SF
//
//  Created by Roman Esin on 14.07.2020.
//

import SwiftUI

struct FriendDetailView: View {

    @Environment(\.colorScheme) var colorScheme
    @State var isAlertShown = false
    let friend: Friend

    var competitions: [Competition] = [
        Competition(
            title: "Competition1",
            startDate: Date() - 100000,
            endDate: Date() + 100000
        ),
        Competition(
            title: "Competition2",
            startDate: Date(),
            endDate: Date() + 1000000
        )
    ]

    var body: some View {
        List {
            Section {
                Button(action: {

                }) {
                    HStack {
                        Image(systemName: "at")
                            .foregroundColor(.accentColor)
                        // TODO: Use username here
                        Text("\(friend.name)")
                            .minimumScaleFactor(0.7)
                    }
                }
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = friend.name
                    }) {
                        Label("Copy", systemImage: "doc.on.clipboard")
                    }
                }

                // TODO: add emails to friends
                Button(action: {
                    UIApplication.shared.open(URL(string: "mailto:thisIsSomeEmail@mailservice.com")!,
                                              options: [:],
                                              completionHandler: nil)
                }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.accentColor)
                        Text("thisIsSomeEmail@mailservice.com")
                            .minimumScaleFactor(0.7)
                    }
                }
                .contextMenu {
                    Button(action: {
                        UIApplication.shared.open(URL(string: "mailto:thisIsSomeEmail@mailservice.com")!,
                                                  options: [:],
                                                  completionHandler: nil)
                    }) {
                        Label("Write an email", systemImage: "square.and.pencil")
                    }
                }

                Button(action: {
                    isAlertShown = true
                }) {
                    HStack {
                        Image(systemName: "minus.circle")
                        Text("Unfriend")
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.accentColor)
            }
            .foregroundColor(.secondary)

            Section(header: Text("Current Activity")) {
                ActivityOverview(shouldAnimate: false, activity: .constant(friend.activityRings))
            }

            Section(header: Text("Current Competitions")) {
                ForEach(competitions.indices) { index in
                    CompetitionCell(competitions[index])
                }
            }

            Section(header: Text("Prizes")) {
                // TODO: Prizes
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(friend.name)
        .alert(isPresented: $isAlertShown) {
            Alert(title: Text("Are you sure youo want to unfriend \(friend.name)?"),
                  primaryButton: .destructive(Text("Unfriend")) {
                // TODO: Friend / Unfriend
            }, secondaryButton: .cancel(Text("Cancel")))
        }
    }

    init(_ friend: Friend) {
        self.friend = friend
    }
}

//struct FriendDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            FriendDetailView(TemporaryFriend(
//                name: "Friend3",
//                activity: .init(
//                    moveCurrent: 380,
//                    moveGoal: 400,
//                    exerciseCurrent: 39,
//                    exerciseGoal: 30,
//                    standCurrent: 14,
//                    standGoal: 12
//                )
//            ))
//        }
//    }
//}
