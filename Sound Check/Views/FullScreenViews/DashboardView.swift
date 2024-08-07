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

    @State private var isShowingPermissionSheet = false
    @State private var selectedStat: HealthMetricContext = .soundLevels
    @State private var isShowingAlert = false
    @State private var fetchError: SCError = .noData

    var isSound: Bool { selectedStat == .soundLevels }

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

                    switch selectedStat {
                        case .soundLevels:
                            SoundChart(selectedStat: selectedStat, chartData: hkManager.environmentData)
                            DecibelPieChart(chartData: ChartMath.averageWeekdayCount(for: hkManager.environmentData))
                        case .headphones:
                            HeadphoneChart(selectedStat: selectedStat, chartData: hkManager.headphonesData)
                            HeadphoneDiffChart(chartData: ChartMath.averageDailySoundDiffs(for: hkManager.decibelDiffData))
                    }
                }
            }
            .padding()
            .task {
                    // await hkManager.addSimulatorData()
                do {
                    try await hkManager.fetchDecibelCount()
                    try await hkManager.fetchHeadphoneDecibelCount()
                    try await hkManager.fetchHeadphoneDecibelCountDiff()
                } catch SCError.authNotDetermine {
                    isShowingPermissionSheet = true
                } catch SCError.noData {
                    print("❌ No Data Error")
                    fetchError = .noData
                    isShowingAlert = true
                } catch {
                    print("❌ Unable to complete request")
                    fetchError = .unableToCompleteRequest
                    isShowingAlert = true
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionSheet) {
                    // fetch health data
            } content: {
                HealthKitPermissionPrimingView()
            }
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                // action
            } message: { fetchError in
                Text(fetchError.failureReason)
            }

        }
        .tint(isSound ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
