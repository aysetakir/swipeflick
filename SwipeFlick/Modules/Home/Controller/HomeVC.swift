import SnapKit
import UIKit

final class HomeVC: UIViewController {
    private var viewModel: HomeVMProtocol
    var onSuccess: (() -> Void)?
    var _test: Bool = false
    
    private var emptyView: EmptyView?
    private var isRecommendationShown = false
    
    private let cardTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.textAlignment = .left
        return label
    }()
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let actionButtonsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var dislikeButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        button.configuration = config
        
        let xLabel = UILabel()
        xLabel.text = "✕"
        xLabel.font = .systemFont(ofSize: 32, weight: .bold)
        xLabel.textColor = .white
        xLabel.textAlignment = .center
        button.addSubview(xLabel)
        xLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        button.addTarget(
            self,
            action: #selector(dislikeButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var haventWatchedButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        button.configuration = config
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        
        let eyeLabel = UILabel()
        eyeLabel.text = "👁"
        eyeLabel.font = .systemFont(ofSize: 20)
        
        let textLabel = UILabel()
        textLabel.text = "haventwatched".translated
        textLabel.font = .systemFont(ofSize: 16, weight: .medium)
        textLabel.textColor = .white
        
        stackView.addArrangedSubview(eyeLabel)
        stackView.addArrangedSubview(textLabel)
        
        button.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        button.addTarget(
            self,
            action: #selector(haventWatchedButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        button.configuration = config
        
        let heartImageView = UIImageView()
        let heartConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        heartImageView.image = UIImage(systemName: "heart.fill", withConfiguration: heartConfig)
        heartImageView.tintColor = .white
        heartImageView.contentMode = .scaleAspectFit
        
        button.addSubview(heartImageView)
        heartImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        button.addTarget(
            self,
            action: #selector(likeButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var restartButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        button.configuration = config
        button.isHidden = true
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        
        let textLabel = UILabel()
        textLabel.text = "startAgain".translated
        textLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        textLabel.textColor = .white
        
        stackView.addArrangedSubview(textLabel)
        
        button.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        button.addTarget(
            self,
            action: #selector(restartButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private var currentCard: SwipeCardView?
    private var loadingView: UIView?
    
    init(viewModel: HomeVMProtocol, onSuccess: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onSuccess = onSuccess
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        
        setupUI()
        setupBindings()
        fetchMovies()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        haventWatchedButton.applyGradientBorder(
            colors: [.firstGradient, .secondGradient],
            cornerRadius: haventWatchedButton.bounds.height / 2
        )
        dislikeButton.applyGradientBackground(
            colors: [.firstGradient, .secondGradient],
            cornerRadius: 35
        )
        likeButton.applyGradientBackground(
            colors: [.firstGradient, .secondGradient],
            cornerRadius: 35
        )
        restartButton.applyGradientBackground(
            colors: [.firstGradient, .secondGradient],
            cornerRadius: restartButton.bounds.height / 2
        )
    }
    
    private func loadNextCard() {
        Task {
            await setupCard()
        }
    }
    
    //MARK: - Fetch Movies
    private func fetchMovies() {
        Task {
            await viewModel.fetchMovies()
            await self.setupCard()
        }
    }
    
    //MARK: - Setup Bindings
    private func setupBindings() {
        viewModel.onMoviesUpdated = { [weak self] in
            guard let self else { return }
            print(self.viewModel.movies.count)
            self.hideEmptyView()
        }
        
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            self.alertDialog(title: "error".translated, message: message)
            self.showEmptyView()
        }
    }
}

//MARK: - Button Actions
private extension HomeVC {
    @objc func dislikeButtonTapped() {
        print("Dislike button tapped")
        UIView.animate(withDuration: 0.1, animations: {
            self.dislikeButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.dislikeButton.transform = .identity
            } completion: { _ in
                self.currentCard?.simulateSwipe(.left)
            }
        })
    }
    
    @objc func haventWatchedButtonTapped() {
        print("Haven't Watched buttn")
        
        if !isRecommendationShown {
            loadNextCard()
        }
    }
    
    @objc func likeButtonTapped() {
        print("Like button tapped")
        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.likeButton.transform = .identity
            } completion: { _ in
                self.currentCard?.simulateSwipe(.right)
            }
        })
    }
    
    @objc func restartButtonTapped() {
        restartApp()
    }
    
    @objc func flipCard(_ sender: UITapGestureRecognizer) {
        guard let card = sender.view as? SwipeCardView else { return }
        card.isFlipped ? card.flipToFront() : card.flipToBack()
    }
}

