//
//  RingType.swift
//  Project SF
//
//  Created by Christian Privitelli on 12/7/20.
//

import SwiftUI

enum RingType: String {
    
    case move
    case exercise
    case stand
    
    var color: Color { Color(rawValue) }
    var darkColor: Color { Color(rawValue + "Dark") }
    var icon: Image { Image(rawValue + "Icon") }
}
