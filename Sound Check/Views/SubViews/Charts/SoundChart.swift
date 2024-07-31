//
//  SoundChart.swift
//  Sound Check
//
//  Created by Alex Ryan on 7/11/24.
//

import SwiftUI
import Charts

struct SoundChart: View {
    @State private var rawSelectedDate: Date?

    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    var avgDecibel: Double {
        guard !chartData.isEmpty else { return 0 }
        let totalDecibels = chartData.reduce(0) { $0 + $1.value }
        return totalDecibels / Double(chartData.count)
    }
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }

    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Sound Levels", systemImage: "waveform")
                            .font(.title3.bold())
                            .foregroundStyle(.pink)

                        Text("Avg: \(Double(avgDecibel), format: .number.precision(.fractionLength(0))) Decibels")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)

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

                RuleMark(y: .value("Average", avgDecibel))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))

                ForEach(chartData) { decibel in
                    PointMark(
                        x: .value("Date", decibel.date, unit: .day),
                        y: .value("Decibels", decibel.value)
                    )
                    .opacity(rawSelectedDate == nil || decibel.date == selectedHealthMetric?.date ? 1.0 : 0.3)
                    LineMark(
                        x: .value("Date", decibel.date, unit: .day),
                        y: .value("Decibels", decibel.value)
                    )
                    .opacity(0.3)
                }
                .foregroundStyle(Color.pink.gradient)
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))

            .chartXAxis{
                AxisMarks{
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis{
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))

                    AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)

            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .fontWeight(.heavy)
                .foregroundStyle(.pink)
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
    SoundChart(selectedStat: .soundLevels, chartData: MockData.EnvironmentdB)
        .padding()
}
