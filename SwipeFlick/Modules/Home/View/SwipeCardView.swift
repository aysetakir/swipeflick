import UIKit
import SnapKit

final class SwipeCardView: UIView {
    
    // MARK: - Properties
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var originalCenter: CGPoint = .zero
    
    var onSwipeLeft: (() -> Void)?
    var onSwipeRight: (() -> Void)?
    var isStatic: Bool = false
    var isFlipped = false
    var imdbURL: URL?
    var onIMDBTap: ((URL) -> Void)?
    
    private let swipeThreshold: CGFloat = 0.3
    
    // MARK: - Front UI
    let imageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let blurEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        view.alpha = 0
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondGradient
        return imageView
    }()
    
    private let gradientContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.95).cgColor
        ]
        layer.locations = [0.4, 1.0]
        return layer
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 18)
        label.textColor = .lightGray
        return label
    }()
    
    private let likeOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.alpha = 0
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "heart.fill")
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        return view
    }()
    
    private let dislikeOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.alpha = 0
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "xmark")
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        return view
    }()
    
    // MARK: - Back UI
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let titleBackLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .heavy)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        return stackView
    }()
    
    private let releaseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let dotLabel: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    private let runtimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
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
    
    private let genresScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let genresStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let overviewScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = false
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientContainer.bounds
        DispatchQueue.main.async {
            self.imdbButton.applyGradientBorder(
                colors: [.firstGradient, .secondGradient],
                cornerRadius: self.imdbButton.bounds.height / 2
            )
        }
    }
    
    private func setupGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Gesture Handling
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        if isStatic {
            return
        }
        
        let translation = gesture.translation(in: superview)
        
        switch gesture.state {
        case .began:
            originalCenter = center
            
        case .changed:
            center = CGPoint(x: originalCenter.x + translation.x,
                             y: originalCenter.y)
            
            let rotationAngle = translation.x / (superview?.bounds.width ?? 1) * 0.4
            transform = CGAffineTransform(rotationAngle: rotationAngle)
            
            if translation.x > 0 {
                likeOverlay.alpha = min(abs(translation.x) / 100, 0.8)
                dislikeOverlay.alpha = 0
            } else {
                dislikeOverlay.alpha = min(abs(translation.x) / 100, 0.8)
                likeOverlay.alpha = 0
            }
            
        case .ended:
            handleSwipeEnd(translation: translation)
            
        default:
            break
        }
    }
    
    private func handleSwipeEnd(translation: CGPoint) {
        guard let superviewWidth = superview?.bounds.width else { return }
        
        let threshold = superviewWidth * swipeThreshold
        
        if translation.x > threshold {
            swipeRight()
        } else if translation.x < -threshold {
            swipeLeft()
        } else {
            resetPosition()
        }
    }
    
    // MARK: - Swipe Actions
    func swipeRight() {
        simulateSwipe(.right)
    }

    func swipeLeft() {
        simulateSwipe(.left)
    }
    
    private func resetPosition() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.center = self.originalCenter
            self.transform = .identity
            self.likeOverlay.alpha = 0
            self.dislikeOverlay.alpha = 0
        }
    }
    
    func flipToBack() {
        guard !isFlipped else { return }
        isFlipped = true
        [gradientContainer, titleLabel, genreLabel].forEach { $0.isHidden = true }
        
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut]) {
            self.blurEffectView.alpha = 1
        } completion: { _ in
            self.backView.isHidden = false
            self.backView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseInOut]) {
                self.backView.alpha = 1
            }
        }
    }
    
    @objc func flipToFront() {
        guard isFlipped else { return }
        isFlipped = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.backView.alpha = 0
        } completion: { _ in
            self.backView.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut]) {
                self.blurEffectView.alpha = 0
            } completion: { _ in
                [self.gradientContainer, self.titleLabel, self.genreLabel].forEach { $0.isHidden = false }
            }
        }
    }
    
    func configure(title: String, genre: String, posterURL: URL?, _isStatic: Bool = false) {
        titleLabel.text = title
        genreLabel.text = genre
        isStatic = _isStatic
        panGestureRecognizer.isEnabled = !_isStatic
        
        if let url = posterURL {
            posterImageView.setImage(with: url)
        } else {
            posterImageView.image = UIImage(named: "noPoster")
        }
    }
    
    func configureBack(title: String, release: String?, runtime: String?, rating: String?, genres: [String], overview: String, imdbURL: URL?) {
        titleBackLabel.text = title
        releaseLabel.text = release ?? ""
        runtimeLabel.text = runtime ?? ""
        overviewLabel.text = overview
        ratingLabel.text = rating
        self.imdbURL = imdbURL
        
        genresStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for genre in genres {
            let label = UILabel()
            label.text = "  \(genre)  "
            label.font = .systemFont(ofSize: 13, weight: .semibold)
            label.textColor = .white
            label.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            label.layer.cornerRadius = 12
            label.layer.masksToBounds = true
            genresStackView.addArrangedSubview(label)
        }
        
        imdbButton.addTarget(self, action: #selector(openIMDB), for: .touchUpInside)
    }
    
    @objc private func openIMDB() {
        guard let url = imdbURL else { return }
        onIMDBTap?(url)
    }
}

