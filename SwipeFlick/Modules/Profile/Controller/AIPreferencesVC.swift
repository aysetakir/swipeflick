import UIKit
import SnapKit

final class AIPreferencesVC: UIViewController {
    private let viewModel: AIPreferencesVMProtocol

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "aiPreferencesTitle".translated
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "aiPreferencesSubtitle".translated
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.75)
        label.numberOfLines = 0
        return label
    }()

    private let textView: UITextView = {
        let editor = UITextView()
        editor.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        editor.textColor = .white
        editor.font = .systemFont(ofSize: 16, weight: .regular)
        editor.layer.cornerRadius = 12
        editor.layer.borderWidth = 1
        editor.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        editor.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        editor.keyboardAppearance = .dark
        return editor
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "aiPreferencesPlaceholder".translated
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.4)
        return label
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "save".translated

            var att = AttributeContainer()
            att.font = .systemFont(ofSize: 17, weight: .semibold)
            config.attributedTitle = AttributedString("save".translated, attributes: att)
            
            let bg = UIColor.buttonPrimary
            config.baseBackgroundColor = bg
            config.baseForegroundColor = .white
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
            button.configuration = config
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
        } else {
            button.setTitle("save".translated, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            button.backgroundColor = .buttonPrimary
            button.layer.cornerRadius = 12
            button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
        }
        return button
    }()

    init(viewModel: AIPreferencesVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        title = "aiPreferences".translated
        setupUI()
        setupConstraints()
        bind()
        viewModel.load()
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        viewModel.save(text: textView.text ?? "")
    }
}

extension AIPreferencesVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        viewModel.updateDraft(text: textView.text)
    }
}

private extension AIPreferencesVC {
    func setupUI() {
        view.addSubview(headerLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
        view.addSubview(saveButton)

        textView.delegate = self
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    func setupConstraints() {
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(6)
            make.leading.trailing.equalTo(headerLabel)
        }
        textView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(headerLabel)
            make.height.equalTo(180)
        }
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.top).offset(14)
            make.leading.equalTo(textView.snp.leading).offset(18)
            make.trailing.equalTo(textView.snp.trailing).offset(-18)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(headerLabel)
        }
    }

    func bind() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            self.textView.text = state.text
            self.placeholderLabel.isHidden = !state.text.isEmpty
            self.saveButton.isEnabled = state.isSaveEnabled && !state.isSaving
            self.saveButton.alpha = (state.isSaveEnabled && !state.isSaving) ? 1 : 0.6
        }
        viewModel.onError = { [weak self] message in
            self?.alertDialog(title: "error".translated, message: message)
        }
        viewModel.onSaved = { [weak self] in
            self?.alertDialog(title: "success".translated, message: "aiPreferencesSaved".translated)
        }
    }
}
