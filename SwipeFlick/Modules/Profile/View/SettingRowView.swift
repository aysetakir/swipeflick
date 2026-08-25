import UIKit
import SnapKit

final class SettingRowView: UIControl {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    enum Style { case normal, destructive }

    init(title: String, systemIcon: String, style: Style = .normal) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.06)
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        iconView.image = UIImage(systemName: systemIcon)
        iconView.tintColor = (style == .normal) ? .buttonPrimary : .systemRed
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = (style == .normal) ? UIColor.white : .systemRed

        chevron.tintColor = .white.withAlphaComponent(0.6)

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(chevron)

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(chevron.snp.leading).offset(-8)
        }
        chevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }

        snp.makeConstraints { $0.height.equalTo(56) }

        addTarget(self, action: #selector(touchDown), for: [.touchDown])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchCancel, .touchUpOutside])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func tintColorDidChange() {
        super.tintColorDidChange()
    }

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.08) {
            self.alpha = 0.85
            self.transform = CGAffineTransform(scaleX: 0.99, y: 0.99)
        }
    }
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.12) {
            self.alpha = 1
            self.transform = .identity
        }
    }
}
