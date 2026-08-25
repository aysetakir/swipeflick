import UIKit
import WebKit
import SnapKit

final class WebViewController: UIViewController {
    
    private let url: URL
    private let pageTitle: String
    private var webView: WKWebView!
    private var loadingIndicator: UIActivityIndicatorView!
    
    init(url: URL, title: String) {
        self.url = url
        self.pageTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPage()
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundPrimary
        title = pageTitle
        
        // MARK: - WebView
        webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .backgroundPrimary
        webView.scrollView.backgroundColor = .backgroundPrimary
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // MARK: - Loading Indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closePressed)
        )
    }
    
    private func loadPage() {
        loadingIndicator.startAnimating()
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc private func closePressed() {
        dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        alertDialog(message: "error".translated)
    }
}
