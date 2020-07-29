//
//  FriendRequestCell.swift
//  Project SF
//
//  Created by Christian Privitelli on 29/7/20.
//

import SwiftUI
import CloudKit

struct FriendRequestCell: View {
    var name: String
    var acceptAction: () -> Void
    
    var body: some View {
        GroupBox {
            HStack(alignment: .bottom) {
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "person.fill")
                            .resizable()
                            .padding(10)
                            .frame(width: 50)
                            .background(Color(.systemTeal))
                            .clipShape(Circle())
                        ActivityRingsView(
                            values: .constant(
                                ActivityRings(
                                    moveCurrent: 10,
                                    moveGoal: 300,
                                    exerciseCurrent: 40,
                                    exerciseGoal: 30,
                                    standCurrent: 9,
                                    standGoal: 12)
                            ),
                            ringSize: RingSize(size: 45, width: 5.5, padding: 3)
                        )
                        .frame(width: 50)
                    }
                    .frame(height: 50)
                    Text("\(name) would like to be friends.")
                        .padding(.bottom, 8)
                    HStack {
                        Button("Ignore") {
                            
                        }
                        .foregroundColor(.orange)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(.orange)
                                .opacity(0.25)
                        )
                        Button("Accept") {
                            
                        }
                        .foregroundColor(.green)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(.green)
                                .opacity(0.25)
                        )
                        Spacer()
                    }
                }
            }
        }
    }
}
