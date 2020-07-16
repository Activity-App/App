//
//  Pixel.swift
//  Project SF
//
//  Created by Roman Esin on 16.07.2020.
//

import Foundation

// swiftlint:disable identifier_name
struct Pixel {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

class PixelImage {
    var width: Int
    var height: Int
    var pixels: [Pixel]

    static func random(width: Int, height: Int) -> PixelImage {
        var pixels: [Pixel] = []
        for _ in 0..<(width * height) {
            pixels.append(Pixel(a: 255,
                                r: .random(in: 0...255),
                                g: .random(in: 0...255),
                                b: .random(in: 0...255)))
        }
        return PixelImage(width: width, height: height, pixels: pixels)
    }

    /// Returns random symmetrixal `PixelImage` with given size.
    /// - Parameters:
    ///   - width: Width of the image.
    ///   - height: Height of the image.
    /// - Returns: Random symmetrixal `PixelImage` with given size.
    static func randomSymmetrical(width: Int, height: Int) -> PixelImage {
        var pixels: [Pixel] = []
        let clear = Pixel(a: 255,
                          r: 240,
                          g: 240,
                          b: 240)

        let color = Pixel(a: 255,
                          r: .random(in: 0...255),
                          g: .random(in: 0...255),
                          b: .random(in: 0...255))

        var slice: [Pixel] = []
        let num = width % 2
        for _ in 0..<height {
            loop: for j in 0..<width {
                if j - num == width / 2 {
                    pixels.append(contentsOf: slice[..<(slice.count - num)].reversed())
                    slice = []
                    break loop
                } else {
                    let color = Bool.random() ? clear : color
                    pixels.append(color)
                    slice.append(color)
                }
            }
        }
        return PixelImage(width: width, height: height, pixels: pixels)
    }

    init(width: Int, height: Int, pixels: [Pixel]) {
        self.width = width
        self.height = height
        self.pixels = pixels
    }
}
