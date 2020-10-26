//
//  FriendsCell.swift
//  Project SF
//
//  Created by Roman Esin on 14.07.2020.
//

import SwiftUI

struct FriendsCell: View {

    let friend: ExternalUser

    var body: some View {
        NavigationLink(destination: FriendDetailView(friend: friend, competitions: [])) {
            HStack {
                VStack(alignment: .leading) {
                    Text(friend.name)
                        .font(.title3)
                        .fontWeight(.black)
                        .padding(.bottom, 4)
                    Text("Move: \(friend.activityRings.moveFraction)")
                        .foregroundColor(RingType.move.color)
                        .fontWeight(.medium)
                    Text("Exercise: \(friend.activityRings.exerciseFraction)")
                        .foregroundColor(RingType.exercise.color)
                        .fontWeight(.medium)
                    Text("Stand: \(friend.activityRings.standFraction)")
                        .foregroundColor(RingType.stand.darkColor)
                        .fontWeight(.medium)
                }
                Spacer()
                ActivityRingsView(values: .constant(friend.activityRings), ringSize: .small)
                    .padding(.vertical, 12)
                    .padding(.trailing, 6)
            }
        }
    }

    init(_ friend: ExternalUser) {
        self.friend = friend
    }
}
//
//struct FriendsCell_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            RoundedNavigationLink("Show", destination:
//                                    GroupBox {
//                                        FriendsCell(Friend(
//                                            name: "Friend3",
//                                            activityRings: .init(
//                                                moveCurrent: 380,
//                                                moveGoal: 400,
//                                                exerciseCurrent: 39,
//                                                exerciseGoal: 30,
//                                                standCurrent: 14,
//                                                standGoal: 12
//                                            )
//                                        ))
//                                    }
//            )
//        }
//    }
//}
