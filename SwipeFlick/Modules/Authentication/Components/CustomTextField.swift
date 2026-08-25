import UIKit
import SnapKit

func customTextField(
    title: String,
    placeholder: String,
    iconName: String,
    isSecure: Bool
) -> UIView {
    let container = UIView()
    container.backgroundColor = .white
    container.layer.cornerRadius = 16
    container.layer.borderWidth = 1
    container.layer.borderColor = UIColor.systemGray2.cgColor
    
    let iconView = UIImageView(image: UIImage(systemName: iconName))
    iconView.tintColor = .buttonPrimary
    iconView.contentMode = .scaleAspectFit
    
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    titleLabel.textColor = .gray
    
    let textField = UITextField()
    textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    textField.textColor = .black
    textField.isSecureTextEntry = isSecure
    textField.autocapitalizationType = (iconName == "envelope") ? .none : .words
    
    textField.attributedPlaceholder = NSAttributedString(
        string: placeholder,
        attributes: [
            .foregroundColor: UIColor.systemGray3,
            .font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ]
    )
    
    container.addSubview(iconView)
    container.addSubview(titleLabel)
    container.addSubview(textField)
    
    iconView.snp.makeConstraints { make in
        make.leading.equalToSuperview().offset(16)
        make.centerY.equalToSuperview()
        make.size.equalTo(24)
    }
    
    titleLabel.snp.makeConstraints { make in
        make.top.equalToSuperview().offset(12)
        make.leading.equalTo(iconView.snp.trailing).offset(12)
        make.trailing.equalToSuperview().offset(-16)
    }
    
    textField.snp.makeConstraints { make in
        make.top.equalTo(titleLabel.snp.bottom).offset(4)
        make.leading.equalTo(titleLabel)
        make.trailing.equalToSuperview().offset(-16)
        make.bottom.equalToSuperview().offset(-12)
    }
    
    return container
}
