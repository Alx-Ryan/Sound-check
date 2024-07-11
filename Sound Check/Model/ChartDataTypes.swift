//
//  ChartDataTypes.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/11/24.
//

import Foundation

struct WeedDayChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
