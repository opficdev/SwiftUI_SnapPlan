//
//  TimePicker.swift
//  SnapPlan
//
//  Created by opfic on 1/31/25.
//

import SwiftUI

struct TimePicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTime: Date
       
    var body: some View {
       VStack {
           DatePicker(
               "",
               selection: $selectedTime,
               displayedComponents: .hourAndMinute
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
       .background(Color.calendar)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: selectedTime)
    }
}

#Preview {
    TimePicker(
        selectedTime: .constant(Date())
    )
}
