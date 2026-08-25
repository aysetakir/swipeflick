import UIKit

final class MoodButton: UIButton {
    
    public let mood: Mood
    
    init(mood: Mood) {
        self.mood = mood
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradientBackground(
            colors: [.firstGradient, .secondGradient],
            cornerRadius: 16
        )
    }
    
    private func setupUI() {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .clear
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 20, leading: 24, bottom: 20, trailing: 24
        )
        
        var titleAttr = AttributedString(mood.emoji)
        titleAttr.font = .systemFont(ofSize: 18)
        config.attributedTitle = titleAttr
        
        var subtitleAttr = AttributedString(mood.displayName)
        subtitleAttr.font = .systemFont(ofSize: 17, weight: .semibold)
        config.attributedSubtitle = subtitleAttr
        
        config.titlePadding = 6
        config.titleAlignment = .center
        
        self.configuration = config
        self.clipsToBounds = true
    }
}
