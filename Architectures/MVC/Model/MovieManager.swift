//
//  MovieManager.swift
//  Architectures
//
//  Created by Fabijan Bajo on 17/05/2017.
//
//

import UIKit


final class MovieStore {
    
    
    // MARK: - Properties
    
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    
    // MARK: - Methods
    
    // Fetch now playing movies and dispatch on main
    func fetchNowPlayingMovies(completion: @escaping (MoviesResult) -> Void) {
        let request = URLRequest(url: TmdbAPI.nowPlayingMoviesURL)
        let task = session.dataTask(with: request) { (data, response, error) in
            let result = self.processMoviesRequest(data: data, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task.resume()
    }
    private func processMoviesRequest(data: Data?, error: Error?) -> MoviesResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return TmdbAPI.parsedMovies(forJSONData: jsonData)
    }
    
    // Fetch image for movie and dispatch on main
    func fetchImage(for path: String, size: TmdbImageSize, completion: @escaping (ImageResult) -> Void) {
        let request = URLRequest(url: TmdbAPI.tmdbImageURL(forSize: size, path: path))
        let task = session.dataTask(with: request) { (data, response, error) in
            let result = self.processImageRequest(data: data, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task.resume()
    }
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                // Couldn't create image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(MovieError.imageCreationError)
                }
        }
        return .success(image)
    }
}


// MARK: - Movie types

enum MovieError: Error {
    case imageCreationError
}

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum MoviesResult {
    case success([Movie])
    case failure(Error)
}
