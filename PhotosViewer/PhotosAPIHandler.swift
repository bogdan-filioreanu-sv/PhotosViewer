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
        
        let jsonData = try? JSON(data: utf8Data,options: .allowFragments)
        if let jsonData = try? jsonData?.rawData(), let dataSource = try? JSONDecoder().decode(PhotoDataSource.self, from: jsonData) {
          finalDataSource = dataSource
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
