import UIKit
import SnapKit

final class EmptyView: UIView {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "emptyImage")
        return imageView
    }()
    
    private let retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "try_again".translated
        config.baseBackgroundColor = .buttonPrimary
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 30, bottom: 14, trailing: 30)
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    
    private var retryAction: (() -> Void)?
    
    init(retryAction: (() -> Void)? = nil) {
        super.init(frame: .zero)
        self.retryAction = retryAction
        setupUI()
        
        if let retryAction = retryAction {
            retryButton.addAction(UIAction(handler: { _ in retryAction() }), for: .touchUpInside)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI
private extension EmptyView {
    func setupUI() {
        backgroundColor = .backgroundPrimary
        
        addSubview(imageView)
        addSubview(retryButton)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.height.equalTo(350)
        }
        
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
        }
    }
}
