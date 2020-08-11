//
//  FriendsView.swift
//  Project SF
//
//  Created by Christian Privitelli on 12/7/20.
//

import SwiftUI

struct TemporaryFriend: Identifiable {
    var id = UUID()
    var name: String
    var activity: ActivityRings
}

struct FriendsView: View {
    
    let friends: [TemporaryFriend] = [
        TemporaryFriend(
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
        TemporaryFriend(
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
        TemporaryFriend(
            name: "Friend3",
            activity: .init(
                moveCurrent: 380,
                moveGoal: 400,
                exerciseCurrent: 39,
                exerciseGoal: 30,
                standCurrent: 14,
                standGoal: 12
            )
        ),
        TemporaryFriend(
            name: "Friend3",
            activity: .init(
                moveCurrent: 0,
                moveGoal: 400,
                exerciseCurrent: 0,
                exerciseGoal: 30,
                standCurrent: 0,
                standGoal: 12
            )
        )
    ]
    
    @EnvironmentObject var friendController: FriendController
    @EnvironmentObject var userController: UserController
    @StateObject var discoveryController = UserDiscoveryController()
    @State var showAddFriend = false

    var body: some View {
        NavigationView {
            List {
//                Button("remove all friends") {
//                    FriendManager().removeAllFriends()
//                }
                Section(header: Text("Friend Activity")) {
                    ForEach(friendController.friends) { friend in
                        FriendsCell(friend)
                    }
                }

                Section(header: Text("Pending Invites")) {
                    ForEach(friendController.receivedRequestsFromFriends) { request in
                        FriendRequestCell(name: request.creatorName ?? request.creatorUsername ?? "user", activityRings: nil) {
                            FriendRequestManager().acceptFriendRequest(request.record) { result in
                                switch result {
                                case .success:
                                    friendController.updateAll { _ in }
                                    print("sucessfully added \(request.creatorName ?? "user")")
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Friends")
            .navigationBarItems(
                trailing: NavigationButton(
                    systemName: "plus",
                    action: { showAddFriend = true }
                )
            )
        }
        .tabItem {
            Label("Friends", systemImage: "person.3.fill")
                .font(.title2)
        }
        .onAppear {
            friendController.updateAll { _ in }
        }
        .sheet(isPresented: $showAddFriend) {
            ForEach(discoveryController.discovered) { user in
                FriendDiscoveryView(name: user.name, username: user.username!, action: {
                    FriendRequestManager().invite(user: user.privateUserRecordName!, then: { result in
                        print(result)
                    })
                })
                .padding(.horizontal)
            }
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
