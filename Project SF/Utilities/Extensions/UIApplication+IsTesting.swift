//
//  UIApplication+IsTesting.swift
//  Project SF
//
//  Created by William Taylor on 11/7/20.
//

import Foundation
import UIKit

extension ProcessInfo {
    
    var isTesting: Bool {
        #if DEBUG
        return environment["XCTestConfigurationFilePath"] != nil
        #else
        return false
        #endif
    }
    
}
