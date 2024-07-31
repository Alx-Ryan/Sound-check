//
//  HeadphoneChart.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/31/24.
//

import SwiftUI
import Charts

struct HeadphoneChart: View {

    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]

    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }

    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Headphone dB", systemImage: "ear.badge.waveform")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)

                        Text("Avg: Decibels")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)

            Chart {
                RuleMark(y: .value("Goal", 55))
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                
                ForEach(chartData) { headphonedB in
                    LineMark(
                        x: .value("Day", headphonedB.date, unit: .day),
                        y: .value("Value", headphonedB.value)
                    )
                    .foregroundStyle(.indigo.gradient)
                    .interpolationMethod(.cardinal)
                    .symbol(.circle)
                    .symbolSize(50)

                    AreaMark(
                        x: .value("Day", headphonedB.date, unit: .day),
                        yStart: .value("Value", headphonedB.value),
                        yEnd: .value("Min Value", minValue - 15)
                    )
                    .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                    .interpolationMethod(.cardinal)
                }
            }
            .frame(height: 150)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis{
                AxisMarks{
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis{
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))

                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    HeadphoneChart(selectedStat: .headphones, chartData: MockData.HeadphonedB)
}
