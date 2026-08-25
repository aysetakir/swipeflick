import Foundation

extension String {
    var translated: String {
        NSLocalizedString(self, comment: "")
    }
}
