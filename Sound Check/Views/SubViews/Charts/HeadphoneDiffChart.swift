    //
    //  HeadphoneDiffChart.swift
    //  Sound Check
    //
    //  Created by Alex Ryan on 8/5/24.
    //

import SwiftUI
import Charts

struct HeadphoneDiffChart: View {
    @State private var rawSelectedDate: Date?

    var chartData: [WeekDayChartData]
    var selectedData: WeekDayChartData? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Label("Average Decibel Change", systemImage: "ear.badge.waveform")
                        .font(.title3.bold())
                        .foregroundStyle(.indigo)

                    Text("Per WeekDay (Last 28 Days)")
                        .font(.caption)
                }
                Spacer()
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)

            Chart {
                if let selectedData {
                    RuleMark(x: .value("Selected Data", selectedData.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
                }
                ForEach(chartData) { DecibelDiff in
                    BarMark(
                        x: .value("Day", DecibelDiff.date, unit: .day),
                        y: .value("Decibel Diff", DecibelDiff.value)
                    )
                    .foregroundStyle(DecibelDiff.value <= 0 ? Color.indigo.gradient : Color.purple.gradient)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated).day(), centered: true)
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

    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedData?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)

            Text(selectedData?.value ?? 0, format: .number.precision(.fractionLength(2)))
                .fontWeight(.heavy)
                .foregroundStyle((selectedData?.value ?? 0) <= 0 ? .indigo : .purple)
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
    HeadphoneDiffChart(chartData: MockData.decibelDiffs)
}
