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
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView()
                .environmentObject(plannerVM)
                .environmentObject(loginVM)
            TimeLineView()
                .environmentObject(plannerVM)
        }
        .sheet(isPresented: .constant(true)) {
            ScheduleView(schedule: .constant(nil))
                .presentationDetents(
                    firebaseVM.isScheduleExist() ?
                    [.fraction(0.4), .fraction(0.99)] : [.fraction(0.1)]
                )
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
    }
}

#Preview {
    PlannerView()
        .environmentObject(LoginViewModel())
}

