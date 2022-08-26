//
//  Sequence+Extensions.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/08/12.
//

import Foundation

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
