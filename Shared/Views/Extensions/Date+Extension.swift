//
//  Date+Extension.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/13.
//

import Foundation

extension Date {
    var monthAndDate: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM / dd"
        return formatter.string(from: self)
    }

    var simpleYear: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }

    var simpleTime: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "hh:mm"
        return formatter.string(from: self)
    }
}
