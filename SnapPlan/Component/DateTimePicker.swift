//
//  TimePicker.swift
//  SnapPlan
//
//  Created by opfic on 1/31/25.
//

import SwiftUI

struct DateTimePicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTime: Date
    @Binding var pickerHeight: CGFloat
    @State private var component: DatePickerComponents
    
    init(selectedTime: Binding<Date>, pickerHeight: Binding<CGFloat>,component: DatePickerComponents) {
        self._selectedTime = selectedTime
        self._pickerHeight = pickerHeight
        self._component = State(initialValue: component)
    }
       
    var body: some View {
        VStack {
            DatePicker(
                "",
                selection: $selectedTime,
                displayedComponents: component
            )
            .datePickerStyle(.wheel)
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
                    print(pickerHeight)
                }
            }
        )
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
        pickerHeight: .constant(0),
        component: .hourAndMinute
    )
}
