//
//  CompetitionsController.swift
//  Project SF
//
//  Created by Christian Privitelli on 24/7/20.
//

import Foundation

class CompetitionsController: ObservableObject {
    
    var manager = CompetitionsManager()
    
    @Published var state = State.loading
    @Published var competitions: [Competition] = []
    
    /// Create a competition and update on success.
    /// - Parameters:
    ///   - competition: A competition struct to add to CloudKit
    ///   - friends: An array of friends you would like to invite to the competition.
    func create(competition: Competition, with friends: [Friend]) {
        state = .loading
        
        manager.createCompetition(
            type: .init(
                move: competition.move,
                exercise: competition.exercise,
                stand: competition.stand,
                steps: competition.steps,
                distance: competition.distance,
                stepsGoal: competition.stepsGoal,
                distanceGoal: competition.distanceGoal),
            title: competition.title,
            endDate: competition.endDate,
            friends: friends
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.state = .idle
                    self.update()
                case .failure(let error):
                    self.state = .failure(error)
                    self.update()
                }
            }
        }
    }
    
    /// Fetch latest list of competitions from CloudKit and store the result in the `competitions` array.
    func update() {
        state = .loading
        
        manager.fetchCompetitions { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let competitions):
                    self.state = .idle
                    self.competitions = competitions.map { Competition(record: $0) }
                case .failure(let error):
                    self.state = .failure(error)
                }
            }
        }
    }
    
    /// Possible state of the `CompetitionsController` class.
    enum State: Equatable {
        case loading
        case idle
        case failure(Error)
        
        /// Make equatable to detect changes.
        static func == (lhs: CompetitionsController.State, rhs: CompetitionsController.State) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading),
                 (.idle, .idle):
                return true
            case (.loading, .idle),
                 (.loading, .failure),
                 (.failure, .idle),
                 (.idle, .loading),
                 (.idle, .failure),
                 (.failure, .loading):
                return false
            case (.failure(let lhsError), .failure(let rhsError)):
                if lhsError.localizedDescription == rhsError.localizedDescription {
                    return true
                } else {
                    return false
                }
            }
        }
    }
}
