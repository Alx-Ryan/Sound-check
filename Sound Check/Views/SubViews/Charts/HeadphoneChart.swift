//
//  HeadphoneChart.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/31/24.
//

import SwiftUI
import Charts

struct HeadphoneChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?

    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }

    var body: some View {
        ChartContainer(
            title: "Headphone dB",
            symbol: "ear.badge.waveform",
            subTitle: "Avg: Decibels",
            context: selectedStat,
            isNav: true) {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.xyaxis.line", title: "No Data", description: "There is no sound data from the Health App")
            } else {
                Chart {
                    if let selectedHealthMetric {
                        RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(
                                position: .top,
                                alignment: .center,
                                spacing: 0,
                                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                    annotationView
                                }
                    }
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
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
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
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }

    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)

            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    HeadphoneChart(selectedStat: .headphones, chartData: MockData.HeadphonedB)
}
