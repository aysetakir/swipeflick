import UIKit
import SnapKit

final class AuthenticationVC: UIViewController {
    private let viewModel: AuthenticationVMProtocol
    var onSuccess: (() -> Void)?
    
    private var isLoginSelected = true
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "authenticationTitle".translated
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var headerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "authenticationSubtitle".translated
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 35
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var segmentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray.withAlphaComponent(0.1)
        view.layer.cornerRadius = 25
        return view
    }()
    
    private lazy var selectedSegment: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 21
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var loginTabButton: UIButton = {
        let button = UIButton()
        button.setTitle("login".translated, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    private lazy var registerTabButton: UIButton = {
        let button = UIButton()
        button.setTitle("register".translated, for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    private var nameInputView: UIView?
    private var surnameInputView: UIView?
    private var emailInputView: UIView!
    private var passwordInputView: UIView!
    private var confirmPasswordInputView: UIView?
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("forgotPassword".translated, for: .normal)
        button.setTitleColor(.buttonPrimary, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
        return button
    }()
    
    private lazy var authButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("login".translated, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .buttonPrimary
        button.layer.cornerRadius = 28
        return button
    }()
    
    init(viewModel: AuthenticationVMProtocol, onSuccess: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onSuccess = onSuccess
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        setupViews()
        setupConstraints()
        setupSegmentActions()
        updateForm()
        setupNotificationCenter()
        setupKeyboardGasture()
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = isLoginSelected ? "login".translated : "register".translated
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerTitleLabel)
        contentView.addSubview(headerSubtitleLabel)
        
        contentView.addSubview(containerView)
        containerView.addSubview(segmentContainer)
        segmentContainer.addSubview(selectedSegment)
        segmentContainer.addSubview(loginTabButton)
        segmentContainer.addSubview(registerTabButton)
        
        containerView.addSubview(forgotPasswordButton)
        containerView.addSubview(authButton)
    }
    
    // MARK: - Segment Actions
    private func setupSegmentActions() {
        loginTabButton.addTarget(self, action: #selector(didTapLoginTab), for: .touchUpInside)
        registerTabButton.addTarget(self, action: #selector(didTapRegisterTab), for: .touchUpInside)
    }
    
    @objc private func didTapLoginTab() {
        guard !isLoginSelected else { return }
        isLoginSelected = true
        animateSegment(toLogin: true)
        updateForm()
    }
    
    @objc private func didTapRegisterTab() {
        guard isLoginSelected else { return }
        isLoginSelected = false
        animateSegment(toLogin: false)
        updateForm()
    }
    
    private func animateSegment(toLogin: Bool) {
        selectedSegment.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalTo(segmentContainer).multipliedBy(0.5).offset(-12)
            if toLogin {
                make.leading.equalToSuperview().offset(4)
            } else {
                make.leading.equalTo(segmentContainer.snp.centerX).offset(8)
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.segmentContainer.layoutIfNeeded()
            self.loginTabButton.setTitleColor(toLogin ? .black : .gray, for: .normal)
            self.registerTabButton.setTitleColor(toLogin ? .gray : .black, for: .normal)
        }
    }
    
    // MARK: - Update Form
    private func updateForm() {
        [
            emailInputView,
            passwordInputView,
            confirmPasswordInputView,
            nameInputView,
            surnameInputView
        ].forEach {
            $0?.removeFromSuperview()
        }
        
        title = isLoginSelected ? "login".translated : "register".translated
        
        if isLoginSelected {
            // MARK: - Login
            nameInputView = nil
            surnameInputView = nil
            confirmPasswordInputView = nil
            
            emailInputView = customTextField(
                title: "email".translated,
                placeholder: "swipeflick@gmail.com",
                iconName: "envelope",
                isSecure: false
            )
            passwordInputView = customTextField(
                title: "password".translated,
                placeholder: "*********",
                iconName: "lock",
                isSecure: true
            )
            
            authButton.setTitle("login".translated, for: .normal)
            forgotPasswordButton.isHidden = false
            
        } else {
            // MARK: - Register
            nameInputView = customTextField(
                title: "name".translated,
                placeholder: "Swipe",
                iconName: "person",
                isSecure: false
            )
            surnameInputView = customTextField(
                title: "surname".translated,
                placeholder: "Flick",
                iconName: "person",
                isSecure: false
            )
            emailInputView = customTextField(
                title: "email".translated,
                placeholder: "swipeflick@gmail.com",
                iconName: "envelope",
                isSecure: false
            )
            passwordInputView = customTextField(
                title: "password".translated,
                placeholder: "*********",
                iconName: "lock",
                isSecure: true
            )
            confirmPasswordInputView = customTextField(
                title: "confirmPassword".translated,
                placeholder: "*********",
                iconName: "lock",
                isSecure: true
            )
            
            authButton.setTitle("register".translated, for: .normal)
            forgotPasswordButton.isHidden = true
            
            containerView.addSubview(nameInputView!)
            containerView.addSubview(surnameInputView!)
            containerView.addSubview(confirmPasswordInputView!)
        }
        
        authButton.addTarget(
            self,
            action: #selector(didTapAuthButton),
            for: .touchUpInside
        )
        
        containerView.addSubview(emailInputView)
        containerView.addSubview(passwordInputView)
        
        setupFormConstraints()
    }
    
    //MARK: - Notification Center
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    //MARK: - Keyboard Gesture
    private func setupKeyboardGasture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func findFirstResponder() -> UIView? {
        return containerView.subviews.first { view in
            guard let textField = view.subviews.compactMap({ $0 as? UITextField }).first else { return false }
            return textField.isFirstResponder
        }
    }
}

//MARK: - Keyboard Handling
private extension AuthenticationVC {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        if let activeTextField = findFirstResponder() {
            let rect = activeTextField.convert(activeTextField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - TextField Delegate
extension AuthenticationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Login/Register Button Action
private extension AuthenticationVC {
    @objc func didTapAuthButton() {
        view.endEditing(true)
        
        guard let emailField = emailInputView.subviews.compactMap({ $0 as? UITextField }).first,
              let passwordField = passwordInputView.subviews.compactMap({ $0 as? UITextField }).first else {
            return
        }
        
        let email = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let password = passwordField.text ?? ""
        
        if isLoginSelected {
            guard !email.isEmpty, !password.isEmpty else {
                alertDialog(message: "emptyFields".translated)
                return
            }
            
            viewModel.login(email: email, password: password) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        FirebaseUserPreferencesManager.shared.prefetchAllData {
                            self?.onSuccess?()
                        }
                    case .failure(let error):
                        guard let self else { return }
                        self.alertDialog(message: self.viewModel.message(for: error, isLogin: true))
                    }
                }
            }
            
        } else {
            guard
                let nameField = nameInputView?.subviews.compactMap({ $0 as? UITextField }).first,
                let surnameField = surnameInputView?.subviews.compactMap({ $0 as? UITextField }).first,
                let confirmField = confirmPasswordInputView?.subviews.compactMap({ $0 as? UITextField }).first
            else { return }
            
            let name = nameField.text ?? ""
            let surname = surnameField.text ?? ""
            let confirm = confirmField.text ?? ""
            
            guard !name.isEmpty, !surname.isEmpty, !email.isEmpty, !password.isEmpty, !confirm.isEmpty else {
                alertDialog(message: "emptyFields".translated)
                return
            }
            
            guard password == confirm else {
                alertDialog(message: "passwordMismatch".translated)
                return
            }
            
            viewModel.register(name: name, surname: surname, email: email, password: password) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        FirebaseUserPreferencesManager.shared.prefetchAllData {
                            self?.onSuccess?()
                        }
                    case .failure(let error):
                        guard let self else { return }
                        self.alertDialog(message: self.viewModel.message(for: error, isLogin: false))
                    }
                }
            }
        }
    }
}

//MARK: - Forgot Password
private extension AuthenticationVC {
    @objc func didTapForgotPassword() {
        guard isLoginSelected else { return }
        let forgotPasswordViewModel = viewModel.createForgotPasswordVM()
        var prefill: String? = nil
        if let emailTextField = emailInputView.subviews.compactMap({ $0 as? UITextField }).first {
            prefill = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
        let forgotPasswordViewController = ForgotPasswordVC(viewModel: forgotPasswordViewModel, prefilledEmail: prefill)
        navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }
}

// MARK: - Public Helpers
extension AuthenticationVC {
    func resetToLogin() {
        view.endEditing(true)
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        if !isLoginSelected {
            isLoginSelected = true
            animateSegment(toLogin: true)
        }
        updateForm()
        view.layoutIfNeeded()
        let topInset = scrollView.adjustedContentInset.top
        scrollView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    }
}

// MARK: - Constraints
private extension AuthenticationVC {
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
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
        }
        
        headerSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(headerTitleLabel)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(headerSubtitleLabel.snp.bottom).offset(40)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        segmentContainer.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(30)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(50)
        }
        
        selectedSegment.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalToSuperview().offset(4)
            make.width.equalTo(segmentContainer).multipliedBy(0.5).offset(-12)
        }
        
        loginTabButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        registerTabButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        forgotPasswordButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-25)
        }
        
        authButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(56)
            make.bottom.lessThanOrEqualTo(containerView.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }
    
    func setupFormConstraints() {
        if isLoginSelected {
            // MARK: - Login Constraints
            emailInputView.snp.makeConstraints { make in
                make.top.equalTo(segmentContainer.snp.bottom).offset(30)
                make.leading.trailing.equalToSuperview().inset(25)
                make.height.equalTo(70)
            }
            
            passwordInputView.snp.makeConstraints { make in
                make.top.equalTo(emailInputView.snp.bottom).offset(25)
                make.leading.trailing.equalToSuperview().inset(25)
                make.height.equalTo(70)
            }
            
            forgotPasswordButton.snp.remakeConstraints { make in
                make.top.equalTo(passwordInputView.snp.bottom).offset(10)
                make.trailing.equalToSuperview().offset(-25)
            }
            
            authButton.snp.remakeConstraints { make in
                make.top.equalTo(passwordInputView.snp.bottom).offset(70)
                make.leading.trailing.equalToSuperview().inset(25)
                make.height.equalTo(56)
            }
            
        } else {
            // MARK: - Register Constraints
            guard
                let nameView = nameInputView,
                let surnameView = surnameInputView,
                let confirmView = confirmPasswordInputView
            else { return }
            
            nameView.snp.makeConstraints { make in
                make.top.equalTo(segmentContainer.snp.bottom).offset(30)
                make.leading.trailing.equalToSuperview().inset(25)
                make.height.equalTo(70)
            }
            
            surnameView.snp.makeConstraints { make in
                make.top.equalTo(nameView.snp.bottom).offset(25)
                make.leading.trailing.equalToSuperview().inset(25)
                make.height.equalTo(70)
            }
            
            emailInputView.snp.makeConstraints { make in
                make.top.equalTo(surnameView.snp.bottom).offset(25)
                make.leading.trailing.equalToSuperview().inset(25)
                make.height.equalTo(70)
            }
            
            passwordInputView.snp.makeConstraints { make in
                make.top.equalTo(emailInputView.snp.bottom).offset(25)
                make.leading.trailing.equalToSuperview().inset(25)
                make.height.equalTo(70)
            }
            
            confirmView.snp.makeConstraints { make in
                make.top.equalTo(passwordInputView.snp.bottom).offset(25)
                make.leading.trailing.equalToSuperview().inset(25)
                make.height.equalTo(70)
            }
            
            authButton.snp.remakeConstraints { make in
                make.top.equalTo(confirmView.snp.bottom).offset(40)
                make.leading.trailing.equalToSuperview().inset(25)
                make.height.equalTo(56)
            }
        }
    }
}
