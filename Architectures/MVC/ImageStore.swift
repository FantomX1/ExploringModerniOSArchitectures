//
//  ImageStore.swift
//  FrameworksAndMovies
//
//  Created by Fabijan Bajo on 25/04/2017.
//  Copyright © 2017 Fabijan Bajo. All rights reserved.
//
/*
    Task: interface for adding, retrieving, and deleting an image from the cache
*/

import UIKit

final class ImageStore {
    
    
    // MARK: - Properties
    
    private let cache = NSCache<NSString,UIImage>()
    
    
    // MARK: - Methods
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        // Store image to disk
        // Writing atomically prevents data corruption should your application crash during the write procedure. (stored in temp first)
        let url = imageURL(forKey: key)
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            let _ = try? data.write(to: url, options: [.atomic])
        }
    }
    
    func image(forKey key: String) -> UIImage? {
        // Check if in local cache first
        if let  existingImage = cache.object(forKey: key as NSString) {
            return existingImage
        }
        // Check in docs dir
        let url = imageURL(forKey: key)
        guard let imageFromDisk = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        // Set from disk to cache 
        cache.setObject(imageFromDisk, forKey: key as NSString)
        return imageFromDisk
    }
    
    func deleteImage(forKey key: String) {
        // Remove from both cache and file system
        cache.removeObject(forKey: key as NSString)
        let url = imageURL(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
    }
    
    // Helper for creating file URLS for images to be stored in docs dir
    private func imageURL(forKey key: String) -> URL {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDir.appendingPathComponent(key)
    }
}
