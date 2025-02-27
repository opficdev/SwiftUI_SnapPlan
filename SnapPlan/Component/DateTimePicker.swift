//
//  TimePicker.swift
//  SnapPlan
//
//  Created by opfic on 1/31/25.
//

import SwiftUI

struct DateTimePicker<S: DatePickerStyle>: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTime: Date
    @State private var pickerHeight = CGFloat.zero
    let component: DatePickerComponents
    let style: S
    
    init(selectedTime: Binding<Date>, component: DatePickerComponents, style: S = .wheel) {
        UIDatePicker.appearance().minuteInterval = 5
        self._selectedTime = selectedTime
        self.component = component
        self.style = style
    }
       
    var body: some View {
        VStack {
            DatePicker(
                "",
                selection: $selectedTime,
                displayedComponents: component
            )
            .datePickerStyle(style)
            .labelsHidden()
            
            Button(action: {
                dismiss()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.macBlue)
                        .frame(height: 35)
                    Text("확인")
                        .foregroundStyle(Color.white)
                }
            }
        }
        .padding()
        .background(
            GeometryReader { geometry in
                Color.calendar.onAppear {
                    pickerHeight = geometry.size.height
                }
            }
        )
        .presentationDragIndicator(.visible)
        .presentationDetents([.height(pickerHeight)])
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: selectedTime)
    }
}

#Preview {
    DateTimePicker(
        selectedTime: .constant(Date()),
        component: .hourAndMinute
    )
}
