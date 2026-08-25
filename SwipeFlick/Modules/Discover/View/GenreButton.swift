import UIKit

final class GenreButton: UIButton {
    
    let genreTitle: String
    private var isSelectedGenre: Bool = false
    
    init(title: String) {
        self.genreTitle = title
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateAppearance()
    }
    
    private func setupButton() {
        setTitle(genreTitle, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        updateAppearance()
        layer.cornerRadius = 20
        layer.borderWidth = 1
        
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside])
    }
    
    func setSelected(_ selected: Bool) {
        isSelectedGenre = selected
        updateAppearance()
    }
    
    private func updateAppearance() {
        if isSelectedGenre {
            applyGradientBackground(colors: [.firstGradient, .secondGradient])
            titleLabel?.font = .boldSystemFont(ofSize: 15)
        } else {
            applyGradientBorder(colors: [.firstGradient, .secondGradient])
            titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        }
    }
    
    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}
