//
//  DecibelPieChart.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/11/24.
//

import SwiftUI
import Charts

struct DecibelPieChart: View {

    @State private var rawSelectedChartValue: Double? = 0

    var chartData: [WeekDayChartData]
    var selectedWeekday: WeekDayChartData? {
        guard let rawSelectedChartValue else { return nil }
        var total = 0.0

        return chartData.first {
            total += $0.value
            return rawSelectedChartValue <= total
        }
    }

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
                        outerRadius: selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140 : 110,
                        angularInset: 2
                    )
                    .foregroundStyle(.pink.gradient)
                    .cornerRadius(8)
                    .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1.0 : 0.3)
                }
            }
            .chartAngleSelection(value: $rawSelectedChartValue.animation(.easeInOut))
            .frame(height: 240)
            .chartBackground { proxy in
                GeometryReader { geo in
                    if let plotFrame = proxy.plotFrame {
                        let frame = geo[plotFrame]
                        if let selectedWeekday {
                            VStack {
                                Text(selectedWeekday.date.weekdayTitle)
                                    .font(.title3.bold())
                                    .contentTransition(.identity)

                                Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    DecibelPieChart(chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
        .padding()
}
