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
                FlavorRecord(label: "soupy", strength: 0.9, extraction: -0.1),
                FlavorRecord(label: "harsh", strength: 0.9, extraction: 0.1),
                FlavorRecord(label: "overwhelming", strength: 0.7, extraction: 0.3),
                FlavorRecord(label: "severe", strength: 0.6, extraction: 0.4),
                FlavorRecord(label: "intense", strength: 0.4, extraction: 0.6),
                FlavorRecord(label: "dry", strength: 0.3, extraction: 0.7),
                FlavorRecord(label: "bitter", strength: 0.1, extraction: 0.9),
                FlavorRecord(label: "powdery", strength: -0.1, extraction: 0.9),
                FlavorRecord(label: "empty", strength: -0.3, extraction: 0.7),
                FlavorRecord(label: "dusty", strength: -0.4, extraction: 0.6),
                FlavorRecord(label: "astringent", strength: -0.5, extraction: 0.5),
                FlavorRecord(label: "dilute", strength: -0.6, extraction: 0.4),
                FlavorRecord(label: "limp", strength: -0.7, extraction: 0.3),
                FlavorRecord(label: "fragile", strength: -0.8, extraction: 0.2),
                FlavorRecord(label: "muted", strength: -0.85, extraction: 0.15),
                FlavorRecord(label: "faint", strength: -0.9, extraction: -0.1),
                FlavorRecord(label: "sparse", strength: -0.8, extraction: -0.2),
                FlavorRecord(label: "flimsy", strength: -0.6, extraction: -0.4),
                FlavorRecord(label: "watery", strength: -0.45, extraction: -0.55),
                FlavorRecord(label: "underwhelming", strength: -0.4, extraction: -0.6),
                FlavorRecord(label: "bland", strength: -0.35, extraction: -0.65),
                FlavorRecord(label: "nutty", strength: -0.3, extraction: -0.7),
                FlavorRecord(label: "sour", strength: -0.1, extraction: -0.9),
                FlavorRecord(label: "salty", strength: 0.15, extraction: -0.85),
                FlavorRecord(label: "quick finish", strength: 0.25, extraction: -0.75),
                FlavorRecord(label: "dull", strength: 0.4, extraction: -0.6),
                FlavorRecord(label: "beefy", strength: 0.55, extraction: -0.45),
                FlavorRecord(label: "bulky", strength: 0.7, extraction: -0.3)
            ]
        }
    }
}

extension Diary.FlavorRecord {
    var localizedLabel: LocalizedStringKey {
        return LocalizedStringKey(label)
    }
}
