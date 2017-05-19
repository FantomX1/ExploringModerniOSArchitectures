//
//  MovieResultsViewController.swift
//  Architectures
//
//  Created by Fabijan Bajo on 19/05/2017.
//
//

import UIKit

class MovieResultsViewController: UIViewController {
    
    
    // MARK: - Properties
    
    var movieManager: MovieManager!
    let dataSource = MovieResultsDataSource()
    @IBOutlet var collectionView: UICollectionView!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Now Playing Movies"
        // Configure collectionview
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        let cellNib = UINib(nibName: "MovieCollectionViewCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: dataSource.cellID)
        
        // Start the movie fetch asynchronously and update the datasource
        movieManager.fetchNowPlayingMovies { (result) in
            switch result {
            case let .success(movies):
                self.dataSource.movies = movies
            case let .failure(error):
                print(error)
                self.dataSource.movies.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}


// MARK: - CollectionView Delegate

extension MovieResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let movie = dataSource.movies[indexPath.item]
        // Download image data for cell asynchronously
        movieManager.fetchImage(forMovie: movie, size: .thumb) { (result) in
            // Make sure it's the same movie object (fetching async)
            guard let movieIndex = self.dataSource.movies.index(of: movie),
                case let .success(image) = result else {
                    return
            }
            let movieIndexPath = IndexPath(row: movieIndex, section: 0)
            // Update cell when image request finishes, if cell still visible on screen
            if let cell = self.collectionView.cellForItem(at: movieIndexPath) as? MovieCollectionViewCell {
                cell.updateImageView(with: image)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = dataSource.movies[indexPath.row]
        let movieDetailVC = MovieDetailViewController()
        movieDetailVC.movie = movie
        movieDetailVC.movieManager = movieManager
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension MovieResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Half screen width with room for 1pt interitemspacing
        let width = (view.bounds.width / 2) - 1
        let height = (view.bounds.height / 2.5) - 1
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}