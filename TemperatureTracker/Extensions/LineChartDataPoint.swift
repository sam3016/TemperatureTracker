//
//  LineChartDataPoint.swift
//  TemperatureTracker
//
//  Created by Sam Hui on 2023/07/17.
//

import SwiftUI
import Charts

struct LineChartDataPoint: Identifiable {
    let id = UUID()
    let weekday: Date
    let temperature: Double

    init(day: String, temperature: Double) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        self.weekday = formatter.date(from: day) ?? Date.distantPast
        self.temperature = temperature
    }
}
