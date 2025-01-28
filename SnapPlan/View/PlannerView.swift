//
//  TimeView.swift
//  SnapPlan
//
//  Created by opfic on 12/31/24.
//

import SwiftUI
import SwiftUIIntrospect


struct PlannerView: View {
    @StateObject var plannerVM = PlannerViewModel()
    @StateObject var firebaseVM = FirebaseViewModel()
    @EnvironmentObject var loginVM: LoginViewModel
    @State private var showSideBar = false
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView(
                showSideBar: $showSideBar
            )
                .environmentObject(plannerVM)
            TimeLineView()
                .environmentObject(plannerVM)
        }
        .sheet(isPresented: .constant(true)) {
            ScheduleView(schedule: .constant(nil))
//                .presentationDetents(
//                    [.fraction(0.4), .fraction(0.99)] : [.fraction(0.07)]
//                )
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
                .introspect(.sheet, on: .iOS(.v16, .v17, .v18)) { controller in
                    if let sheet = controller as? UISheetPresentationController {
                        if let maxDetent = sheet.detents.max(by: { $0.identifier.rawValue < $1.identifier.rawValue }) {
                            sheet.largestUndimmedDetentIdentifier = maxDetent.identifier
                        }
                    }
                }
        }
        .onAppear {
            
        }
        .onChange(of: plannerVM.selectDate) { newDate in
            
        }
        
    }
}

#Preview {
    PlannerView()
        .environmentObject(LoginViewModel())
}

