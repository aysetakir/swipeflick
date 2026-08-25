import UIKit

extension UIButton {
    
    func applyGradientBackground(colors: [UIColor], cornerRadius: CGFloat = 20) {
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        gradient.cornerRadius = cornerRadius
        
        layer.insertSublayer(gradient, at: 0)
        layer.borderWidth = 0
    }
    
    func applyGradientBorder(colors: [UIColor], cornerRadius: CGFloat = 20, borderWidth: CGFloat = 3) {
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        gradient.cornerRadius = cornerRadius
        
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        shape.lineWidth = borderWidth
        gradient.mask = shape
        
        layer.insertSublayer(gradient, at: 0)
        backgroundColor = .clear
        layer.borderWidth = 0
        
    }
}