// MARK: - Swipe Animation
extension SwipeCardView {
    enum SwipeDirection {
        case left
        case right
    }
    
    func simulateSwipe(_ direction: SwipeDirection) {
        guard let superview = superview else { return }
        
        let duration: TimeInterval = 0.35
        let distance: CGFloat = superview.bounds.width * 1.5
        
        let rotationAngle: CGFloat
        let sign: CGFloat
        
        switch direction {
        case .right:
            rotationAngle = .pi / 10
            sign = 1
        case .left:
            rotationAngle = -.pi / 10
            sign = -1
        }
        
        likeOverlay.alpha = 0
        dislikeOverlay.alpha = 0
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: [.calculationModeLinear],
                                animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                switch direction {
                case .right:
                    self.likeOverlay.alpha = 0.8
                    self.dislikeOverlay.alpha = 0
                case .left:
                    self.dislikeOverlay.alpha = 0.8
                    self.likeOverlay.alpha = 0
                }
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                self.transform = CGAffineTransform(rotationAngle: rotationAngle)
                    .translatedBy(x: sign * distance, y: 0)
                self.alpha = 0
            }
        }, completion: { _ in
            switch direction {
            case .right:
                self.onSwipeRight?()
            case .left:
                self.onSwipeLeft?()
            }
            self.removeFromSuperview()
        })
    }
}

// MARK: - Setup UI
private extension SwipeCardView {
    func setupUI() {
        backgroundColor = UIColor.darkGray
        layer.cornerRadius = 12
        clipsToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        // FrontView
        addSubview(imageContainer)
        
        imageContainer.addSubview(posterImageView)
        imageContainer.addSubview(blurEffectView)
        
        addSubview(gradientContainer)
        gradientContainer.layer.addSublayer(gradientLayer)
        
        addSubview(likeOverlay)
        addSubview(dislikeOverlay)
        addSubview(titleLabel)
        addSubview(genreLabel)
        
        // BackView
        addSubview(backView)
        backView.addSubview(titleBackLabel)
        backView.addSubview(infoStackView)
        backView.addSubview(ratingLabel)
        backView.addSubview(genresScrollView)
        backView.addSubview(overviewScrollView)
        backView.addSubview(imdbButton)
        
        infoStackView.addArrangedSubview(releaseLabel)
        infoStackView.addArrangedSubview(dotLabel)
        infoStackView.addArrangedSubview(runtimeLabel)
        genresScrollView.addSubview(genresStackView)
        overviewScrollView.addSubview(overviewLabel)
        
        // FrontView
        imageContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(350)
        }
        
        likeOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dislikeOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(genreLabel.snp.top).offset(-8)
        }
        
        genreLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
        
        // BackView
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleBackLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(32)
            make.left.right.equalToSuperview().inset(16)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleBackLabel.snp.bottom).offset(16)
            make.left.equalTo(titleBackLabel)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.centerY.equalTo(infoStackView)
            make.right.equalToSuperview().inset(20)
        }
        
        genresScrollView.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        genresStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalToSuperview()
        }
        
        overviewScrollView.snp.makeConstraints { make in
            make.top.equalTo(genresScrollView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(imdbButton.snp.top).offset(-16)
        }
        
        overviewLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        imdbButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(32)
            make.height.equalTo(40)
            make.width.equalTo(140)
        }
    }
}
