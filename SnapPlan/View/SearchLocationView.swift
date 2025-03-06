//
//  SearchLocationView.swift
//  SnapPlan
//
//  Created by opfic on 2/28/25.
//

import SwiftUI

struct SearchLocationView: View {
    @EnvironmentObject var searchVM: SearchLocationViewModel
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focused: Bool
    @State private var address = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("검색", text: $searchVM.query)
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
                VStack(alignment: .leading) {
                    Text(suggestion.title)
                    Text(suggestion.subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    searchVM.query = suggestion.title
                    address = suggestion.subtitle
                    dismiss()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("위치")
                    .font(.headline)
                    .bold()
            }
        }
        .ignoresSafeArea(.container, edges: [.horizontal, .bottom])
        .frame(maxHeight: .infinity, alignment: .top)
        .onDisappear {
            scheduleVM.location = searchVM.query
            scheduleVM.address = address
            DispatchQueue.main.async {
                focused = false
            }
        }
    }
}
