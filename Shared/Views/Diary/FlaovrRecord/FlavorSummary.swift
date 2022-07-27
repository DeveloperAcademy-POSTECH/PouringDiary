//
//  FlavorSummary.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/27.
//

import SwiftUI

struct FlavorSummary: View {
    var sum: Double
    var count: Int
    var label: LocalizedStringKey
    var minLabel: LocalizedStringKey
    var maxLabel: LocalizedStringKey

    var body: some View {
        VStack(spacing: 0) {
            Text(label)
                .font(.subheadline)
                .padding(.bottom, 4)
            HStack {
                Text(minLabel)
                    .font(.caption2)
                GeometryReader { proxy in
                    ZStack(alignment: sum < 0 ? .trailing : .leading) {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: proxy.size.width, height: 20)
                            .cornerRadius(10)
                        if sum != 0 {
                            HStack(spacing: 0) {
                                if sum > 0 {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: 0.5*proxy.size.width, height: 20)
                                }
                                Rectangle()
                                    .fill(Color.accentColor.opacity(0.7))
                                    .frame(width: proxy.size.width*abs(sum)*0.5/Double(count), height: 20)
                                    .cornerRadius(
                                        radius: 10,
                                        corners: sum > 0 ? [.topRight, .bottomRight] : [.topLeft, .bottomLeft]
                                    )
                                if sum < 0 {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: 0.5*proxy.size.width, height: 20)
                                }
                            }
                        }
                    }
                    .frame(width: proxy.size.width, height: 20)
                }
                Text(maxLabel)
                    .font(.caption2)
            }
            .frame(height: 20)
        }
    }
}

struct FlavorSummary_Previews: PreviewProvider {
    static var previews: some View {
        FlavorSummary(
            sum: -0.5,
            count: 1,
            label: "flavor-record-picker-extraction",
            minLabel: "flavor-record-picker-extraction-under",
            maxLabel: "flavor-record-picker-extraction-over"
        )
    }
}
