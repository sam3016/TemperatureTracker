//
//  TemperatureTrackerTests.swift
//  TemperatureTrackerTests
//
//  Created by Sam Hui on 2023/07/22.
//

import CoreData
import XCTest
@testable import TemperatureTracker

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
