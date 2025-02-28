//
//  SearchLocationView.swift
//  SnapPlan
//
//  Created by opfic on 2/28/25.
//

import SwiftUI

struct SearchLocationView: View {
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @EnvironmentObject var searchVM: SearchLocationViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("위치", text: $searchVM.query)
                    .focused($focused)
                    .onAppear {
                        focused = true
                    }
                if !searchVM.query.isEmpty {
                    Button(action: {
                        scheduleVM.location.removeAll()
                        searchVM.query.removeAll()
                        searchVM.suggestions.removeAll()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(colorScheme == .light ? .systemGray5 : .systemGray4))
            )
            .padding(.horizontal)
            
            List(searchVM.suggestions, id: \.self) { suggestion in
                Text(suggestion.title)
                    .onTapGesture {
                        scheduleVM.location = suggestion.title
                        searchVM.query = suggestion.title
                        dismiss()
                    }
            }
        }
        .ignoresSafeArea(.container, edges: [.horizontal, .bottom])
        .frame(maxHeight: .infinity, alignment: .top)
        .onDisappear {
            if searchVM.suggestions.isEmpty {
                scheduleVM.location = searchVM.query
            }
            DispatchQueue.main.async {
                focused = false
            }
        }
    }
}

#Preview {
    SearchLocationView()
        .environmentObject(ScheduleViewModel())
        .environmentObject(SearchLocationViewModel())
}


