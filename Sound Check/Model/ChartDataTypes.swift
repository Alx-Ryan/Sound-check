//
//  ChartDataTypes.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/11/24.
//

import Foundation

struct DateValueChartData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
