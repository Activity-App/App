//
//  FriendRequestCell.swift
//  Project SF
//
//  Created by Christian Privitelli on 29/7/20.
//

import SwiftUI
import CloudKit

struct FriendRequestCell: View {
    let name: String
    let activityRings: ActivityRings?
    let acceptAction: () -> Void
    @State var loading = false
    
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
                        if let activityRings = activityRings {
                            ActivityRingsView(
                                values: .constant(activityRings),
                                ringSize: RingSize(size: 45, width: 5.5, padding: 3)
                            )
                            .frame(width: 50)
                        }
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
                            acceptAction()
                            loading = true
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
                        if loading { ProgressView() }
                    }
                }
            }
        }
    }
}