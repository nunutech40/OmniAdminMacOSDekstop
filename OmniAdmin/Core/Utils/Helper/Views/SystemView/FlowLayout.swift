//
//  FlowLayout.swift
//  OmniAdmin
//
//  Created by Nunu Nugraha on 29/12/25.
//

import SwiftUI

// Pastikan ini di luar struct AddProjectView
struct FlowLayout: Layout {
    var spacing: CGFloat

    // Kita buat init eksplisit biar Xcode nggak bingung
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        _ = layout(proposal: proposal, subviews: subviews, bounds: bounds, isPlacing: true)
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews, bounds: CGRect = .zero, isPlacing: Bool = false) -> (size: CGSize, lastHeight: CGFloat) {
        var x = bounds.minX
        var y = bounds.minY
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        let proposalWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > proposalWidth && x > bounds.minX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            if isPlacing {
                subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            }
            x += size.width + spacing
            maxWidth = max(maxWidth, x)
            maxHeight = max(maxHeight, size.height)
        }
        return (CGSize(width: maxWidth, height: y + maxHeight - bounds.minY), y + maxHeight)
    }
}
