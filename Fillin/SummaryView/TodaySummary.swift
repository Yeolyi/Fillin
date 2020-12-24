//
//  TodaySummary.swift
//  habitdiary
//
//  Created by SEONG YEOL YI on 2020/12/21.
//

import SwiftUI

struct TodaySummary: View {
    @EnvironmentObject var displayManager: DisplayManager
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: []
    )
    var habitInfos: FetchedResults<Habit>
    @Binding var selectedDate: Date
    var habit: [Habit] = []
    var body: some View {
        VStack {
            Text("Data".localized)
                .sectionText()
            if !displayManager.summaryProfile.isEmpty {
                ForEach(displayManager.summaryProfile[0].idArray.compactMap({$0}).uniqueValues, id: \.self) { habitID in
                    idToRow(id: habitID)
                }
            }
        }
    }
    func idToRow(id: UUID) -> AnyView {
        guard let habit = habitInfos.first(where: {$0.id == id}) else {
            return AnyView(EmptyView())
        }
        return AnyView(
            MainRow(habit: habit, showAdd: false, date: selectedDate)
        )
    }
}

struct TodaySummary_Previews: PreviewProvider {
    static var previews: some View {
        TodaySummary(selectedDate: .constant(Date()))
    }
}

extension Array where Element: Hashable {
    var uniqueValues: [Element] {
        var allowed = Set(self)
        return compactMap { allowed.remove($0) }
    }
}
