//
//  UserDefaults+UIColor.swift
//  Project SF
//
//  Created by Roman Esin on 18.07.2020.
//

import UIKit

extension UserDefaults {
    func set(_ value: UIColor?, forKey key: String) {
        var colorData: Data?
        if let color = value {
            do {
                colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            } catch {
                print(error)
            }
        }
        set(colorData, forKey: key)
    }

    func uiColor(forKey key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            do {
                color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
            } catch {
                print(error)
            }
        }
        return color
    }
}