// MARK: - UI State Management
private extension HomeVC {
    func showRestartButton() {
        isRecommendationShown = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dislikeButton.alpha = 0
            self.haventWatchedButton.alpha = 0
            self.likeButton.alpha = 0
        }) { _ in
            self.dislikeButton.isHidden = true
            self.haventWatchedButton.isHidden = true
            self.likeButton.isHidden = true
            self.restartButton.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.restartButton.alpha = 1
            }
        }
    }
    
    func hideRestartButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.restartButton.alpha = 0
        }) { _ in
            self.restartButton.isHidden = true
            
            self.dislikeButton.isHidden = false
            self.haventWatchedButton.isHidden = false
            self.likeButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.dislikeButton.alpha = 1
                self.haventWatchedButton.alpha = 1
                self.likeButton.alpha = 1
            }
        }
    }
    
    func restartApp() {
        viewModel.likedMovies.removeAll()
        viewModel.dislikedMovies.removeAll()
        viewModel.swipeCount = 0
        isRecommendationShown = false
        
        currentCard?.removeFromSuperview()
        currentCard = nil
        
        hideRestartButton()
        
        fetchMovies()
    }
}

// MARK: - Loading View
private extension HomeVC {
    func showLoadingView() {
        loadingView?.removeFromSuperview()
        
        let container = UIView()
        container.backgroundColor = UIColor.darkGray
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.secondGradient.cgColor,
            UIColor.firstGradient.cgColor,
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        container.layer.addSublayer(gradientLayer)
        
        let loadingLabel = UILabel()
        loadingLabel.text = "homeLoadingLabel".translated
        loadingLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        loadingLabel.textColor = .white
        loadingLabel.textAlignment = .center
        loadingLabel.numberOfLines = 0
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, loadingLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        
        container.addSubview(stackView)
        cardContainerView.addSubview(container)
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        container.layoutIfNeeded()
        gradientLayer.frame = container.bounds
        
        container.layer.setValue(gradientLayer, forKey: "attachedGradient")
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
        
        loadingView = container
    }
    
    func hideLoadingView() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
}

