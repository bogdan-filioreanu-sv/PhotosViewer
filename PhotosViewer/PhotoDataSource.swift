//
//  PhotoDataSource.swift
//  PhotosViewer
//
//  Created by bogdan.filioreanu on 5/7/20.
//  Copyright © 2020 bogdan.filioreanu. All rights reserved.
//

import Foundation

class PhotoDataSource: Codable {
  let title: String?
  private let rows: [PhotoRowInfo]?
  
  func validRows() -> [PhotoRowInfo] {
    return rows?.compactMap({ (rowInfo) -> PhotoRowInfo? in
      (rowInfo.description != nil || rowInfo.title != nil || rowInfo.imageHref != nil) ? rowInfo : nil
    }) ?? []
  }
}
