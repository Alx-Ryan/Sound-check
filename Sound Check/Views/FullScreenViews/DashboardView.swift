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
                            SoundChart(chartData: ChartHelper.convert(data: hkManager.environmentData))
                            DecibelPieChart(chartData: ChartHelper.averageWeekdayCount(for: hkManager.environmentData))
                        case .headphones:
                            HeadphoneChart(chartData: ChartHelper.convert(data: hkManager.headphonesData))
                            HeadphoneDiffChart(chartData: ChartHelper.averageDailySoundDiffs(for: hkManager.decibelDiffData))
                    }
                }
            }
            .padding()
            .task { fetchHealthData() }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .fullScreenCover(isPresented: $isShowingPermissionSheet, onDismiss: {
                fetchHealthData()
            }, content: {
                HealthKitPermissionPrimingView()
            })
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                // action
            } message: { fetchError in
                Text(fetchError.failureReason)
            }

        }
        .tint(selectedStat == .soundLevels ? .pink : .indigo)
    }

    private func fetchHealthData() {
        Task {
                // await hkManager.addSimulatorData()
            do {
                async let DecibelCount = hkManager.fetchDecibelCount()
                async let headphoneDecibel = hkManager.fetchHeadphoneDecibelCount(daysBack: 28)
                async let headphoneDiff = hkManager.fetchHeadphoneDecibelCount(daysBack: 29)
                hkManager.environmentData = try await DecibelCount
                hkManager.headphonesData = try await headphoneDecibel
                hkManager.decibelDiffData = try await headphoneDiff
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
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
