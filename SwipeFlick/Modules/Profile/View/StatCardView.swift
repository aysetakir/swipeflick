import UIKit
import SnapKit

final class StatCardView: UIView {
    private let iconView = UIImageView()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    var value: Int = 0 { didSet { valueLabel.text = "\(value)" } }

    init(icon: String, title: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.06)
        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .buttonPrimary
        iconView.contentMode = .scaleAspectFit

        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .left
        valueLabel.text = "0"

        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .white.withAlphaComponent(0.8)
        titleLabel.text = title

        let h = UIStackView(arrangedSubviews: [iconView, valueLabel])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 8

        let v = UIStackView(arrangedSubviews: [h, titleLabel])
        v.axis = .vertical
        v.spacing = 4

        addSubview(v)
        v.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        iconView.snp.makeConstraints { $0.size.equalTo(18) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

