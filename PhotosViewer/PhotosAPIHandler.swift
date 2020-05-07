//
//  PhotosAPIHandler.swift
//  PhotosViewer
//
//  Created by bogdan.filioreanu on 5/7/20.
//  Copyright © 2020 bogdan.filioreanu. All rights reserved.
//

import SwiftyJSON

enum APIError: Error {
  case invalidURL
  case unknown
  case apiError(error: Error)
  case jsonError(error: Error)
}

class PhotosAPIHandler {
  
  let urlString = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
  let urlSession: URLSession
  let sourceURL: URL?
  
  init() {
    self.urlSession = URLSession(configuration: .default)
    self.sourceURL = URL(string: urlString)
  }
  
  func fetchData(completion: @escaping (Result<PhotoDataSource?, APIError>) -> Void) {
    
    guard let url = sourceURL else {
      DispatchQueue.main.async {
        completion(.failure(.invalidURL))
      }
      return
    }
    
    let fetchTask = urlSession.dataTask(with: url) { (data, response, error) in
      var finalError: APIError? = nil
      var finalDataSource: PhotoDataSource? = nil
      
      if let error = error {
        finalError = .apiError(error: error)
      } else if let data = data,
        let utf8Data = String(decoding: data, as: UTF8.self).data(using: .utf8) {
        do {
          let jsonData = try JSON(data: utf8Data,options: .allowFragments)
          let rawData = try jsonData.rawData()
          finalDataSource = try JSONDecoder().decode(PhotoDataSource.self, from: rawData)
        } catch {
          finalError = .jsonError(error: error)
        }
      } else {
        finalError = .unknown
      }
      
      DispatchQueue.main.async {
        if let finalError = finalError {
          completion(.failure(finalError))
        } else {
          completion(.success(finalDataSource))
        }
      }
    }
    fetchTask.resume()
  }
}
