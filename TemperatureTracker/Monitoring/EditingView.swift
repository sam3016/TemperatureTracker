//
//  EditingView.swift
//  TemperatureTracker
//
//  Created by Sam Hui on 2023/07/09.
//

import SwiftUI

struct EditingView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var monitoring: Monitoring

    var body: some View {
        Form {
            Section(header: Text("Date")) {
                Text(monitoring.measurementDate.formatted(date: .numeric, time: .omitted))
            }

            Section(header: Text("Temperature")) {
                Slider(value: $monitoring.measurementTemperature, in: 35.1...41.0)
                Text("Your temperature is \(monitoring.measurementTemperature, specifier: "%.1f")ºC")
                    .foregroundColor(monitoring.measurementTemperature > 37.2 ? .red : .primary)
            }
        }
        .onReceive(monitoring.objectWillChange) { _ in
            dataController.queueSave()
        }
    }
}

struct EditingView_Previews: PreviewProvider {
    static var previews: some View {
        EditingView(monitoring: .example)
    }
}
