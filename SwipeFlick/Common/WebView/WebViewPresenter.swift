import UIKit

enum WebViewPresenter {
    static func present(from source: AnyObject, url: URL, title: String) {
        let webVC = WebViewController(url: url, title: title)
        let nav = UINavigationController(rootViewController: webVC)
        nav.modalPresentationStyle = .pageSheet
        
        if let vc = source as? UIViewController {
            vc.present(nav, animated: true)
        } else if let view = source as? UIView,
                  let parent = view.parentViewController {
            parent.present(nav, animated: true)
        } else {
            print("⚠️ WebViewPresenter: Could not find a presenting controller.")
        }
    }
}
