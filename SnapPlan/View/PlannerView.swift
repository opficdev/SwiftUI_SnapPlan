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
        UIKitSheetWrapper()
            .edgesIgnoringSafeArea(.all)
            .environmentObject(plannerVM)
            .environmentObject(loginVM)
    }
}

struct UIKitSheetWrapper: UIViewControllerRepresentable {
    @EnvironmentObject var plannerVM: PlannerViewModel
    @EnvironmentObject var loginVM: LoginViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        let rootController = UIViewController()
        rootController.view.backgroundColor = .clear

        DispatchQueue.main.async {
            let sheetVC = MainViewController()
            sheetVC.plannerVM = plannerVM
            sheetVC.loginVM = loginVM
            sheetVC.modalPresentationStyle = .overFullScreen
            sheetVC.modalTransitionStyle = .crossDissolve
            rootController.present(sheetVC, animated: true)
        }
        return rootController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class BackgroundViewController: UIHostingController<AnyView> {
    init(plannerVM: PlannerViewModel, loginVM: LoginViewModel) {
        let rootView = VStack(spacing: 0) {
            CalendarView()
                .environmentObject(plannerVM)
                .environmentObject(loginVM)
            TimeLineView()
                .environmentObject(plannerVM)
        }
        super.init(rootView: AnyView(rootView))
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 메인 뷰 컨트롤러
class MainViewController: UIViewController {
    var plannerVM: PlannerViewModel!
    var loginVM: LoginViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear // ✅ 배경 투명 유지

        // 배경 뷰에 SwiftUI 뷰 추가
        let backgroundVC = BackgroundViewController(plannerVM: plannerVM, loginVM: loginVM)
        addChild(backgroundVC)
        view.addSubview(backgroundVC.view)
        backgroundVC.view.frame = view.bounds
        backgroundVC.didMove(toParent: self)
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

            // 배경 어둡게 하지 않기
            sheet.largestUndimmedDetentIdentifier = sheet.detents[1].identifier
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

