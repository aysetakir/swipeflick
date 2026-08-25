import Foundation

enum Endpoint {
    case topRated(page: Int)
    case movieDetail(id: Int)
    case moviesByGenre(genreID: Int, page: Int)
    case moviesByMultipleGenres(genreIDs: String, page: Int)
    case movieByName(name: String)
    case genres
    
    //MARK: - Base URL
    private var baseURL: String {
        return "https://api.themoviedb.org/3"
    }
    
    //MARK: - Path
    private var path: String {
        switch self {
        case .topRated:
            return "/movie/top_rated"
        case .movieDetail(let id):
            return "/movie/\(id)"
        case .moviesByGenre, .moviesByMultipleGenres:
            return "/discover/movie"
        case .genres:
            return "/genre/movie/list"
        case .movieByName:
            return "/search/movie"
        }
    }
    
    //MARK: - Query Items
    private var queryItems: [URLQueryItem]? {
        guard let apiKey = TmdbKeyStore.shared.key, !apiKey.isEmpty else {
            return nil
        }
        switch self {
        case .topRated(let page):
            return [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .movieDetail:
            return [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "append_to_response", value: "external_ids,videos")
            ]
        case .moviesByGenre(let genreID, let page):
            return [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "sort_by", value: "popularity.desc"),
                URLQueryItem(name: "with_genres", value: "\(genreID)"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .moviesByMultipleGenres(let genreIDs, let page):
            return [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "sort_by", value: "popularity.desc"),
                URLQueryItem(name: "with_genres", value: genreIDs),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .genres:
            return [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "language", value: "en-US")
            ]
        case .movieByName(let name):
            let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "query", value: encodedName)
            ]
        }
    }
    
    //MARK: - URL
    var url: URL? {
        guard let items = queryItems else { return nil }
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = items
        return components?.url
    }
}
