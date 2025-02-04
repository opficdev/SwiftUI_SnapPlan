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
    @EnvironmentObject var firebaseVM: FirebaseViewModel
    @State private var showSideBar = false
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView(showSideBar: $showSideBar)
                .environmentObject(plannerVM)
            TimeLineView()
                .environmentObject(plannerVM)
        }
        .sheet(isPresented: .constant(true)) {
            ScheduleView(schedule: .constant(nil))
                .environmentObject(plannerVM)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)   //  사용자가 임의로 sheet를 완전히 내리는 것을 방지
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
        .environmentObject(FirebaseViewModel())
}

