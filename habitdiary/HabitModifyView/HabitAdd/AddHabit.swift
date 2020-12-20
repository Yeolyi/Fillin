//
//  AddHabit.swift
//  habitdiary
//
//  Created by SEONG YEOL YI on 2020/12/13.
//

import SwiftUI

struct AddHabit: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var sizeClass
    @EnvironmentObject var listOrderManager: ListOrderManager
    @EnvironmentObject var sharedViewData: AppSetting
    @FetchRequest(
        entity: HabitInfo.entity(),
        sortDescriptors: []
    )
    var habitInfos: FetchedResults<HabitInfo>
    @State var currentPage = 1
    let totalPage = 4
    @State var habitName = ""
    @State var habitType = HabitType.daily
    @State var dayOfTheWeek: [Int] = []
    @State var number = "1"
    @State var selectedColor = "#404040"
    var isNextAvailable: Bool {
        switch currentPage {
        case 1: return habitName != ""
        case 2: return habitType == .daily ? true : !dayOfTheWeek.isEmpty
        case 3: return Int(number) ?? 0 > 0
        case 4: return true
        default:
            assertionFailure()
            return true
        }
    }
    var body: some View {
        VStack {
            if currentPage == 1 {
                NameSection(name: $habitName)
            }
            if currentPage == 2 {
                DateSection(habitType: $habitType, dayOfTheWeek: $dayOfTheWeek)
            }
            if currentPage == 3 {
                TimesSection(number: $number)
            }
            if currentPage == 4 {
                ThemeSection(color: $selectedColor)
            }
            Spacer()
            HStack {
                previousButton
                Spacer()
            }
            nextButton
        }
        .padding(.bottom, 30)
    }
    var previousButton: some View {
        Button(action: {
            withAnimation { self.currentPage = max(self.currentPage - 1, 1) }
        }) {
            Text("이전으로")
                .fixedSize()
                .foregroundColor(ThemeColor.mainColor(colorScheme))
                .padding(.leading, 10)
                .padding(.bottom, 3)
        }
        .if(currentPage == 1) {
            $0.hidden()
        }
    }
    var nextButton: some View {
        Button(action: {
            if isNextAvailable == false { return }
            if currentPage == totalPage {
                saveAndQuit()
                return
            }
            withAnimation { self.currentPage += 1 }
        }) {
            HStack {
                Spacer()
                Text(currentPage == totalPage ? "완료": "다음 (\(currentPage)/\(totalPage))")
                    .font(.system(size: 18, weight: .medium))
                    .fixedSize()
                    .foregroundColor(.white)
                    .padding([.top, .bottom], 15)
                Spacer()
            }
            .background(ThemeColor.mainColor(colorScheme))
        }
        .padding([.leading, .trailing], 10)
        .opacity(isNextAvailable ? 1.0 : 0.3)
    }
    func saveAndQuit() {
        dayOfTheWeek = dayOfTheWeek.sorted(by: <)
        let newHabit = HabitInfo(context: managedObjectContext)
        let habitID = UUID()
        newHabit.name = habitName
        newHabit.color = selectedColor
        newHabit.habitType = habitType.rawValue
        newHabit.targetDays = dayOfTheWeek.map({Int16($0)})
        newHabit.id = habitID
        newHabit.targetAmount = Int16(number) ?? 1
        newHabit.achieve = [:]
        newHabit.requiredSecond = 0
        CoreDataManager.save(managedObjectContext)
        listOrderManager.habitOrder.append(OrderInfo(elementId: habitID))
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct AddHabit_Previews: PreviewProvider {
    static var previews: some View {
        AddHabit()
    }
}
