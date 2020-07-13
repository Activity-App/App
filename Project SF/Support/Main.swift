//
//  Main.swift
//  Project SF
//
//  Created by William Taylor on 11/7/20.
//

import Foundation

@main
struct Main {
    
    static func main() {
        if !ProcessInfo.processInfo.isTesting {
            ProjectSFApp.main()
        } else {
            TestApp.main()
        }
    }
    
}
