//
//  ChartAnnotationView.swift
//  Sound Check
//
//  Created by Alex Ryan on 8/7/24.
//

import SwiftUI
import Charts

struct ChartAnnotationView: ChartContent {
    let data: DateValueChartData
    let context: HealthMetricContext
    let style: Color?

    var body: some ChartContent {
        RuleMark(x: .value("Selected Metric", data.date, unit: .day))
            .foregroundStyle(Color.secondary.opacity(0.3))
            .offset(y: -10)
            .annotation(
                position: .top,
                alignment: .center,
                spacing: 0,
                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
    }

        var annotationView: some View {
            VStack(alignment: .leading) {
                Text(data.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                    .font(.footnote.bold())
                    .foregroundStyle(.secondary)

                Text(data.value, format: .number.precision(.fractionLength(context == .soundLevels ? 0 : 1)))
                    .fontWeight(.heavy)
                    .foregroundStyle(style ?? (context == .soundLevels ? .pink : .indigo))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
            )
        }
    }
