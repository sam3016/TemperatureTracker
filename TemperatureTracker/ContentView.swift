//
//  ContentView.swift
//  TemperatureTracker
//
//  Created by Sam Hui on 2023/07/05.
//

import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    @State private var showingChart = false

    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter
    private let monthYearFormatter: DateFormatter

    @State private var selectedDate = Self.now
    private static var now = Date() // Cache now

    init(calendar: Calendar) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
        self.monthYearFormatter = DateFormatter(dateFormat: "MMMM yyyy", calendar: calendar)
    }

    var body: some View {
        VStack {
            CalendarView(
                calendar: calendar,
                date: $selectedDate,
                content: { date in
                    Button {
                        selectedDate = date
                    } label: {
                        Text("00")
                            .padding(8)
                            .foregroundColor(.clear)
                            .background(
                                calendar.isDate(date, inSameDayAs: selectedDate) ? Color.red
                                    : calendar.isDateInToday(date) ? .green
                                    : .blue
                            )
                            .cornerRadius(8)
                            .accessibilityHidden(true)
                            .overlay(
                                Text(dayFormatter.string(from: date))
                                    .foregroundColor(.white)
                            )
                    }
                    .accessibilityLabel(fullFormatter.string(from: date))
                },
                trailing: { date in
                    Text(dayFormatter.string(from: date))
                        .foregroundColor(.secondary)
                },
                header: { date in
                    Text(weekDayFormatter.string(from: date))
                },
                title: { date in
                    HStack {
                        Text(monthYearFormatter.string(from: date))
                            .font(.headline)
                            .padding()
                        Spacer()
                        Button {
                            withAnimation {
                                guard let newDate = calendar.date(
                                    byAdding: .month,
                                    value: -1,
                                    to: selectedDate
                                ) else {
                                    return
                                }

                                selectedDate = newDate
                            }
                        } label: {
                            Label(
                                title: { Text("Previous") },
                                icon: { Image(systemName: "chevron.left") }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                            .frame(maxHeight: .infinity)
                        }
                        Button {
                            withAnimation {
                                guard let newDate = calendar.date(
                                    byAdding: .month,
                                    value: 1,
                                    to: selectedDate
                                ) else {
                                    return
                                }

                                selectedDate = newDate
                            }
                        } label: {
                            Label(
                                title: { Text("Next") },
                                icon: { Image(systemName: "chevron.right") }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                            .frame(maxHeight: .infinity)
                        }
                    }
                    .padding(.bottom, 6)
                }
            )
            .equatable()

            List(selection: $dataController.selectedMeasurement) {
                ForEach(dataController.measurementByDate(date: selectedDate)) { measurement in
                    MeasurementRow(monitoring: measurement)
                }
                .onDelete(perform: delete)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    dataController.newMeasurement(selectedDate: selectedDate)
                } label: {
                    Label("New Measurement", systemImage: "square.and.pencil")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingChart.toggle()
                } label: {
                    Label("Chart", systemImage: "chart.xyaxis.line")
                }
                .disabled(getMonthData().count == 0)
            }
        }
        .sheet(isPresented: $showingChart) {
            GroupBox("Temeprature Change on \(monthYearFormatter.string(from: selectedDate))") {
                Chart {
                    ForEach(getMonthData()) {
                        LineMark(
                            x: .value("Week Day", $0.weekday, unit: .day),
                            y: .value("Temperature", $0.temperature)
                        )
                        .foregroundStyle(by: .value("Value", "Temperature"))
                    }
                    .lineStyle(StrokeStyle(lineWidth: 2.0))
                    .interpolationMethod(.cardinal)
                }
                .chartYScale(domain: [35, 41])
                .chartForegroundStyleScale([
                    "Temperature": .red
                ])
            }
        }
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = dataController.measurementByDate(date: selectedDate)[offset]
            dataController.delete(item)
        }
    }

    func getMonthData() -> [LineChartDataPoint] {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return dataController.measurementByMonth(date: selectedDate).map {
            let data = LineChartDataPoint(
                day: formatter.string(from: $0.measurementDate),
                temperature: $0.measurementTemperature
            )
            return data
        }
    }
}

// MARK: - Component

public struct CalendarView<Day: View, Header: View, Title: View, Trailing: View>: View {
    // Injected dependencies
    private var calendar: Calendar
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let trailing: (Date) -> Trailing
    private let header: (Date) -> Header
    private let title: (Date) -> Title

    // Constants
    private let daysInWeek = 7

    public init(
        calendar: Calendar,
        date: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder trailing: @escaping (Date) -> Trailing,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title
    ) {
        self.calendar = calendar
        self._date = date
        self.content = content
        self.trailing = trailing
        self.header = header
        self.title = title
    }

    public var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()

        return LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
            Section(header: title(month)) {
                ForEach(days.prefix(daysInWeek), id: \.self, content: header)
                ForEach(days, id: \.self) { date in
                    if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                        content(date)
                    } else {
                        trailing(date)
                    }
                }
            }
        }
    }
}

// MARK: - Conformances

extension CalendarView: Equatable {
    public static func == (
        lhs: CalendarView<Day, Header, Title, Trailing>,
        rhs: CalendarView<Day, Header, Title, Trailing>) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }
}

// MARK: - Helpers

private extension CalendarView {
    func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
}

private extension Calendar {
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates = [dateInterval.start]

        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }

            guard date < dateInterval.end else {
                stop = true
                return
            }

            dates.append(date)
        }

        return dates
    }

    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
}

private extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}

// MARK: - Previews

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(calendar: Calendar(identifier: .gregorian))
            ContentView(calendar: Calendar(identifier: .islamicUmmAlQura))
            ContentView(calendar: Calendar(identifier: .hebrew))
            ContentView(calendar: Calendar(identifier: .indian))
        }
    }
}
#endif
