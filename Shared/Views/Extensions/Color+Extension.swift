//
//  Color+Extension.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/28.
//

import SwiftUI

extension Color {
    init(hex: UInt32) {
        assert(hex >= 0x000000, "Out of hex range")
        assert(hex <= 0xffffff, "Out of hex range")
        let redComponent = (hex & 0xff0000) >> 16
        let greenComponent = (hex & 0x00ff00) >> 8
        let blueComponent = hex & 0x0000ff

        self = Color(
            red: Double(redComponent) / 256,
            green: Double(greenComponent) / 256,
            blue: Double(blueComponent) / 256
        )
    }
}
