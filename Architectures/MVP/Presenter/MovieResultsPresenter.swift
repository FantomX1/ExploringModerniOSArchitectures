//
//  MovieResultsPresenter.swift
//  Architectures
//
//  Created by Fabijan Bajo on 29/05/2017.
//
//

import Foundation

class MovieResultsPresenter: ResultsViewPresenter {
    
    
    // MARK: - Properties
    
    unowned private let view: ResultsView
    private var movies = [Movie]()
    var objectsCount: Int { return movies.count }
    struct PresentableInstance: Transportable {
        let title: String
        let thumbnailURL: URL
        let fullSizeURL: URL
        let ratingText: String
        let releaseDateText: String
    }
    private let releaseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        return formatter
    }()
    
    
    // MARK: - Initializers
    
    required init(view: ResultsView) {
        self.view = view
    }
    // Cannot Mock because of movies private access control
    convenience init(view: ResultsView, testableMovies: [Movie]) {
        self.init(view: view)
        movies = testableMovies
    }
    
    
    // MARK: - Methods
    
    func presentableInstance(index: Int) -> Transportable {
        let movie = movies[index]
        let thumbnailURL = TmdbAPI.tmdbImageURL(forSize: .thumb, path: movie.posterPath)
        let fullSizeURL = TmdbAPI.tmdbImageURL(forSize: .full, path: movie.posterPath)
        let ratingText = String(format: "%.1f", movie.averageRating)
        let dateObject = releaseDateFormatter.date(from: movie.releaseDate)
        let releaseDateText = releaseDateFormatter.string(from: dateObject!)
        return PresentableInstance(title: movie.title, thumbnailURL: thumbnailURL, fullSizeURL: fullSizeURL, ratingText: ratingText, releaseDateText: releaseDateText)
    }
    
    func presentNewObjects() {
        DataManager.shared.fetchNewTmdbObjects(withType: .movie) { (result) in
            switch result {
            case let .success(parsables):
                self.movies = parsables as! [Movie]
            case let .failure(error):
                print(error)
            }
            self.view.reloadCollectionData()
        }
    }
    
    func presentDetail(for indexPath: IndexPath) {
        let presentable = presentableInstance(index: indexPath.row) as! PresentableInstance
        let vc = DetailViewController()
        vc.imageURL = presentable.fullSizeURL
        vc.navigationItem.title = presentable.title
        view.show(vc)
    }
}


// MARK: - CollectionViewConfigurable
extension MovieResultsPresenter: CollectionViewConfigurable {
    
    // MARK: - Properties
    
    // Required
    var cellID: String { return "MovieCell" }
    var widthDivisor: Double { return 2.0 }
    var heightDivisor: Double { return 2.5 }
    
    // Optional
    var interItemSpacing: Double? { return 1 }
    var lineSpacing: Double? { return 1 }
    var bottomInset: Double? { return 49 }
}
