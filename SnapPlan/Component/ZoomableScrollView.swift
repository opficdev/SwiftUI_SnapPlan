//
//  ZoomableScrollView.swift
//  SnapPlan
//
//  Created by opfic on 5/2/25.
//

import SwiftUI
import UIKit

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    private var minScale: CGFloat
    private var maxScale: CGFloat

    init(@ViewBuilder content: () -> Content, minScale: CGFloat = 1.0, maxScale: CGFloat = 5.0) {
        self.content = content()
        self.minScale = minScale
        self.maxScale = maxScale
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = maxScale
        scrollView.minimumZoomScale = minScale
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            containerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])

        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        context.coordinator.hostingController = hostingController
        context.coordinator.containerView = containerView

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableScrollView
        var hostingController: UIHostingController<Content>?
        var containerView: UIView?

        init(_ parent: ZoomableScrollView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return containerView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let containerView = containerView else { return }

            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)

            containerView.center = CGPoint(
                x: scrollView.contentSize.width * 0.5 + offsetX,
                y: scrollView.contentSize.height * 0.5 + offsetY
            )
        }
    }
}

