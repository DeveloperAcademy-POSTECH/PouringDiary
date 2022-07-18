//
//  FlavorItem.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/15.
//

import SwiftUI

struct FlavorItem: View {
    let record: Diary.FlavorRecord
    let selected: Bool
    var body: some View {
        Text(record.localizedLabel)
            .font(.caption)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(selected ? 0.7 : 1.0))
            .foregroundColor(.white)
            .cornerRadius(3)
    }
}

struct FlavorItem_Previews: PreviewProvider {
    static var previews: some View {
        FlavorItem(record: .presets[0], selected: true)
    }
}
