//
//  SearchLocationView.swift
//  SnapPlan
//
//  Created by opfic on 2/28/25.
//

import SwiftUI

struct SearchLocationView: View {
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @State private var location: String = ""
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("위치", text: $location)
                    .focused($focused)
                    .onAppear {
                        focused = true
                    }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
        .ignoresSafeArea(.all, edges: [.horizontal, .bottom])
        .onDisappear {
            scheduleVM.location = location
        }
    }
}

#Preview {
    SearchLocationView()
        .environmentObject(ScheduleViewModel())
}


