//
//  DiaryMemoCard.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/27.
//

import SwiftUI

struct DiaryMemoCard: View {
    @ObservedObject var diary: Diary
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text(diary.created?.monthAndDate ?? "")
                    .font(.caption2)
            }
            Text(diary.memo ?? "")
                .font(.body)
            if !diary.flavorRecordArray.isEmpty {
                VStack(spacing: 12) {
                    FlavorSummary(
                        sum: diary.extractionSum,
                        count: diary.flavorRecordArray.count,
                        label: "flavor-record-picker-extraction",
                        minLabel: "flavor-record-picker-extraction-under",
                        maxLabel: "flavor-record-picker-extraction-over"
                    )
                    FlavorSummary(
                        sum: diary.strengthSum,
                        count: diary.flavorRecordArray.count,
                        label: "flavor-record-picker-strength",
                        minLabel: "flavor-record-picker-strength-under",
                        maxLabel: "flavor-record-picker-strength-over"
                    )
                    Divider()
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(diary.flavorRecordArray, id: \.label) { record in
                                FlavorItem(record: record, selected: false)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}
