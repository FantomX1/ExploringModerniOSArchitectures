//
//  TmdbParser.swift
//  Architectures
//
//  Created by Fabijan Bajo on 20/05/2017.
//
//
/*
    Tmdb object parsing utility methods
*/

import Foundation

struct TmdbParser {
    
    // DataManager's access to the parsing utilities
    public static func parsedResult(withJSONData data: Data, type: ModelType) -> DataResult {
        do{
            // Serialize raw json into foundation json and retrieve movie array
            let jsonFoundationObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard
                let jsonDict = jsonFoundationObject as? [AnyHashable:Any],
                let jsonObjectsArray = jsonDict["results"] as? [[String:Any]] else {
                    return .failure(TmdbError.invalidJSONData(key: "results", dictionary: jsonFoundationObject))
            }
            return .success(parsedObjects(withJSONArray: jsonObjectsArray, type: type))
        } catch let serializationError {
            return .failure(serializationError)
        }
    }
    
    // Caller of individual object parsers based on object type
    private static func parsedObjects(withJSONArray array: [[String: Any]], type: ModelType) -> [Transportable] {
        switch type {
            case .movie: return array.flatMap { parsedMovie(forMovieJSON: $0) }
            case .actor: return array.flatMap { parsedActor(forActorJSON: $0) }
        }
    }
    
    // Parse individual movie dictionaries, extracted from json response
    private static func parsedMovie(forMovieJSON json: [String:Any]) -> Movie? {
        guard
            let movieID = json["id"] as? Int,
            let title = json["title"] as? String,
            let posterPath = json["poster_path"] as? String,
            let averageRating = json["vote_average"] as? Double,
            let releaseDate = json["release_date"] as? String else {
                // Do not have enough information to construct the object
                return nil
        }
        return Movie(title: title, posterPath: posterPath, movieID: movieID, releaseDate: releaseDate, averageRating: averageRating)
    }
    
    // Parse individual actor dictionaries, extracted from json response
    private static func parsedActor(forActorJSON json: [String:Any]) -> Actor? {
        guard
            let actorID = json["id"] as? Int,
            let name = json["name"] as? String,
            let profilePath = json["profile_path"] as? String else {
                // Do not have enough information to construct the object
                return nil
        }
        return Actor(name: name, profilePath: profilePath, actorID: actorID)
    }
}


// MARK: - Tmdb parsing related helper types

fileprivate enum TmdbError: CustomStringConvertible, Error {
    case invalidJSONData(key: String, dictionary: Any)
    case serializationError(error: Error)
    case other(string: String)
    var description: String {
        switch self {
        case .invalidJSONData(let key, let dict):
            return "Could not find key '\(key)' in JSON dictionary:\n \(dict)"
        case .serializationError(let error):
            return "JSON serialization failed with error:\n \(error)"
        case .other(let string):
            return string
        }
    }
}
