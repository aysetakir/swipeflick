import UIKit
import SnapKit

final class RandomVC: UIViewController {
    
    private var viewModel: RandomVMProtocol
    private var moodButtons: [MoodButton] = []
    
    // MARK: - UI Components
    private var emptyView: EmptyView?
    private let contentView = UIView()
    
    private let headerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "randomTitle".translated
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "randomSubtitle".translated
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let moodPromptLabel: UILabel = {
        let label = UILabel()
        label.text = "moodLabel".translated
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    private let moodStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundPrimary
        view.isHidden = true
        return view
    }()
    
    private let loadingCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondGradient
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let cardIconImageView: UIImageView = {
        let imageView = UIImageView()
        
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        imageView.image = UIImage(systemName: "shuffle", withConfiguration: config)
        
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "randomLoadingLabel".translated
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let resultContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private var movieCardView: MovieCardView?
    
    private let tryAgainButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 12, leading: 16, bottom: 12, trailing: 16
        )
        
        var titleAttr = AttributedString("tryAgain".translated)
        titleAttr.font = .systemFont(ofSize: 15, weight: .semibold)
        config.attributedTitle = titleAttr
        
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 14
        return button
    }()
    
    private let chooseAnotherButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 12, leading: 16, bottom: 12, trailing: 16
        )
        
        var titleAttr = AttributedString("chooseAnother".translated)
        titleAttr.font = .systemFont(ofSize: 15, weight: .semibold)
        config.attributedTitle = titleAttr
        
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 14
        return button
    }()
    
    // MARK: - Initialization
    init(viewModel: RandomVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        setupBindings()
        setupMoodButtons()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async {
            self.tryAgainButton.applyGradientBorder(
                colors: [.firstGradient, .secondGradient],
                cornerRadius: self.tryAgainButton.bounds.height / 2
            )
            self.chooseAnotherButton.applyGradientBackground(
                colors: [.firstGradient, .secondGradient],
                cornerRadius: self.chooseAnotherButton.bounds.height / 2
            )
        }
    }
}

// MARK: - Bindings
private extension RandomVC {
    func setupBindings() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                showLoading()
            }
        }
        
        viewModel.onMovieFound = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showResult()
            }
        }
        
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            hideLoading()
            alertDialog(title: "error".translated, message: message)
            showEmptyView()
        }
    }
}

// MARK: - Actions
private extension RandomVC {
    func setupActions() {
        tryAgainButton.addTarget(
            self,
            action: #selector(tryAgainTapped),
            for: .touchUpInside
        )
        
        chooseAnotherButton.addTarget(
            self,
            action: #selector(chooseAnotherTapped),
            for: .touchUpInside
        )
    }
    
    @objc private func tryAgainTapped() {
        resultContainerView.isHidden = true
        movieCardView?.removeFromSuperview()
        movieCardView = nil
        
        showLoading()
        
        Task {
            await viewModel.fetchRandomMovie()
        }
    }
    
    @objc private func chooseAnotherTapped() {
        viewModel.reset()
        hideResult()
    }
    
    @objc private func movieCardTapped() {
        guard let movie = viewModel.randomMovie else { return }
        
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.movieCardView?.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.movieCardView?.transform = .identity
            } completion: { _ in
                self.showMovieDetailPopup(for: movie)
            }
        })
    }
}

// MARK: - Mood Buttons
private extension RandomVC {
    func setupMoodButtons() {
        let moods: [[Mood]] = [
            [.excited, .romantic],
            [.chill, .happy],
            [.sad, .thoughtful]
        ]
        
        moods.forEach { row in
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            rowStack.distribution = .fillEqually
            
            row.forEach { mood in
                let button = MoodButton(mood: mood)
                button.addTarget(self, action: #selector(moodTapped(_:)), for: .touchUpInside)
                button.tag = mood.intValue
                rowStack.addArrangedSubview(button)
                moodButtons.append(button)
            }
            
            moodStackView.addArrangedSubview(rowStack)
        }
    }
    
    @objc func moodTapped(_ sender: UIButton) {
        let mood = Mood.allCases[sender.tag]
        viewModel.selectMood(mood)
    }
}

// MARK: - UI States
private extension RandomVC {
    func showLoading() {
        moodPromptLabel.isHidden = true
        moodStackView.isHidden = true
        loadingView.isHidden = false
        spinCard()
    }
    
    func hideLoading() {
        loadingCardView.layer.removeAllAnimations()
        loadingCardView.layer.transform = CATransform3DIdentity
        
        loadingView.isHidden = true
        moodPromptLabel.isHidden = false
        moodStackView.isHidden = false
    }
    
