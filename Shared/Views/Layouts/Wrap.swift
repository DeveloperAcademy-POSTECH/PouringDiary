//
//  Wrap.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/10/27.
//

import SwiftUI

struct Wrap: Layout {
    let spacing: CGFloat
    let runSpacing: CGFloat

    init(spacing: CGFloat = 4, runSpacing: CGFloat = 8) {
        self.spacing = spacing
        self.runSpacing = runSpacing
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let proposalWidth: CGFloat = proposal.width ?? .infinity

        var rowCount = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var height: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)

            if rowWidth > proposalWidth {
                height += rowHeight + runSpacing
                rowCount += 1
                rowWidth = 0
                rowHeight = 0
            } else if subview == subviews.last {
                height += rowHeight
            }
        }

        return CGSize(
            width: proposalWidth,
            height: height
        )
    }
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let proposalWidth: CGFloat = proposal.width ?? .infinity

        let placementProposal = ProposedViewSize(
            width: proposalWidth,
            height: 50)

        var posX: CGFloat = 0
        var posY: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let width = size.width
            if posX + width > proposalWidth {
                posX = 0
                posY += size.height + runSpacing
            }
            subview.place(
                at: CGPoint(
                    x: bounds.minX + posX,
                    y: bounds.minY + posY),
                proposal: placementProposal
            )
            posX += spacing + width
        }
    }
}
