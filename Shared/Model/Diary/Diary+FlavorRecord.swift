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
                FlavorRecord(label: "강한", strength: 0.9, extraction: 0.1),
                FlavorRecord(label: "쓴맛", strength: 0.6, extraction: 0.3),
                FlavorRecord(label: "텁텁한", strength: 0.4, extraction: 0.6),
                FlavorRecord(label: "드라이한", strength: 0.2, extraction: 0.8),
                FlavorRecord(label: "우디한", strength: -0.2, extraction: 0.8),
                FlavorRecord(label: "떫은", strength: -0.5, extraction: 0.5),
                FlavorRecord(label: "물맛이 나는", strength: -0.8, extraction: 0.2),
                FlavorRecord(label: "약한", strength: -1, extraction: 0),
                FlavorRecord(label: "묽은", strength: -0.8, extraction: -0.2),
                FlavorRecord(label: "밋밋한", strength: -0.5, extraction: -0.5),
                FlavorRecord(label: "너티한", strength: -0.3, extraction: -0.7),
                FlavorRecord(label: "신맛", strength: -0.1, extraction: -0.9),
                FlavorRecord(label: "날카로운", strength: 0.3, extraction: -0.7),
                FlavorRecord(label: "짠맛", strength: 0.6, extraction: -0.4),
                FlavorRecord(label: "자극적인", strength: 9, extraction: -0.1)
            ]
        }
    }
}

extension Diary.FlavorRecord {
    var localizedLabel: LocalizedStringKey {
        return LocalizedStringKey(label)
    }
}
