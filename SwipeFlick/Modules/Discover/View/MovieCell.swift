import UIKit
import SnapKit

final class MovieCell: UICollectionViewCell {
    
    static let identifier = "MovieCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.2, alpha: 1)
        return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        layer.locations = [0.6, 1.0]
        return layer
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        // iOS’un varsayılan highlight rengini kapatma
        self.contentView.isUserInteractionEnabled = false
        self.backgroundView = UIView()
        self.selectedBackgroundView = UIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = posterImageView.bounds
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(posterImageView)
        posterImageView.layer.addSublayer(gradientLayer)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        posterImageView.setImage(with: movie.posterURL)
    }
    
    
    override var isHighlighted: Bool {
        didSet {
            animate(isPressed: isHighlighted)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                animate(isPressed: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.animate(isPressed: false)
                }
            }
        }
    }
    
    private func animate(isPressed: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.containerView.transform = isPressed ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
            self.titleLabel.alpha = isPressed ? 1 : 0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        containerView.transform = .identity
        titleLabel.alpha = 0
    }
}