// MARK: - EmptyView
private extension HomeVC {
    func showEmptyView() {
        emptyView?.removeFromSuperview()
        let empty = EmptyView(retryAction: { [weak self] in
            guard let self = self else { return }
            Task {
                await self.viewModel.fetchMovies()
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

// MARK: - Setup Card
private extension HomeVC {
    func setupCard() async {
        if _test {
            return
        } else {
            _test = true
        }
        
        defer { _test = false }
        
        currentCard?.removeFromSuperview()
        currentCard = nil
        
        var _movie = await viewModel.getNextMovie()
        
        if _movie == nil
            || self.viewModel.swipeCount >= 10
            && !self.viewModel.likedMovies.isEmpty
            && !self.viewModel.dislikedMovies.isEmpty
        {
            showLoadingView()
            
            let service = GeminiRecommendationService()
            let likedTitles = self.viewModel.likedMovies.map(\.title)
            let dislikedTitles = viewModel.dislikedMovies.map(\.title)
            let res = try? await service.recommend(
                using: GeminiRecommendationRequest(
                    likedTitles: likedTitles,
                    dislikedTitles: dislikedTitles
                )
            )
            
            print("ai answer: \(res?.title ?? "none")")
            
            if let title = res?.title {
                let recommendedMovie = try? await self.viewModel.getMovieByName(name: title)
                _movie = recommendedMovie
                
                if let aiMovie = recommendedMovie {
                    isRecommendationShown = true
                    self.viewModel.saveAIPickMovie(aiMovie)
                    showRestartButton()
                }
            }
            
            hideLoadingView()
        }
        
        guard let movie = _movie else { return }
        
        let card = SwipeCardView()
        cardContainerView.addSubview(card)
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        card.onSwipeLeft = { [weak self] in
            guard let self = self else { return }
            print("Swiped LEFT!")
            self.viewModel.dislikedMovies.append(movie)
            self.viewModel.saveDislikedMovie(movie)
            
            if !self.isRecommendationShown {
                self.loadNextCard()
            }
        }
        
        card.onSwipeRight = { [weak self] in
            guard let self = self else { return }
            self.viewModel.likedMovies.append(movie)
            self.viewModel.saveLikedMovie(movie)
            print("right")
            
            if !self.isRecommendationShown {
                self.loadNextCard()
            }
        }
        
        let genreText = viewModel.genres
            .filter({ movie.genreIDs.contains($0.id) })
            .map({ $0.name }).joined(separator: ", ")
        
        card.configure(
            title: movie.title,
            genre: genreText,
            posterURL: movie.posterURL,
            _isStatic: isRecommendationShown
        )
        
        self.viewModel.swipeCount += 1
        
        currentCard = card
        
        
        if self.isRecommendationShown {
            self.cardTitleLabel.text = "secondCardTitle".translated
        } else {
            self.cardTitleLabel.text = "firstCardTitle".translated
        }
        UIView.animate(withDuration: 0.3) {
            self.cardTitleLabel.alpha = 1
        }
        
        
        if isRecommendationShown {
            if let detail = await viewModel.fetchDetail(for: movie.id) {
                let runtimeString =  viewModel.formatRuntime(detail.runtime)
                let releaseString =  viewModel.formatReleaseDate(detail.releaseDate)
                let ratingString = String(format: "⭐️ %.1f", detail.voteAverage)
                let genreNames = detail.genres.map { $0.name }
                guard let imdbString = detail.externalIDs.imdbURL else { return }
                
                card.configureBack(
                    title: detail.title,
                    release: releaseString,
                    runtime: runtimeString,
                    rating: ratingString,
                    genres: genreNames,
                    overview: detail.overview,
                    imdbURL: URL(string: imdbString)
                )
            }
            card.onIMDBTap = { [weak self] url in
                guard let self = self else { return }
                WebViewPresenter.present(from: self, url: url, title: "imdb".translated)
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(flipCard))
            card.addGestureRecognizer(tap)
        }
    }
}

// MARK: - Setup UI
private extension HomeVC {
    func setupUI() {
        view.addSubview(actionButtonsContainer)
        actionButtonsContainer.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        view.addSubview(cardContainerView)
        cardContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(actionButtonsContainer.snp.top).offset(-20)
        }
        
        view.addSubview(cardTitleLabel)
        cardTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(cardContainerView.snp.top).offset(-10)
            make.leading.equalTo(cardContainerView.snp.leading)
        }
        
        actionButtonsContainer.addSubview(dislikeButton)
        actionButtonsContainer.addSubview(haventWatchedButton)
        actionButtonsContainer.addSubview(likeButton)
        actionButtonsContainer.addSubview(restartButton)
        
        dislikeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(70)
        }
        
        haventWatchedButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(60)
            make.width.greaterThanOrEqualTo(200)
        }
        
        likeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(70)
        }
        
        restartButton.snp.makeConstraints { make in
            make.leading.equalTo(cardContainerView)
            make.trailing.equalTo(cardContainerView)
            make.centerY.equalToSuperview()
            make.height.equalTo(60)
        }
    }
}
