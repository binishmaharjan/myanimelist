//
//  Created by Maharjan Binish on 2023/04/30.
//

import UIKit

/// アプリ共通のnavigation controller。
///
/// - 通常の`UINavigationController`からの変更点
///   - navigation barの背景色が``AppColor``の`primary`となる
///   - navigation bar上のボタンの色が``AppColor``の`white1`となる
///   - 戻るボタンのタイトルが非表示となる
open class AppNavigationController: UINavigationController {
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        minimizeBackButton(of: rootViewController)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithOpaqueBackground()
        barAppearance.titleTextAttributes[.foregroundColor] = UIColor(appColor: .primary)
        barAppearance.backgroundColor = .app(.white1)
//        barAppearance.shadowColor = .clear
        navigationBar.standardAppearance = barAppearance
        navigationBar.scrollEdgeAppearance = barAppearance
        navigationBar.tintColor = .app(.white1)
    }

    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        viewControllers.forEach(minimizeBackButton(of:))
        super.setViewControllers(viewControllers, animated: animated)
    }

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        minimizeBackButton(of: viewController)
        super.pushViewController(viewController, animated: animated)
    }

    private func minimizeBackButton(of viewController: UIViewController) {
        viewController.navigationItem.backButtonDisplayMode = .minimal
    }
}

// MARK: - Previews

import SwiftUI

private struct AppNavigationViewPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let rootViewController = UIViewController()
        rootViewController.title = "Root"
        let navController = AppNavigationController(rootViewController: rootViewController)
        let viewController = UIViewController()
        viewController.title = "ViewController"
        navController.pushViewController(viewController, animated: false)
        return navController
    }
    func updateUIViewController(_ uiViewController: some UIViewController, context: Context) {
    }
}

//@available(iOS 17.0, *)
//#Preview {
//    AppNavigationViewPreview()
//        .ignoresSafeArea()
//}
