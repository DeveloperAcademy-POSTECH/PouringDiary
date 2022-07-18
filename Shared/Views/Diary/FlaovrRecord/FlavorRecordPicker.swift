//
//  FlavorRecordPicker.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/14.
//

import SwiftUI

struct FlavorRecordPicker: View {
    typealias Item = Diary.FlavorRecord

    @Binding var selectedRecords: [Item]

    private var filtered: [Item] {
        return Item.presets
            .filter { !selectedRecords.contains($0) }
    }

    private var extractionSum: Double {
        return selectedRecords
            .map { $0.extraction }
            .reduce(0) { $0 + $1 }
    }

    private var strengthSum: Double {
        return selectedRecords
            .map { $0.strength }
            .reduce(0) { $0 + $1 }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("flavor-record-picker-information")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedRecords, id: \.label) { record in
                            recordItem(record: record)
                        }
                    }
                    .padding()
                }
                VStack(spacing: 12) {
                    flavorInformation(
                        sum: extractionSum,
                        count: selectedRecords.count,
                        label: "flavor-record-picker-extraction",
                        minLabel: "flavor-record-picker-extraction-under",
                        maxLabel: "flavor-record-picker-extraction-over"
                    )
                    flavorInformation(
                        sum: strengthSum,
                        count: selectedRecords.count,
                        label: "flavor-record-picker-strength",
                        minLabel: "flavor-record-picker-strength-under",
                        maxLabel: "flavor-record-picker-strength-over"
                    )
                    Spacer()
                }
                .padding()
                Spacer()
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(filtered, id: \.label) { record in
                        recordItem(record: record)
                    }
                }
                .padding(.bottom, 16)
            }
            .navigationTitle("flavor-record-picker-title")
        }
    }
}

// MARK: Views
extension FlavorRecordPicker {
    @ViewBuilder
    private func flavorInformation(
        sum: Double,
        count: Int,
        label: LocalizedStringKey,
        minLabel: LocalizedStringKey,
        maxLabel: LocalizedStringKey
    ) -> some View {
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
    @ViewBuilder
    private func recordItem(record: Item) -> some View {
        let selected = selectedRecords.contains(record)
        FlavorItem(record: record, selected: selected)
            .onTapGesture {
                withAnimation {
                    if selected {
                        selectedRecords = selectedRecords.filter { $0 != record }
                    } else {
                        if selectedRecords.count < 5 {
                            selectedRecords.append(record)
                        }
                    }
                }
            }
    }
}

struct FlavorRecordPicker_Previews: PreviewProvider {
    static var previews: some View {
        FlavorRecordPicker(selectedRecords: .constant([
            Diary.FlavorRecord.presets[4],
            Diary.FlavorRecord.presets[2],
            Diary.FlavorRecord.presets[1]
        ]))
        .environment(\.locale, .init(identifier: "ko"))
    }
}
