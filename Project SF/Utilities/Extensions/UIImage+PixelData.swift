//
//  UIImage+PixelData.swift
//  Project SF
//
//  Created by Roman Esin on 16.07.2020.
//

import UIKit

extension UIImage {
    convenience init?(pixelImage: PixelImage) {
        let width = pixelImage.width
        let height = pixelImage.height
        let pixels = pixelImage.pixels

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
                shouldInterpolate: false,
                intent: .defaultIntent)
        else { return nil }
        self.init(cgImage: cgim)
    }
}
