//
//  ExtensionTests.swift
//  TemperatureTrackerTests
//
//  Created by Sam Hui on 2023/08/08.
//

import CoreData
import XCTest
@testable import TemperatureTracker

final class ExtensionTests: BaseTestCase {
    func testMonitoringIDUnwrap() {
        let monitor = Monitoring(context: managedObjectContext)

        monitor.id = UUID()
        XCTAssertEqual(monitor.measurementID, monitor.id, "Changing id should also change measurementID.")
    }

    func testMonitoringCreationDateUnwrap() {
        // Given
        let monitoring = Monitoring(context: managedObjectContext)
        let testDate = Date.now

        // When
        monitoring.creationDate = testDate

        // Then
        XCTAssertEqual(
            monitoring.measurementCreationDate,
            testDate,
            "Changing creationDate should also change measurementCreationDate."
        )
    }

    func testMonitoringMeasurementDateUnwrap() {
        let monitoring = Monitoring(context: managedObjectContext)
        let testDate = Date.now

        monitoring.date = testDate
        XCTAssertEqual(monitoring.measurementDate, testDate, "Changing date should also change measurementDate.")

        monitoring.measurementDate = testDate.addingTimeInterval(100)
        XCTAssertEqual(
            monitoring.date,
            testDate.addingTimeInterval(100),
            "Changing measurementDate should also change date."
        )
    }

    func testMonitoringTemperatureUnwrap() {
        let monitoring = Monitoring(context: managedObjectContext)

        monitoring.temperature = 36.0
        XCTAssertEqual(
            monitoring.measurementTemperature,
            36.0,
            "Changing temperature should also change measureTemperature."
        )

        monitoring.measurementTemperature = 36.5
        XCTAssertEqual(monitoring.temperature, 36.5, "Changing measurementTemperature should also change temperature.")
    }

    func testMonitoringSortingIsStable() {
        let testDate = Date.now

        let monitoring1 = Monitoring(context: managedObjectContext)
        monitoring1.creationDate = testDate
        monitoring1.date = testDate

        let monitoring2 = Monitoring(context: managedObjectContext)
        monitoring2.creationDate = testDate
        monitoring2.date = testDate.addingTimeInterval(100)

        let monitoring3 = Monitoring(context: managedObjectContext)
        monitoring3.creationDate = testDate.addingTimeInterval(-100)
        monitoring3.date = testDate

        let allMonitoring = [monitoring1, monitoring2, monitoring3]
        let sorted = allMonitoring.sorted()

        XCTAssertEqual(
            [monitoring3, monitoring1, monitoring2],
            sorted,
            "Sorting monitoring arrays should use creationDate then date."
        )
    }
}
