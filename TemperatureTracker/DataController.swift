//
//  DataController.swift
//  TemperatureTracker
//
//  Created by Sam Hui on 2023/07/05.
//

import CoreData

class DataController: ObservableObject {
    /// The lone CloudKit container used to store all our data
    let container: NSPersistentCloudKitContainer

    @Published var selectedMeasurement: Monitoring?

    private var saveTask: Task<Void, Error>?

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    /// Initializes a data controller, either in memory(for testing use such as previewing),
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: Self.model)

        // For Testing and previewing purposes, we create a
        // temporary, in-memory database by writing to /dev/null
        // so our data is destroyed after the app finished running
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // Make sure we watch iCloud for all changes to make
        // absolutely sure we keep our local UI in sync when a
        // remote changes happens.
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )

        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )

        let groupID = "group.com.samhui.temperaturetracker"

        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
            container.persistentStoreDescriptions.first?.url =
            url.appending(path: "Model.sqlite")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }

    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    func createSampleData() {
        let viewContext = container.viewContext

        for measureCount in 1...5 {
            let measurement = Monitoring(context: viewContext)
            measurement.creationDate = .now
            measurement.temperature = Double(measureCount) + 35.0
        }

        try? viewContext.save()
    }

    /// Save our Core Data context if there are change. This silently ignores
    /// any errors caused by saving, but this should be fine because
    /// all our attributes are optional.
    func save() {
        saveTask?.cancel()

        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    func queueSave() {
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }

    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        // ⚠️When performing a batch delete we need to make sure we read the result back
        // then merge all the changes from that result back into our live view context
        // so that the two stay in sunc.
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func deleteAll() {
        let request: NSFetchRequest<NSFetchRequestResult> = Monitoring.fetchRequest()
        delete(request)

        save()
    }

    func newMeasurement(selectedDate: Date) {
        let measurement = Monitoring(context: container.viewContext)
        measurement.id = UUID()
        measurement.creationDate = .now
        let calendar = Calendar.current
        _ = calendar.component(.hour, from: selectedDate)
        _ = calendar.component(.minute, from: selectedDate)
        measurement.date = selectedDate
        measurement.temperature = 35.1

        save()

        selectedMeasurement = measurement
    }

    func measurementByDate(date: Date) -> [Monitoring] {
        var predicates = [NSPredicate]()
        let calendar = Calendar.current
        // get the start of the day of the selected date
        let startDate = calendar.startOfDay(for: date)
        // get the start of the day after the selected date
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        // create a predicate to filter between start date and end date
        let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        predicates.append(datePredicate)

        let request = Monitoring.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let allMeasurements = (try? container.viewContext.fetch(request)) ?? []
        return allMeasurements
    }

    func measurementByMonth(date: Date) -> [Monitoring] {
        var predicates = [NSPredicate]()
        let calendar = Calendar.current
        // get the start of the day of the selected date
        let components = calendar.dateComponents([.year, .month], from: date)
        let startDate = calendar.date(from: components)!
        // get the start of the day after the selected date
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        // create a predicate to filter between start date and end date
        let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        predicates.append(datePredicate)

        let request = Monitoring.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        let allMeasurements = (try? container.viewContext.fetch(request)) ?? []
        return allMeasurements
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
}