    func spinCard() {
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 500.0
        loadingCardView.layer.transform = perspective
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 0.5
        rotation.repeatCount = 6
        rotation.delegate = self
        
        loadingCardView.layer.add(rotation, forKey: "spinAnimation")
    }
    
    func showResult() {
        guard let movie = viewModel.randomMovie,
              let mood = viewModel.selectedMood else { return }
        
        loadingCardView.layer.removeAllAnimations()
        loadingView.isHidden = true
        
        headerView.isHidden = true
        resultContainerView.isHidden = false
        
        let buttonStack = resultContainerView.subviews.first(where: { $0 is UIStackView }) as? UIStackView
        
        let cardView = MovieCardView()
        cardView.configure(with: movie, mood: mood)
        
        movieCardView?.removeFromSuperview()
        movieCardView = cardView
        
        resultContainerView.insertSubview(cardView, at: 0)
        
        let cardHeight = UIScreen.main.bounds.height * 0.65
        
        cardView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(cardHeight)
        }
        
        buttonStack?.snp.remakeConstraints {
            $0.top.equalTo(cardView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
            $0.bottom.lessThanOrEqualToSuperview()
        }
        cardView.alpha = 1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(movieCardTapped))
        cardView.addGestureRecognizer(tapGesture)
        cardView.isUserInteractionEnabled = true
    }
    
    func hideResult() {
        UIView.animate(withDuration: 0.3) {
            self.resultContainerView.alpha = 0
        } completion: { _ in
            self.resultContainerView.isHidden = true
            self.resultContainerView.alpha = 1
            self.movieCardView?.removeFromSuperview()
            self.movieCardView = nil
            self.moodPromptLabel.isHidden = false
            self.moodStackView.isHidden = false
            self.headerView.isHidden = false
        }
    }
}

//MARK: - Empty View
private extension RandomVC {
    func showEmptyView() {
        emptyView?.removeFromSuperview()
        
        let empty = EmptyView(retryAction: { [weak self] in
            guard let self else { return }
            hideEmptyView()
            showLoading()
            
            Task {
                await self.viewModel.fetchRandomMovie()
            }
        })
        
        view.addSubview(empty)
        empty.snp.makeConstraints { $0.edges.equalToSuperview() }
        emptyView = empty
    }
    
    func hideEmptyView() {
        emptyView?.removeFromSuperview()
        emptyView = nil
    }
}

//MARK: - Show Movie Detail Popup
private extension RandomVC {
    func showMovieDetailPopup(for movie: Movie) {
        let movieDetailVM = MovieDetailVM(movieId: movie.id)
        let popup = MovieDetailView(viewModel: movieDetailVM)
        
        popup.onClose = { [weak popup] in
            UIView.animate(withDuration: 0.25, animations: {
                popup?.alpha = 0
            }, completion: { _ in
                popup?.removeFromSuperview()
            })
        }
        
        popup.onError = { [weak self] message in
            guard let self else { return }
            alertDialog(title: "error".translated, message: message)
        }
        
        popup.frame = view.bounds
        popup.alpha = 0
        popup.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        view.addSubview(popup)
        
        UIView.animate(withDuration: 0.3) {
            popup.alpha = 1
            popup.transform = .identity
        }
    }
}

// MARK: - CAAnimationDelegate
extension RandomVC: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else { return }
    }
}

// MARK: - Setup UI
private extension RandomVC {
    func setupUI() {
        view.backgroundColor = .backgroundPrimary
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        contentView.addSubview(moodPromptLabel)
        contentView.addSubview(moodStackView)
        
        contentView.addSubview(loadingView)
        loadingView.addSubview(loadingCardView)
        loadingCardView.addSubview(cardIconImageView)
        loadingView.addSubview(loadingLabel)
        
        contentView.addSubview(resultContainerView)
        
        let buttonStack = UIStackView(arrangedSubviews: [tryAgainButton, chooseAnotherButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        resultContainerView.addSubview(buttonStack)
        
        setupConstraints(buttonStack: buttonStack)
    }
    
    func setupConstraints(buttonStack: UIStackView) {
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        moodStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
                
        moodPromptLabel.snp.makeConstraints {
            $0.bottom.equalTo(moodStackView.snp.top).offset(-32)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        loadingView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(60)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        loadingCardView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(60)
            $0.height.equalTo(UIScreen.main.bounds.height * 0.5)
        }
        
        cardIconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        loadingLabel.snp.makeConstraints {
            $0.top.equalTo(loadingCardView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        resultContainerView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        buttonStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
    }
}
