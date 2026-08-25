import UIKit

extension UIViewController {
    func alertDialog(title: String? = nil,
                     message: String,
                     actions: [UIAlertAction]? = nil,
                     completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let actions = actions, !actions.isEmpty {
            actions.forEach { alert.addAction($0) }
        } else {
            let okAction = UIAlertAction(title: "OK".translated, style: .default)
            alert.addAction(okAction)
        }
        
        self.present(alert, animated: true, completion: completion)
    }
}
