//
//  ImageStore.swift
//  Project SF
//
//  Created by Roman Esin on 18.07.2020.
//

import UIKit

// TODO: Finish this thing...
@propertyWrapper
struct ImageStore {
    var key: String
    var storage = UserDefaults.standard

    var wrappedValue: UIImage? {
        get {
            guard let data = storage.value(forKey: key) as? Data else { return nil }
            return UIImage(data: data)
        }
        set { storage.setValue(newValue?.pngData(), forKey: key) }
    }

    init(_ key: String, wrappedValue: UIImage) {
        self.key = key
        self.wrappedValue = wrappedValue
    }
}
