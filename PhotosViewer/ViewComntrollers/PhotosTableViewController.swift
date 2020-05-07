//
//  PhotosTableViewController.swift
//  PhotosViewer
//
//  Created by bogdan.filioreanu on 5/7/20.
//  Copyright © 2020 bogdan.filioreanu. All rights reserved.
//

import UIKit

/// Main content controller containing the photos list organized as a table view
class PhotosTableViewController: UITableViewController {
  
  // The API handler class used for fetching data
  var photosApiHandler: PhotosAPIHandler?
  // The data source used for the table view
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

    var message = "There was a problem. Please try again later."
    switch error {
    case APIError.apiError(let error):
      message = error.localizedDescription
    case APIError.jsonError(let error):
      message = error.localizedDescription
    default:
      break
    }
    let alert = UIAlertController(title: "Failed loading data", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: {
      self.tableView.refreshControl?.endRefreshing()
    })
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photosDataSource?.validRows().count ?? 0
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
