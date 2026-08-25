import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: URL) async throws -> UIImage
}

final class ImageLoader: ImageLoaderProtocol {
    
    static let shared = ImageLoader()
    private init() {}
    
    private let cache = NSCache<NSURL, UIImage>()
    
    func loadImage(from url: URL) async throws -> UIImage {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw NetworkError.noData
        }
        
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}
