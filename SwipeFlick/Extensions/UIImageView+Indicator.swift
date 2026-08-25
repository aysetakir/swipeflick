import UIKit
import SnapKit

extension UIImageView {
    func setImage(with url: URL?) {
        self.image = nil
        self.backgroundColor = .clear
        
        guard let url = url else {
            self.image = UIImage(named: "noPoster")
            self.contentMode = .scaleAspectFill
            return
        }
        
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        addSubview(indicator)
        
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        indicator.startAnimating()
        
        Task {
            if let image = try? await ImageLoader.shared.loadImage(from: url) {
                self.alpha = 0
                self.image = image
                self.contentMode = .scaleAspectFill
                
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               options: [.curveEaseInOut],
                               animations: {
                    self.alpha = 1
                })
            } else {
                self.image = UIImage(named: "noPoster")
                self.contentMode = .scaleAspectFill
            }
            indicator.removeFromSuperview()
        }
    }
}
