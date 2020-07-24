//
//  CompetitionStruct.swift
//  Project SF
//
//  Created by Christian Privitelli on 24/7/20.
//

import Foundation

class Competition: Identifiable {
    var id: String
    
    var title: String
    
    var move: Bool
    var exercise: Bool
    var stand: Bool
    var steps: Bool
    var distance: Bool
    
    var stepsGoal: Int
    var distanceGoal: Int
    
    var startDate: Date
    var endDate: Date
    
    var creator: CompetingPerson
    var people: [CompetingPerson]
    
    init(
        title: String,
        move: Bool = true,
        exercise: Bool = true,
        stand: Bool = true,
        steps: Bool = false,
        distance: Bool = false,
        stepsGoal: Int = 10000,
        distanceGoal: Int = 10,
        startDate: Date,
        endDate: Date
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.move = move
        self.exercise = exercise
        self.stand = stand
        self.steps = steps
        self.distance = distance
        self.stepsGoal = stepsGoal
        self.distanceGoal = distanceGoal
        self.startDate = startDate
        self.endDate = endDate
        
        self.creator = CompetingPerson(name: "Me", points: 300)
        self.people = [
            CompetingPerson(name: "Person1", points: 100),
            CompetingPerson(name: "Person2", points: 200),
            CompetingPerson(name: "Person3", points: 6000)
        ]
    }
    
    init(record: CompetitionRecord) {
        self.id = record.record.recordID.recordName
        self.title = record.title ?? "Competition \(UUID().uuidString)"
        self.move = record.move ?? true
        self.exercise = record.exercise ?? true
        self.stand = record.stand ?? true
        self.steps = record.steps ?? false
        self.distance = record.distance ?? false
        self.stepsGoal = record.stepsGoal ?? 10000
        self.distanceGoal = record.distanceGoal ?? 10
        self.startDate = record.startDate ?? Date()
        self.endDate = record.endDate ?? Date()
        
        self.creator = CompetingPerson(name: "Me", points: 300)
        self.people = [
            CompetingPerson(name: "Person1", points: 100),
            CompetingPerson(name: "Person2", points: 200),
            CompetingPerson(name: "Person3", points: 6000)
        ]
    }
}
