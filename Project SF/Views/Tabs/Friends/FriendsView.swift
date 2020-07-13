//
//  FriendsView.swift
//  Project SF
//
//  Created by Christian Privitelli on 12/7/20.
//

import SwiftUI

struct Friend: Identifiable {
    var id = UUID()
    var name: String
    var activity: ActivityRings
}

struct FriendsView: View {
    
    let friends: [Friend] = [
        Friend(
            name: "Friend1",
            activity: .init(
                moveCurrent: 10,
                moveGoal: 300,
                exerciseCurrent: 1,
                exerciseGoal: 30,
                standCurrent: 4,
                standGoal: 12
            )
        ),
        Friend(
            name: "Friend2",
            activity: .init(
                moveCurrent: 340,
                moveGoal: 300,
                exerciseCurrent: 28,
                exerciseGoal: 30,
                standCurrent: 6,
                standGoal: 12
            )
        ),
        Friend(
            name: "Friend3",
            activity: .init(
                moveCurrent: 380,
                moveGoal: 400,
                exerciseCurrent: 39,
                exerciseGoal: 30,
                standCurrent: 14,
                standGoal: 12
            )
        )
    ]

    var body: some View {
        NavigationView {
            List {
                Text("ACTIVITY")
                ForEach(friends) { friend in
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(friend.name)
                                    .font(.title3)
                                    .fontWeight(.black)
                                    .padding(.bottom, 4)
                                Text("Move: \(Int(friend.activity.moveCurrent))/\(Int(friend.activity.moveGoal))")
                                    .foregroundColor(RingType.move.color)
                                    .fontWeight(.medium)
                                Text("Exercise: \(Int(friend.activity.exerciseCurrent))/\(Int(friend.activity.exerciseGoal))")
                                    .foregroundColor(RingType.exercise.color)
                                    .fontWeight(.medium)
                                Text("Stand: \(Int(friend.activity.standCurrent))/\(Int(friend.activity.standGoal))")
                                    .foregroundColor(RingType.stand.darkColor)
                                    .fontWeight(.medium)
                            }
                            Spacer()
                            ActivityRingsView(values: .constant(friend.activity), ringSize: .small)
                                .padding(.vertical, 12)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Friends")
        }
        .tabItem {
            Label("Friends", systemImage: "person.3.fill")
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
