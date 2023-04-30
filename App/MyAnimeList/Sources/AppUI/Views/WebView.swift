//
//  Created by Maharjan Binish on 2023/04/30.
//

import SwiftUI
import WebKit

public final class WebViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {
    public init(url: URL, bottomEdgeReachedAction: @escaping () -> Void) {
        self.url = url
        self.bottomEdgeReachedAction = bottomEdgeReachedAction
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let url: URL
    private let bottomEdgeReachedAction: () -> Void

    private(set) var loadingCount = 0 {
        didSet {
            if loadingCount <= 0 {
                loadingCount = 0
            }
        }
    }

    var webView: WKWebView {
        view as! WKWebView
    }

    public override func loadView() {
        let webView = WKWebView()
        assert(webView.scrollView.delegate == nil)
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        view = webView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: url))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "goforward"), primaryAction: UIAction { [unowned self] _ in
            self.webView.reload()
        })
    }

    public override func willMove(toParent parent: UIViewController?) {
        if let parent {
            // `WebView` (SwiftUI)を`AppNavigationController`で表示するためにUIHostingControllerでラップした場合、
            // このVCはUIHostingControllerが親VCになるため、navigationItemの内容をコピーする。
            parent.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        }
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingCount += 1
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingCount -= 1
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingCount -= 1
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdgeOffset = scrollView.contentSize.height - scrollView.adjustedContentInset.bottom - scrollView.bounds.height
        if bottomEdgeOffset < scrollView.contentOffset.y, scrollView.isDecelerating, loadingCount == 0 {
            bottomEdgeReachedAction()
        }
    }
}

// MARK: - SwiftUI

public struct WebView: UIViewControllerRepresentable {
    public init(url: URL, onReachBottomEdge: @escaping () -> Void = {}) {
        self.url = url
        self.onReachBottomEdge = onReachBottomEdge
    }

    let url: URL
    let onReachBottomEdge: () -> Void

    public func makeUIViewController(context: Context) -> some UIViewController {
        WebViewController(url: url, bottomEdgeReachedAction: onReachBottomEdge)
    }

    public func updateUIViewController(_ uiViewController: some UIViewController, context: Context) {
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "https://www.example.com")!)
            .bottomFloatingButton("Agree", action: {})
    }
}
