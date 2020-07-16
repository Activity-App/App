//
//  FriendsCell.swift
//  Project SF
//
//  Created by Roman Esin on 14.07.2020.
//

import SwiftUI

struct FriendsCell: View {

    let friend: TemporaryFriend

    var body: some View {
        NavigationLink(destination: FriendDetailView(friend)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(friend.name)
                        .font(.title3)
                        .fontWeight(.black)
                        .padding(.bottom, 4)
                        .foregroundColor(.white)
                    Text("Move: \(friend.activity.moveFraction)")
                        .foregroundColor(RingType.move.color)
                        .fontWeight(.medium)
                    Text("Exercise: \(friend.activity.exerciseFraction)")
                        .foregroundColor(RingType.exercise.color)
                        .fontWeight(.medium)
                    Text("Stand: \(friend.activity.standFraction)")
                        .foregroundColor(RingType.stand.darkColor)
                        .fontWeight(.medium)
                }
                Spacer()
                ActivityRingsView(values: .constant(friend.activity), ringSize: .small)
                    .padding(.vertical, 12)
                    .padding(.trailing, 6)
            }
        }
    }

    init(_ friend: TemporaryFriend) {
        self.friend = friend
    }
}

struct FriendsCell_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoundedNavigationLink("Show", destination:
                                    GroupBox {
                                        FriendsCell(TemporaryFriend(
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
            )
        }
    }
}
