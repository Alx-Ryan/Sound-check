    //
    //  DashboardView.swift
    //  Sound Check
    //
    //  Created by Alex Ryan on 7/5/24.
    //

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
    case soundLevels, headphones
    var id: Self { self }
    
    var title: String {
        switch self {
            case .soundLevels:
                return "Sound Levels"
            case .headphones:
                return "Headphones"
        }
    }
}

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    
    @State private var isShowingPermissionSheet = false
    @State private var selectedStat: HealthMetricContext = .soundLevels
    
    var isSteps: Bool { selectedStat == .soundLevels }
    var avgDecibel: Double {
        guard !hkManager.environmentData.isEmpty else { return 0 }
        let totalDecibels = hkManager.environmentData.reduce(0) { $0 + $1.value }
        return totalDecibels / Double(hkManager.environmentData.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    VStack {
                        NavigationLink(value: selectedStat) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Label("Sound Levels", systemImage: "waveform")
                                        .font(.title3.bold())
                                        .foregroundStyle(.pink)
                                    
                                    Text("Avg: \(Double(avgDecibel)) Decibels")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)
                        
                        Chart {
                            RuleMark(y: .value("Average", avgDecibel))
                                .foregroundStyle(Color.secondary)
                                .lineStyle(.init(lineWidth: 1, dash: [5]))

                            ForEach(/*hkManager.environmentData*/HealthMetric.mockData) { decibel in
                                PointMark(
                                    x: .value("Date", decibel.date, unit: .day),
                                    y: .value("Decibels", decibel.value)
                                )
                                .foregroundStyle(Color.pink.gradient)
                                LineMark(
                                    x: .value("Date", decibel.date, unit: .day),
                                    y: .value("Decibels", decibel.value)
                                )
                            }
                        }
                        .frame(height: 150)
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
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 240)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
            }
            .padding()
            .task {
                    await hkManager.fetchDecibelCount()
                    //await hkManager.fetchHeadphoneDecibelCount()
                isShowingPermissionSheet = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionSheet) {
                    // fetch health data
            } content: {
                HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
            }
        }
        .tint(isSteps ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
