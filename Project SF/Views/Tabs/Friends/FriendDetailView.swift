//
//  FriendDetailView.swift
//  Project SF
//
//  Created by Roman Esin on 14.07.2020.
//

import SwiftUI

struct FriendDetailView: View {

    @Environment(\.colorScheme) var colorScheme
    let friend: Friend

    var competitions: [Competition] = [
        Competition(name: "Competition1", startDate: Date() - 100000, endDate: Date() + 100000),
        Competition(name: "Competition2", startDate: Date() - 100000, endDate: Date() + 30000000),
        Competition(name: "Competition3", startDate: Date() - 100000, endDate: Date() + 9900000)
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
                    // TODO: Unfriend / Friend
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
                HStack {
                    VStack(alignment: .leading) {
                        Text("Move: \(friend.activity.moveFraction)")
                            .foregroundColor(colorScheme == .light ?
                                                RingType.move.darkColor : RingType.move.color)
                            .fontWeight(.medium)
                        Text("Exercise: \(friend.activity.exerciseFraction)")
                            .foregroundColor(colorScheme == .light ?
                                                RingType.exercise.darkColor : RingType.exercise.color)
                            .fontWeight(.medium)
                        Text("Stand: \(friend.activity.standFraction)")
                            .foregroundColor(colorScheme == .light ?
                                                RingType.stand.darkColor : RingType.stand.color)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    ActivityRingsView(values: .constant(friend.activity), ringSize: .medium)
                        .padding(.vertical, 12)
                }
            }

            Section(header: Text("Current Competitions")) {
                ForEach(competitions.indices) { index in
                    CompetitionCell(
                        competitionName: competitions[index].name,
                        startDate: competitions[index].startDate,
                        endDate: competitions[index].endDate
                    )
                }
            }

            Section(header: Text("Prizes")) {
                // TODO: Prizes
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(friend.name)
    }

    init(_ friend: Friend) {
        self.friend = friend
    }
}

struct FriendDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FriendDetailView(Friend(
                name: "Friend3",
                activity: .init(
                    moveCurrent: 380,
                    moveGoal: 400,
                    exerciseCurrent: 39,
                    exerciseGoal: 30,
                    standCurrent: 14,
                    standGoal: 12
                )
            ))
        }
    }
}
