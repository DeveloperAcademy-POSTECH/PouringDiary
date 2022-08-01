//
//  Diary+FlavorRecord.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/13.
//

import Foundation
import SwiftUI

extension Diary {
    struct FlavorRecord: Codable, Equatable {
        let label: String       // 향미의 종류
        let strength: Double    // 농도 (1: 강함 0: 균형 -1: 약함)
        let extraction: Double  // 추출 정도 (1: 과다추출 0: 균형 -1: 과소추출)

        static var presets: [FlavorRecord] {
            return [
                FlavorRecord(label: "flavor-record-harsh", strength: 0.9, extraction: 0.1),
                FlavorRecord(label: "flavor-record-overwhelming", strength: 0.7, extraction: 0.3),
                FlavorRecord(label: "flavor-record-intense", strength: 0.5, extraction: 0.5),
                FlavorRecord(label: "flavor-record-dry", strength: 0.3, extraction: 0.7),
                FlavorRecord(label: "flavor-record-bitter", strength: 0.1, extraction: 0.9),
                FlavorRecord(label: "flavor-record-powdary", strength: -0.1, extraction: 0.9),
                FlavorRecord(label: "flavor-record-empty", strength: -0.3, extraction: 0.7),
                FlavorRecord(label: "flavor-record-astringent", strength: -0.5, extraction: 0.5),
                FlavorRecord(label: "flavor-record-limp", strength: -0.7, extraction: 0.3),
                FlavorRecord(label: "flavor-record-faint", strength: -0.9, extraction: -0.1),
                FlavorRecord(label: "flavor-record-sparse", strength: -0.7, extraction: -0.3),
                FlavorRecord(label: "flavor-record-watery", strength: -0.5, extraction: -0.5),
                FlavorRecord(label: "flavor-record-bland", strength: -0.3, extraction: -0.7),
                FlavorRecord(label: "flavor-record-sour", strength: -0.1, extraction: -0.9),
                FlavorRecord(label: "flavor-record-salty", strength: 0.1, extraction: -0.9),
                FlavorRecord(label: "flavor-record-quickfinish", strength: 0.3, extraction: -0.7),
                FlavorRecord(label: "flavor-record-dull", strength: 0.5, extraction: -0.5),
                FlavorRecord(label: "flavor-record-soupy", strength: 0.9, extraction: -0.1)
            ]
        }
    }
}

extension Diary.FlavorRecord {
    var localizedLabel: LocalizedStringKey {
        return LocalizedStringKey(label)
    }
}
