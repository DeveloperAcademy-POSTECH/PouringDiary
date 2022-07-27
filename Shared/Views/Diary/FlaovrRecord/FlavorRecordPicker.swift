//
//  FlavorRecordPicker.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/14.
//

import SwiftUI

struct FlavorRecordPicker: View {
    typealias Item = Diary.FlavorRecord

    @Environment(\.presentationMode)
    private var presentationMode

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
                    FlavorSummary(
                        sum: extractionSum,
                        count: selectedRecords.count,
                        label: "flavor-record-picker-extraction",
                        minLabel: "flavor-record-picker-extraction-under",
                        maxLabel: "flavor-record-picker-extraction-over"
                    )
                    FlavorSummary(
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationTitle("flavor-record-picker-title")
        }
    }
}

// MARK: Views
extension FlavorRecordPicker {
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
