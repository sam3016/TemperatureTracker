//
//  MeasurementRow.swift
//  TemperatureTracker
//
//  Created by Sam Hui on 2023/07/15.
//

import SwiftUI

struct MeasurementRow: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var monitoring: Monitoring

    var body: some View {
        NavigationLink(value: monitoring) {
            HStack {
                Image(systemName: "medical.thermometer")
                    .imageScale(.large)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(monitoring.measurementDate.formatted(date: .abbreviated, time: .shortened))
                    Text("\(monitoring.measurementTemperature, specifier: "%.1f")ºC")
                        .foregroundColor(monitoring.measurementTemperature > 37.2 ? .red : .secondary)
                }
            }
        }
    }
}

struct MeasurementRow_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementRow(monitoring: .example)
    }
}
