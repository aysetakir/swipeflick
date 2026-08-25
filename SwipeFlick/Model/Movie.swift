import Foundation

struct TopRatedResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let genreIDs: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case genreIDs = "genre_ids"
    }
    
    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    // MARK: - Firestore Conversion
    init(id: Int, title: String, overview: String, posterPath: String?, genreIDs: [Int]) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.genreIDs = genreIDs
    }
    
    init?(from dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? Int,
              let title = dictionary["title"] as? String,
              let overview = dictionary["overview"] as? String,
              let genreIDs = dictionary["genreIDs"] as? [Int] else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = dictionary["posterPath"] as? String
        self.genreIDs = genreIDs
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "overview": overview,
            "genreIDs": genreIDs
        ]
        
        if let posterPath = posterPath {
            dict["posterPath"] = posterPath
        }
        
        return dict
    }
}
