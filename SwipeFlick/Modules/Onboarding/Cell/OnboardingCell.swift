import UIKit
import SnapKit

final class OnboardingCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundPrimary
        return view
    }()
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundPrimary
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 50
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .backgroundPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .backgroundPrimary.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(imageContainerView)
        containerView.addSubview(cardView)
        imageContainerView.addSubview(imageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(containerView.snp.height).multipliedBy(0.7)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cardView.snp.makeConstraints { make in
            make.top.equalTo(imageContainerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.top).offset(12)
            make.leading.equalTo(cardView.snp.leading).offset(16)
            make.trailing.equalTo(cardView.snp.trailing).offset(-16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(cardView.snp.leading).offset(16)
            make.trailing.equalTo(cardView.snp.trailing).offset(-16)
            make.bottom.equalTo(cardView.snp.bottom).offset(-12)
        }
    }
    
    func configure(title: String, subtitle: String, imageName: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        imageView.image = UIImage(named: imageName)
    }
}
