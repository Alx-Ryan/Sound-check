//
//  DateEXT.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/11/24.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }

    var weekdayTitle: String {
        self.formatted(.dateTime.weekday(.wide))
    }
}
