import UIKit
import SnapKit

final class MovieDetailView: UIView {
    private var viewModel: MovieDetailVMProtocol
    
    var onClose: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private var isFlipped = false
    private var movie: Movie?
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    // Front
    private let frontView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let detailButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.title = "viewDetail".translated
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        button.configuration = config
        return button
    }()
    
    private let frontCloseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.tintColor = .secondGradient
        return button
    }()
    
    // Back
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 20
        view.isHidden = true
        return view
    }()
    
    private let contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundPrimary
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .heavy)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let genresScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let genresStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    private let releaseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let runtimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let dotLabel: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.font = .systemFont(ofSize: 14 , weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemYellow
        label.textAlignment = .right
        return label
    }()
    
    private let overviewScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bouncesVertically = true
        scrollView.bouncesHorizontally = false
        return scrollView
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let imdbButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "goToIMDB".translated
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        button.configuration = config
        
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.title = "viewPoster".translated
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        button.configuration = config
        return button
    }()
    
    private let backCloseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.tintColor = .secondGradient
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    //MARK: - Init
    init(viewModel: MovieDetailVMProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
        
        loadingIndicator.startAnimating()
        Task {
            await viewModel.fetchDetail()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.detailButton.applyGradientBackground(
                colors: [.firstGradient, .secondGradient],
                cornerRadius: self.detailButton.bounds.height / 2
            )
            self.backButton.applyGradientBackground(
                colors: [.firstGradient, .secondGradient],
                cornerRadius: self.detailButton.bounds.height / 2
            )
            self.imdbButton.applyGradientBorder(
                colors: [.firstGradient, .secondGradient],
                cornerRadius: self.imdbButton.bounds.height / 2
            )
        }
    }
    
    // MARK: - Configure
    func configure(viewModel: MovieDetailVMProtocol) {
        self.viewModel = viewModel
        setupBindings()
        loadingIndicator.startAnimating()
        
        Task {
            await viewModel.fetchDetail()
        }
    }
    
    //MARK: - Bindings
    private func setupBindings() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }
        
        viewModel.onMovieDetailUpdated = { [weak self] in
            guard let self = self, let detail = self.viewModel.movie else { return }
            
            posterImageView.setImage(with: detail.posterURL)
            titleLabel.text = detail.title
            overviewLabel.text = detail.overview
            let yearText = String(detail.releaseDate.prefix(4))
            releaseLabel.text = yearText
            runtimeLabel.text = viewModel.formatRuntime(detail.runtime)
            genresStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            detail.genres.forEach { genre in
                let label = self.makeGenreLabel(with: genre.name)
                self.genresStackView.addArrangedSubview(label)
            }
            ratingLabel.text = String(format: "⭐️ %.1f", detail.voteAverage)
        }
        
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            onError?(message)
        }
    }
    
    // MARK: - Actions
    @objc func dismissTapped() {
        onClose?()
    }
    
    @objc func flipToBack() {
        guard !isFlipped else { return }
        isFlipped = true
        UIView.transition(from: frontView, to: backView, duration: 0.6, options: [.transitionFlipFromRight, .showHideTransitionViews])
    }
    
    @objc func flipToFront() {
        guard isFlipped else { return }
        isFlipped = false
        UIView.transition(from: backView, to: frontView, duration: 0.6, options: [.transitionFlipFromLeft, .showHideTransitionViews])
    }
    
    @objc private func openIMDB() {
        guard let imdbURLString = viewModel.movie?.externalIDs.imdbURL,
              let url = URL(string: imdbURLString) else {
            onError?("imdbError".translated)
            return
        }
        WebViewPresenter.present(from: self, url: url, title: "imdb".translated)
    }
}

// MARK: - UI Setup/Constraints
private extension MovieDetailView {
    func setupUI() {
        addSubview(blurView)
        addSubview(containerView)
        
        containerView.addSubview(frontView)
        containerView.addSubview(backView)
        
        //Front
        frontView.addSubview(imageContainerView)
        imageContainerView.addSubview(posterImageView)
        frontView.addSubview(detailButton)
        frontView.addSubview(frontCloseButton)
        
        //Back
        backView.addSubview(contentContainerView)
        contentContainerView.addSubview(titleLabel)
        contentContainerView.addSubview(infoStackView)
        contentContainerView.addSubview(ratingLabel)
        contentContainerView.addSubview(genresScrollView)
        contentContainerView.addSubview(overviewScrollView)
        contentContainerView.addSubview(imdbButton)
        contentContainerView.addSubview(loadingIndicator)
        
        genresScrollView.addSubview(genresStackView)
        infoStackView.addArrangedSubview(releaseLabel)
        infoStackView.addArrangedSubview(dotLabel)
        infoStackView.addArrangedSubview(runtimeLabel)
        overviewScrollView.addSubview(overviewLabel)
        
        backView.addSubview(backButton)
        backView.addSubview(backCloseButton)
    }
    
    func setupConstraints() {
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        // Front
        frontView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageContainerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(detailButton.snp.top).offset(-16)
        }
        
        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        detailButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        frontCloseButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(30)
        }
        
        // Back
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentContainerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(backButton.snp.top).offset(-16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(60)
            make.left.right.equalToSuperview().inset(20)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalTo(titleLabel)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.centerY.equalTo(infoStackView)
            make.right.equalToSuperview().inset(20)
        }
        
        genresScrollView.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        genresStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalToSuperview()
        }
        
        overviewScrollView.snp.makeConstraints { make in
            make.top.equalTo(genresScrollView.snp.bottom).offset(24)
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(imdbButton.snp.top).offset(-20)
        }
        
        overviewLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        imdbButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(40)
        }
        
        backButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        backCloseButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(30)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupActions() {
        blurView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(dismissTapped)
            )
        )
        
        detailButton.addTarget(
            self,
            action: #selector(flipToBack),
            for: .touchUpInside
        )
        
        backButton.addTarget(
            self,
            action: #selector(flipToFront),
            for: .touchUpInside
        )
        
        frontCloseButton.addTarget(
            self,
            action: #selector(dismissTapped),
            for: .touchUpInside
        )
        
        backCloseButton.addTarget(
            self,
            action: #selector(dismissTapped),
            for: .touchUpInside
        )
        
        imdbButton.addTarget(
            self,
            action: #selector(openIMDB),
            for: .touchUpInside
        )
    }
    
    private func makeGenreLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = "  \(text)  "
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        label.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.snp.makeConstraints { make in
            make.height.equalTo(26)
            make.width.greaterThanOrEqualTo(label.intrinsicContentSize.width + 20)
        }
        return label
    }
}
