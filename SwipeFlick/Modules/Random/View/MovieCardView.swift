import UIKit
import SnapKit

final class MovieCardView: UIView {
    
    private var isExpanded = false
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.85).cgColor
        ]
        layer.locations = [0.4, 1.0]
        return layer
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.8)
        label.numberOfLines = 3
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let moodBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let moodLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = imageView.bounds
    }
    
    private func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 20
        clipsToBounds = true
        
        addSubview(imageView)
        imageView.layer.addSublayer(gradientLayer)
        
        addSubview(moodBadge)
        moodBadge.addSubview(moodLabel)
        
        addSubview(titleLabel)
        addSubview(taglineLabel)
        
        setupConstraints()
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(taglineTapped))
        taglineLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func taglineTapped() {
        isExpanded.toggle()
        
        UIView.animate(withDuration: 0.3) {
            self.taglineLabel.numberOfLines = self.isExpanded ? 0 : 3
            self.layoutIfNeeded()
        }
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        moodBadge.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.height.equalTo(32)
        }
        
        moodLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(taglineLabel.snp.top).offset(-8)
        }
        
        taglineLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func configure(with movie: Movie, mood: Mood) {
        titleLabel.text = movie.title
        taglineLabel.text = movie.overview
        moodLabel.text = mood.displayName
         
        isExpanded = false
        taglineLabel.numberOfLines = 3
        
        imageView.setImage(with: movie.posterURL)
        
    }
}
