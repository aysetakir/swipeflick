import UIKit
import QuartzCore
import SnapKit

final class SplashVC: UIViewController {
    private let viewModel: SplashVMProtocol
    
    private let logoContainer: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "SplashLogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.buttonPrimary.withAlphaComponent(0.95)
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.9
        label.alpha = 0
        return label
    }()
    
    private lazy var messageContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [messageLabel, dotsStackView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.alpha = 0
        return stack
    }()
    
    private let dotsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()
    
    private var dotViews: [UIView] = []
    private var hasDisplayedInitialMessage = false
    private var isAnimatingMessage = false
    private var hasStartedDotAnimation = false
    
    private let dotDiameter: CGFloat = 6
    private lazy var dotAccentColor: UIColor = .buttonPrimary
    private lazy var dotBaseColor: UIColor = dotAccentColor.withAlphaComponent(0.25)
    private lazy var dotHighlightColor: UIColor = dotAccentColor.withAlphaComponent(0.9)
    
    init(viewModel: SplashVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundPrimaryColor")
        setupLayout()
        configureBindings()
        animateLogo()
        viewModel.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stop()
    }
    
    deinit {
        viewModel.stop()
    }
}

private extension SplashVC {
    func setupLayout() {
        view.addSubview(logoContainer)
        view.addSubview(messageContainer)
        logoContainer.addSubview(logoImageView)
        
        setupDots()
        
        logoContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(190)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        messageContainer.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide).inset(32)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(32)
        }
    }
    
    func configureBindings() {
        viewModel.onMessageUpdate = { [weak self] message in
            guard let self else { return }
            DispatchQueue.main.async {
                self.updateMessage(message)
            }
        }
    }
    
    func animateLogo() {
        logoContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0.2,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) {
            self.logoContainer.alpha = 1
            self.logoContainer.transform = .identity
        }
    }
    
    func updateMessage(_ message: String) {
        let verticalOffset: CGFloat = 14
        
        if !hasDisplayedInitialMessage {
            hasDisplayedInitialMessage = true
            messageLabel.text = message
            messageLabel.transform = CGAffineTransform(translationX: 0, y: verticalOffset)
            
            UIView.animate(
                withDuration: 0.8,
                delay: 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.4,
                options: [.curveEaseOut]
            ) {
                self.messageContainer.alpha = 1
                self.messageLabel.alpha = 1
                self.messageLabel.transform = .identity
            }
            
            startDotsAnimationIfNeeded()
            return
        }
        
        guard !isAnimatingMessage else { return }
        isAnimatingMessage = true
        
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [.curveEaseIn]
        ) {
            self.messageLabel.alpha = 0
            self.messageLabel.transform = CGAffineTransform(translationX: 0, y: -verticalOffset)
        } completion: { _ in
            self.messageLabel.text = message
            self.messageLabel.transform = CGAffineTransform(translationX: 0, y: verticalOffset)
            
            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                usingSpringWithDamping: 0.76,
                initialSpringVelocity: 0.3,
                options: [.curveEaseOut]
            ) {
                self.messageLabel.alpha = 1
                self.messageLabel.transform = .identity
            } completion: { _ in
                self.isAnimatingMessage = false
            }
        }
        
        startDotsAnimationIfNeeded()
    }
    
    func setupDots() {
        dotViews = (0..<3).map { _ in
            let dot = UIView()
            dot.backgroundColor = dotBaseColor
            dot.layer.cornerRadius = dotDiameter / 2
            dot.layer.masksToBounds = true
            
            dotsStackView.addArrangedSubview(dot)
            dot.snp.makeConstraints { make in
                make.width.height.equalTo(dotDiameter)
            }
            
            return dot
        }
    }
    
    func startDotsAnimationIfNeeded() {
        guard !hasStartedDotAnimation else { return }
        hasStartedDotAnimation = true
        
        let duration: CFTimeInterval = 0.9
        let baseTime = CACurrentMediaTime()
        
        for (index, dot) in dotViews.enumerated() {
            guard dot.layer.animation(forKey: "shimmer") == nil else { continue }
            
            let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
            colorAnimation.fromValue = dotBaseColor.cgColor
            colorAnimation.toValue = dotHighlightColor.cgColor
            colorAnimation.duration = duration
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 1.25
            scaleAnimation.duration = duration
            
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [colorAnimation, scaleAnimation]
            animationGroup.duration = duration
            animationGroup.autoreverses = true
            animationGroup.repeatCount = .infinity
            animationGroup.beginTime = baseTime + (Double(index) * 0.18)
            animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            dot.layer.add(animationGroup, forKey: "shimmer")
        }
    }
}

