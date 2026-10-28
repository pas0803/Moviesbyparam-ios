import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private let startURL = URL(string: "https://movienova.sc/")!
    private let siteHost = "movienova.sc"
    private var webView: WKWebView!
    private let progressBar = UIProgressView(progressViewStyle: .bar)
    private let backButton = UIButton(type: .system)
    private var progressObservation: NSKeyValueObservation?

    // Common ad / popup networks that get blocked
    private let blockedHosts = [
        "doubleclick.net", "googlesyndication.com", "googleadservices.com",
        "popads.net", "popcash.net", "propellerads.com", "adsterra.com",
        "exoclick.com", "juicyads.com", "trafficjunky.net", "clickadu.com",
        "hilltopads.net", "onclickads.net", "adcash.com", "popunder.net",
        "revenuehits.com", "mgid.com", "taboola.com", "outbrain.com",
        "adnxs.com", "ad-maven.com", "admaven.com", "monetag.com",
        "richpush.co", "pushame.com", "a-ads.com"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.javaScriptCanOpenWindowsAutomatically = false

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)

        // Floating back button
        backButton.setTitle("\u{2190}", for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        backButton.layer.cornerRadius = 24
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        view.addSubview(backButton)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: guide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            progressBar.topAnchor.constraint(equalTo: guide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),
            backButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            backButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -24)
        ])

        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] web, _ in
            guard let self = self else { return }
            self.progressBar.progress = Float(web.estimatedProgress)
            self.progressBar.isHidden = web.estimatedProgress >= 1.0
        }

        webView.load(URLRequest(url: startURL))
    }

    @objc private func goBack() {
        if webView.canGoBack { webView.goBack() }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func isSite(_ host: String?) -> Bool {
        guard let h = host?.lowercased() else { return false }
        return h == siteHost || h.hasSuffix("." + siteHost)
    }

    private func isBlocked(_ host: String?) -> Bool {
        guard let h = host?.lowercased() else { return false }
        return blockedHosts.contains { h == $0 || h.hasSuffix("." + $0) }
    }

    // Only the site itself may be loaded as a page; ad redirects and app-launch links are dropped
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        let scheme = url.scheme?.lowercased() ?? ""
        if scheme == "about" || scheme == "blob" || scheme == "data" {
            decisionHandler(.allow)
            return
        }
        if navigationAction.targetFrame?.isMainFrame == false {
            // iframes (video players etc.) are fine unless they are ad hosts
            decisionHandler(isBlocked(url.host) ? .cancel : .allow)
            return
        }
        if (scheme == "http" || scheme == "https") && isSite(url.host) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }

    // Refuse every popup window
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        return nil
    }
}
