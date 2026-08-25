import Foundation

struct MovieDetail: Decodable {
    let id: Int
    let title: String
    let overview: String
    let genres: [Genre]
    let posterPath: String?
    let externalIDs: ExternalIDs
    let videos: VideoResponse
    let runtime: Int
    let voteAverage: Double
    let releaseDate: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, genres
        case posterPath = "poster_path"
        case externalIDs = "external_ids"
        case videos, runtime
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
    
    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(posterPath)")
    }
}

struct ExternalIDs: Decodable {
    let imdbID: String?
    
    enum CodingKeys: String, CodingKey {
        case imdbID = "imdb_id"
    }
    
    var imdbURL: String? {
        guard let imdbID else { return nil }
        return "https://www.imdb.com/title/\(imdbID)"
    }
}

struct VideoResponse: Decodable {
    let results: [Video]
}

struct Video: Decodable {
    let key: String
    let name: String
    let site: String
    let type: String
}
