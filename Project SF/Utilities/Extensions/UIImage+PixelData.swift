//
//  UIImage+PixelData.swift
//  Project SF
//
//  Created by Roman Esin on 16.07.2020.
//

import UIKit

// swiftlint:disable identifier_name
struct Pixel {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

extension Array where Element == Pixel {
    static func random(width: Int, height: Int) -> [Pixel] {
        var pixels: [Pixel] = []
        for _ in 0..<(width * height) {
            pixels.append(Pixel(a: 255,
                                r: .random(in: 0...255), 
                                g: .random(in: 0...255),
                                b: .random(in: 0...255)))
        }
        return pixels
    }

    static func randomSymmetrical(width: Int, height: Int) -> [Pixel] {
        // Yes, this makes sence.
        let width = 2 * width / 2
        let height = 2 * height / 2

        var pixels: [Pixel] = []
        let clear = Pixel(a: 0, r: 0, g: 0, b: 0)
        let color = Pixel(a: 255,
                          r: .random(in: 0...255),
                          g: .random(in: 0...255),
                          b: .random(in: 0...255))

        var slice: [Pixel] = []
        for _ in 0..<height {
            loop: for j in 0..<width {
                if j == width / 2 {
                    pixels.append(contentsOf: slice.reversed())
                    slice = []
                    break loop
                } else {
                    let color = Bool.random() ? clear : color
                    pixels.append(color)
                    slice.append(color)
                }
            }
        }
        return pixels
    }
}

extension UIImage {
    convenience init?(pixels: [Pixel], width: Int, height: Int) {
        guard width > 0 && height > 0, pixels.count == width * height else { return nil }
        var data = pixels
        guard let providerRef = CGDataProvider(data: Data(bytes: &data,
                                                          count: data.count * MemoryLayout<Pixel>.size) as CFData)
        else { return nil }
        guard let cgim = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * MemoryLayout<Pixel>.size,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
                provider: providerRef,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent)
        else { return nil }
        self.init(cgImage: cgim)
    }
}
