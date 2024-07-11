//
//  DecibelPieChart.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/11/24.
//

import SwiftUI
import Charts

struct DecibelPieChart: View {

    var chartData: [WeedDayChartData]

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Sound Averages", systemImage: "chart.dots.scatter")
                    .font(.title3.bold())
                    .foregroundStyle(.pink)

                Text("Last 28 Days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)

            Chart {
                ForEach(chartData) { weekday in
                    SectorMark(
                        angle: .value("Average Decibels", weekday.value),
                        innerRadius: .ratio(0.618),
                        angularInset: 2
                    )
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(8)
                }
            }
            .frame(height: 240)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    DecibelPieChart(chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
        .padding()
}
