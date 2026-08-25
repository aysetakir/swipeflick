import UIKit
import SnapKit

final class LikedMoviesCell: UICollectionViewCell {
    static let identifier = "LikedMoviesCell"
    private var gradientLayer: CAGradientLayer?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = UIColor(white: 0.2, alpha: 1)
        return imageView
    }()

    private let gradientView: UIView = {
        let gradientContainerView = UIView()
        gradientContainerView.layer.cornerRadius = 12
        gradientContainerView.layer.masksToBounds = true
        return gradientContainerView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer {
            gradientLayer.frame = gradientView.bounds
        } else {
            installGradientIfNeeded()
        }
    }

    func configure(with movie: Movie) {
        imageView.setImage(with: movie.posterURL)
        titleLabel.text = movie.title
    }
}

private extension LikedMoviesCell {
    func setupUI() {
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)

        contentView.addSubview(imageView)
        contentView.addSubview(gradientView)
        gradientView.addSubview(titleLabel)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        gradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(imageView)
            make.height.equalToSuperview().multipliedBy(0.28)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }

    }

    func installGradientIfNeeded() {
        guard gradientLayer == nil else { return }
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = gradientView.bounds
        gradient.cornerRadius = 12
        gradientView.layer.addSublayer(gradient)
        gradientLayer = gradient
    }
}
