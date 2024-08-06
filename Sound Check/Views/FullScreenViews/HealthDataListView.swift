    //
    //  HealthDataListView.swift
    //  Sound Check
    //
    //  Created by Alex Ryan on 7/6/24.
    //

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitManager.self) private var hkManager

    @State private var isShowingAddData = false
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""

    var metric: HealthMetricContext

    var listData: [HealthMetric] {
        metric == .soundLevels ? hkManager.environmentData : hkManager.headphonesData
    }

    var body: some View {
        List(listData.reversed()) { data in
            HStack {
                Text(data.date, format: .dateTime.month().day().year(.twoDigits))
                Spacer()
                Text(data.value, format: .number.precision(.fractionLength(metric == .soundLevels ? 0 : 1)))
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar {
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }

    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                HStack {
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(metric == .soundLevels ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        Task {
                            if metric == .soundLevels {
                                do {
                                    try await hkManager.addSoundData(for: addDataDate, value: Double(valueToAdd)!) //Fix Force unwrap later
                                    try await hkManager.fetchDecibelCount()
                                    isShowingAddData = false
                                } catch SCError.sharingDenied(let quantityType) {
                                    print("❌ Sharing denied for \(quantityType)")
                                } catch {
                                    print("❌ Data list view unable to complete request")
                                }
                            } else {
                                do {
                                    try await hkManager.addHeadphoneData(for: addDataDate, value: Double(valueToAdd)!) //Fix Force unwrap later
                                    try await hkManager.fetchHeadphoneDecibelCount()
                                    isShowingAddData = false
                                } catch SCError.sharingDenied(let quantityType) {
                                    print("❌ Sharing denied for \(quantityType)")
                                } catch {
                                    print("❌ Data list view unable to complete request")
                                }
                            }
                        }
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isShowingAddData = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthDataListView(metric: .soundLevels)
            .environment(HealthKitManager())
    }
}
