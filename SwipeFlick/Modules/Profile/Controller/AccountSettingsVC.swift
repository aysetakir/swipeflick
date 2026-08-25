import UIKit
import SnapKit
import MessageUI

final class AccountSettingsVC: UIViewController, MFMailComposeViewControllerDelegate {
    private let viewModel: AccountSettingsVMProtocol

    private let stack = UIStackView()

    init(viewModel: AccountSettingsVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "accountSettings".translated
        view.backgroundColor = .backgroundPrimary
        setupUI()
        setupConstraints()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundPrimary
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .buttonPrimary
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

private extension AccountSettingsVC {
    func setupUI() {
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(stack)

        let terms = SettingRowView(title: "termsOfUse".translated, systemIcon: "doc.text")
        let privacy = SettingRowView(title: "privacyPolicy".translated, systemIcon: "lock.shield")
        let support = SettingRowView(title: "support".translated, systemIcon: "envelope")
        let deleteAcc = SettingRowView(title: "deleteAccount".translated, systemIcon: "trash", style: .destructive)

        [terms, privacy, support, deleteAcc].forEach { stack.addArrangedSubview($0) }

        terms.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        privacy.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
        support.addTarget(self, action: #selector(didTapSupport), for: .touchUpInside)
        deleteAcc.addTarget(self, action: #selector(didTapDeleteAccount), for: .touchUpInside)
    }

    func setupConstraints() {
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    func bind() {
        viewModel.onOpenURL = { url in
            UIApplication.shared.open(url)
        }
        viewModel.onPresentSupportEmail = { [weak self] recipient, subject in
            guard let self else { return }
            if MFMailComposeViewController.canSendMail() {
                let composer = MFMailComposeViewController()
                composer.setToRecipients([recipient])
                composer.setSubject(subject)
                composer.mailComposeDelegate = self
                self.present(composer, animated: true)
            } else if let url = URL(string: "mailto:\(recipient)") {
                UIApplication.shared.open(url)
            }
        }
        viewModel.onRequestDeleteConfirmation = { [weak self] title, message in
            let delete = UIAlertAction(title: "delete".translated, style: .destructive) { _ in
                self?.viewModel.confirmDelete()
            }
            let cancel = UIAlertAction(title: "cancel".translated, style: .cancel)
            self?.alertDialog(title: title, message: message, actions: [delete, cancel])
        }
        viewModel.onDeleted = { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(
                title: "accountDeleted".translated,
                message: "accountDeletedMessage".translated,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "ok".translated, style: .default) { [weak self] _ in
                self?.redirectToAuthentication()
            })
            self.present(alert, animated: true)
        }
        viewModel.onError = { [weak self] message in
            self?.alertDialog(message: message)
        }
    }

    @objc func didTapTerms() { viewModel.openTerms() }
    @objc func didTapPrivacy() { viewModel.openPrivacy() }
    @objc func didTapSupport() { viewModel.contactSupport() }
    @objc func didTapDeleteAccount() { viewModel.requestDelete() }
    
    func redirectToAuthentication() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let tabBarController = TabBarController(authManager: FirebaseAuthManager.shared)
        tabBarController.selectedIndex = 3
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = tabBarController
        }
    }
}
