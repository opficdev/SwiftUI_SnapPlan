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
    
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView(showSideBar: $showSideBar)
                .environmentObject(plannerVM)
            TimeLineView(didSelectSchedule: $didSelectSchedule)
                .environmentObject(plannerVM)
        }
        .sheet(isPresented: .constant(true)) {
            ScheduleView(schedule: .constant(nil))
            .presentationDragIndicator(.visible)
            .introspect(.sheet, on: .iOS(.v16, .v17, .v18)) { controller in //  sheet가 올라와있어도 하위 뷰에 터치가 가능하도록 해줌
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

