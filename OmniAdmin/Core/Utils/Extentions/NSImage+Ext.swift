//
//  NSImage+Ext.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 29/12/25.
//

import AppKit

extension NSImage {
    func resizedTo(maxSize: CGFloat) -> Data? {
        let ratio = size.width / size.height
        let newSize = size.width > size.height ?
            NSSize(width: maxSize, height: maxSize / ratio) :
            NSSize(width: maxSize * ratio, height: maxSize)
        
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: self.size), operation: .copy, fraction: 1.0)
        newImage.unlockFocus()
        
        guard let tiff = newImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff) else { return nil }
        
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
    }
}
