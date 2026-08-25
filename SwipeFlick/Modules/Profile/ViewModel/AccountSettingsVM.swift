import Foundation

protocol AccountSettingsVMProtocol: AnyObject {
    
    var onOpenURL: ((URL) -> Void)? { get set }
    var onPresentSupportEmail: ((String, String) -> Void)? { get set }
    var onRequestDeleteConfirmation: ((String, String) -> Void)? { get set }
    var onDeleted: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    func openTerms()
    func openPrivacy()
    func contactSupport()
    func requestDelete()
    func confirmDelete()
}

final class AccountSettingsVM: AccountSettingsVMProtocol {
    private let profileVM: ProfileVMProtocol

    var onOpenURL: ((URL) -> Void)?
    var onPresentSupportEmail: ((String, String) -> Void)?
    var onRequestDeleteConfirmation: ((String, String) -> Void)?
    var onDeleted: (() -> Void)?
    var onError: ((String) -> Void)?

    init(profileViewModel: ProfileVMProtocol) {
        self.profileVM = profileViewModel
    }

    func openTerms() {
        guard let url = URL(string: "https://sites.google.com/view/termsofuse-swipeflick") else { return }
        onOpenURL?(url)
    }

    func openPrivacy() {
        guard let url = URL(string: "https://sites.google.com/view/privacypolicy-swipeflick") else { return }
        onOpenURL?(url)
    }

    func contactSupport() {
        onPresentSupportEmail?("swipeflick@gmail.com", "SwipeFlick Support")
    }

    func requestDelete() {
        onRequestDeleteConfirmation?("deleteAccountTitle".translated, "deleteAccountMessage".translated)
    }

    func confirmDelete() {
        profileVM.deleteAccount { [weak self] result in
            switch result {
            case .success:
                self?.onDeleted?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
}
