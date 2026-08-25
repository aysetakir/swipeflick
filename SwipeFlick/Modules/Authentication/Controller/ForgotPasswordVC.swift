import UIKit
import SnapKit

final class ForgotPasswordVC: UIViewController {
    private let viewModel: ForgotPasswordVMProtocol
    private let prefilledEmail: String?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.isScrollEnabled = false
        scrollView.alwaysBounceVertical = false
        return scrollView
    }()
    private lazy var contentView = UIView()
    
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "resetPasswordTitle".translated
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    private lazy var headerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "resetPasswordSubtitle".translated
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    private lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .backgroundSecondary
        container.layer.cornerRadius = 35
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return container
    }()
    
    private var emailInputView: UIView!
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("sendResetLink".translated, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .buttonPrimary
        button.layer.cornerRadius = 28
        button.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: ForgotPasswordVMProtocol, prefilledEmail: String? = nil) {
        self.viewModel = viewModel
        self.prefilledEmail = prefilledEmail
        super.init(nibName: nil, bundle: nil)
}
    

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = ""
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .backgroundPrimary
        setupViews()
        setupConstraints()
        setupKeyboardGesture()
    }
    
    
    @objc private func didTapSend() {
        view.endEditing(true)
        guard let textField = emailInputView.subviews.compactMap({ $0 as? UITextField }).first else { return }
        let email = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !email.isEmpty else {
            alertDialog(message: "emptyFields".translated)
            return
        }
        viewModel.sendReset(email: email) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let confirmAction = UIAlertAction(title: "ok".translated, style: .default) { [weak self] _ in
                        guard let navigationControllerRef = self?.navigationController else { return }
                        if let authenticationViewController = navigationControllerRef.viewControllers.first(where: { $0 is AuthenticationVC }) as? AuthenticationVC {
                            authenticationViewController.resetToLogin()
                            navigationControllerRef.popToViewController(authenticationViewController, animated: true)
                        } else {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                    self?.alertDialog(title: "success".translated, message: "passwordResetEmailSent".translated, actions: [confirmAction])
                case .failure(let error):
                    guard let self else { return }
                    self.alertDialog(message: self.viewModel.message(for: error))
                }
            }
        }
    }
}

// MARK: - Constraints
private extension ForgotPasswordVC {
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerTitleLabel)
        contentView.addSubview(headerSubtitleLabel)
        contentView.addSubview(containerView)

        emailInputView = customTextField(
            title: "email".translated,
            placeholder: "swipeflick@gmail.com",
            iconName: "envelope",
            isSecure: false
        )
        if let textField = emailInputView.subviews.compactMap({ $0 as? UITextField }).first, let prefill = prefilledEmail, !prefill.isEmpty {
            textField.text = prefill
            textField.autocapitalizationType = .none
        }
        containerView.addSubview(emailInputView)
        containerView.addSubview(sendButton)
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
            make.height.greaterThanOrEqualTo(scrollView).priority(.low)
        }
        headerTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(62)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
        }
        headerSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(headerTitleLabel)
        }
        containerView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(headerSubtitleLabel.snp.bottom).offset(40)
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(185)
            make.leading.trailing.bottom.equalToSuperview()
        }
        emailInputView.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(30)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(70)
        }
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(emailInputView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(56)
        }
    }

    func setupKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() { view.endEditing(true) }
}
