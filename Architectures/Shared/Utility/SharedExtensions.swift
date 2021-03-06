//
//  SharedExtensions.swift
//  Architectures
//
//  Created by Fabijan Bajo on 29/05/2017.
//
//

import UIKit

// MARK: - UIImageView

extension UIImageView {
    public func downloadImage(from url: URL, completion: (() -> Void)? = nil) {
        // Remove "/" because docs dir sees as folders
        let cacheKey = url.path.components(separatedBy: "/").dropFirst(3).joined(separator: "")
        if let image = DataManager.shared.imageStore.image(forKey: cacheKey) {
            DispatchQueue.main.async {
                self.image = image
                completion?()
            }
            return
        }
        // Nothing in cache / docs? Fetch new
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
            print("Image from network fetch")
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data) else {
                    completion?()
                    print("Could not fetch image for url: \(url.path)")
                    return
            }
            DataManager.shared.imageStore.setImage(image, forKey: cacheKey)
            DispatchQueue.main.async {
                self?.image = image
                completion?()
            }
        }).resume()
    }
}


// MARK: - UICollectionViewFlowLayout

extension UICollectionViewFlowLayout {
    // Inits layout with equal spacing for all insets and itemspacings
    convenience init(abstraction: CollectionViewConfigurable, bounds: CGRect) {
        self.init()
        // Define values
        let spacing = CGFloat(abstraction.interItemSpacing ?? 0)
        var bottomInset = CGFloat()
        let widthDivisor = CGFloat(abstraction.widthDivisor)
        let heightDivisor = CGFloat(abstraction.heightDivisor)
        // iOS11 no top layout guide
        if #available(iOS 11.0, *) {
            bottomInset = 0
        } else {
            bottomInset = CGFloat(abstraction.bottomInset ?? 0)
        }
        
        // Calculate itemSize
        let fullWspace = (widthDivisor + 1) * spacing
        let fullHspace = (heightDivisor + 1) * spacing
        let width = (bounds.width - fullWspace) / widthDivisor
        let height = (bounds.height - fullHspace) / heightDivisor
        self.itemSize = CGSize(width: width, height: height)
        sectionInset = UIEdgeInsets(
            top: spacing,
            left: spacing,
            bottom: bottomInset,
            right: spacing
        )
        minimumInteritemSpacing = spacing
        minimumLineSpacing = spacing
    }
}
