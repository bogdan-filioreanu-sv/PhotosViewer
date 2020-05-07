//
//  PhotosTableViewController.swift
//  PhotosViewer
//
//  Created by bogdan.filioreanu on 5/7/20.
//  Copyright © 2020 bogdan.filioreanu. All rights reserved.
//

import UIKit

class PhotosTableViewController: UITableViewController {
  
  var photosApiHandler: PhotosAPIHandler?
  var photosDataSource: PhotoDataSource?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(PhotoInfoCell.self, forCellReuseIdentifier: PhotoInfoCell.reuseIdentifier)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 100
    
    // Configure Refresh Control
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshOnPullToRefresh(_:)), for: .valueChanged)
    
    tableView.refreshControl = refreshControl
    photosApiHandler = PhotosAPIHandler()
    reloadData()
  }
  
  @objc private func refreshOnPullToRefresh(_ sender: Any) {
      reloadData()
  }
  
  func reloadData() {
    photosApiHandler?.fetchData() { [weak self] result in
      switch result {
      case .success(let dataSource):
        // Reset the dataSource and refresh the UI
        self?.photosDataSource = dataSource
        self?.refresh()
      case .failure(let error):
        self?.handleAPIError(error)
      }
    }
  }
  
  func refresh() {
    self.title = self.photosDataSource?.title
    self.tableView.refreshControl?.endRefreshing()
    self.tableView.reloadData()
  }
  
  func handleAPIError(_ error: Error) {
    // For now just print the error
    print("Failed reloading the data source \(error)")
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photosDataSource?.validRows().count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
      return 100
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    // Disable having separators even if no cells are loaded
    return UIView()
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: PhotoInfoCell.reuseIdentifier, for: indexPath) as? PhotoInfoCell ?? PhotoInfoCell()
    
    if let rowData = self.photosDataSource?.validRows()[indexPath.row] {
      cell.setup(data: rowData)
    }
    
    return cell
  }
}
