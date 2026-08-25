import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    private let session = URLSession.shared
    
    private func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw error
        }
    }
    
    //MARK: - Fetch Movies
    func fetchMovies(page: Int = 1) async throws -> ([Movie], Int) {
        let endpoint = Endpoint.topRated(page: page)
        let response: TopRatedResponse = try await request(endpoint)
        return (response.results, response.totalPages)
    }
    
    //MARK: - Fetch Movie Detail
    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        let endpoint = Endpoint.movieDetail(id: id)
        let response: MovieDetail = try await request(endpoint)
        return response
    }
    
    //MARK: - Fetch Movies By Genre
    func fetchMoviesByGenre(genreID: Int, page: Int = 1) async throws -> ([Movie], Int) {
        let endpoint = Endpoint.moviesByGenre(genreID: genreID, page: page)
        let response: TopRatedResponse = try await request(endpoint)
        return (response.results, response.totalPages)
    }
    
    //MARK: - Genre List
    func fetchGenres() async throws -> [Genre] {
        let endpoint = Endpoint.genres
        let response: GenreResponse = try await request(endpoint)
        return response.genres
    }
    
    //MARK: - Fetch Random Movie By Moods and Total Pages Count
    func fetchRandomMovieByMoods(genreIDs: [Int], page: Int = 1) async throws -> ([Movie], Int) {
        let genreIDsString = genreIDs.map { String($0) }.joined(separator: ",")
        let endpoint = Endpoint.moviesByMultipleGenres(genreIDs: genreIDsString, page: page)
        let response: TopRatedResponse = try await request(endpoint)
        return (response.results, response.totalPages)
    }
    
    func fetchMoviesByName(name: String) async throws -> [Movie] {
        let endpoint = Endpoint.movieByName(name: name)
        let response: TopRatedResponse = try await request(endpoint)
        return response.results
    }
}
