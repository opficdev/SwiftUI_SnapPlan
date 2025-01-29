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
    @State private var didSelectSchedule = false
    @State private var tapButton = false
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView(
                showSideBar: $showSideBar
            )
                .environmentObject(plannerVM)
            TimeLineView(
                didSelectSchedule: $didSelectSchedule
            )
                .environmentObject(plannerVM)
        }
        .sheet(isPresented: .constant(true)) {
            ScheduleView(
                schedule: .constant(nil),
                tapButton: $tapButton
            )
            .ignoresSafeArea(.keyboard)
            .presentationDetents(getDetent())
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
    
    private func getDetent() -> Set<PresentationDetent> {
        if didSelectSchedule {
            return [.fraction(0.4), .fraction(0.9)]
        }
        if tapButton {
            return [.fraction(0.9)]
        }
        return [.fraction(0.07)]
    }
}

#Preview {
    PlannerView()
        .environmentObject(LoginViewModel())
}

