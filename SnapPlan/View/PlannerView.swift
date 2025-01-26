//
//  TimeView.swift
//  SnapPlan
//
//  Created by opfic on 12/31/24.
//

import SwiftUI
import SwiftUIIntrospect
import UIKit

struct PlannerView: View {
    @StateObject var plannerVM = PlannerViewModel()
    @StateObject var firebaseVM = FirebaseViewModel()
    @EnvironmentObject var loginVM: LoginViewModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                CalendarView()
                    .environmentObject(plannerVM)
                    .environmentObject(loginVM)
                TimeLineView()
                    .environmentObject(plannerVM)
            }
//                    .sheet(isPresented: .constant(true)) {
//                        ScheduleView(schedules: .constant(nil))
//                            .presentationDetents([.fraction(0.1), .fraction(0.4), .fraction(0.99)])
//                            .presentationDragIndicator(.visible)
//                            .interactiveDismissDisabled(true)
//                            .presentationBackgroundInteraction(.enabled)
//                    }
            
            UIKitSheetWrapper()
        }
    }
}

struct UIKitSheetWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let rootController = UIViewController()
        rootController.view.backgroundColor = .clear

        DispatchQueue.main.async {
            let sheetVC = MainViewController()
            sheetVC.modalPresentationStyle = .overFullScreen
            sheetVC.modalTransitionStyle = .crossDissolve
            rootController.present(sheetVC, animated: true)
        }
        return rootController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear // ✅ 배경 투명 유지
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSheet()
    }

    func presentSheet() {
        let scheduleVC = ScheduleViewController()
        if let sheet = scheduleVC.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { context in 0.1 * context.maximumDetentValue }),
                .custom(resolver: { context in 0.4 * context.maximumDetentValue }),
                .custom(resolver: { context in 0.99 * context.maximumDetentValue })
            ]
            sheet.prefersGrabberVisible = true // ✅ .presentationDragIndicator(.visible)
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = false
        }

        // 시트의 뷰가 터치 이벤트를 가로채지 않도록 설정
        scheduleVC.view.isUserInteractionEnabled = false
        present(scheduleVC, animated: true)
    }
}

class ScheduleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        isModalInPresentation = true // ✅ SwiftUI의 .interactiveDismissDisabled(true)와 동일
    }
}

#Preview {
    PlannerView()
        .environmentObject(LoginViewModel())
}

