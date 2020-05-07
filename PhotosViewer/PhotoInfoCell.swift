//
//  PhotoInfoCell.swift
//  PhotosViewer
//
//  Created by bogdan.filioreanu on 5/7/20.
//  Copyright © 2020 bogdan.filioreanu. All rights reserved.
//

import UIKit
import Kingfisher

/// The cell used for the photos list. It contains the photo image view, the description and the title.
/// The image view uses the Kingfisher framework for fetching the image.
class PhotoInfoCell: UITableViewCell {
  
  static let reuseIdentifier = "PhotoInfoCell"
  
  private var photoView: UIImageView
  private var titleLabel: UILabel
  private var descriptionLabel: UILabel
  private var containerStackView: UIStackView
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.photoView = UIImageView()
    self.titleLabel = UILabel()
    self.descriptionLabel = UILabel()
    self.containerStackView = UIStackView()
    super.init(style: .default, reuseIdentifier: PhotoInfoCell.reuseIdentifier)
    setupInitialLayout()
  }
  
  func setupInitialLayout() {
    selectionStyle = .none
    preservesSuperviewLayoutMargins = false
    separatorInset = UIEdgeInsets.zero
    layoutMargins = UIEdgeInsets.zero
    //translatesAutoresizingMaskIntoConstraints = false
    
    // Setup the stack view
    containerStackView.axis = .vertical
    containerStackView.alignment = .center
    containerStackView.distribution = .equalSpacing
    containerStackView.spacing = CGFloat(5.0)
    containerStackView.translatesAutoresizingMaskIntoConstraints = false
    
    // Setup the image view
    photoView.contentMode = .scaleAspectFit
    photoView.translatesAutoresizingMaskIntoConstraints = false
    
    // Setup the title label
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    // Setup the description label
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textAlignment = .left
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(containerStackView)
    containerStackView.addArrangedSubview(photoView)
    containerStackView.addArrangedSubview(titleLabel)
    containerStackView.addArrangedSubview(descriptionLabel)
    contentView.autoresizingMask = .flexibleHeight
    
    let views: [String: Any] = [
      "photoView": photoView,
      "titleLabel": titleLabel,
      "descriptionLabel": descriptionLabel,
      "stackView": containerStackView]
    
    // All constraints will go here
    var allConstraints: [NSLayoutConstraint] = []
    
    // Stack view constraints
    let stackVerticalConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|-[stackView]-|",
      metrics: nil,
      views: views)
    allConstraints += stackVerticalConstraints
    let stackHorizontalConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: "H:|-[stackView]-|",
      metrics: nil,
      views: views)
    allConstraints += stackHorizontalConstraints
    
    // Horizontal constraints
    let photoHorizontalConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: "V:[photoView(>=50)]",
      metrics: nil,
      views: views)
    allConstraints += photoHorizontalConstraints
    
    NSLayoutConstraint.activate(allConstraints)
    self.invalidateIntrinsicContentSize()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Setup the cell with the new data and also provide a refresh block that can be called when the download is finished
  func setup(data: PhotoRowInfo) {
    let url = URL(string: data.imageHref ?? "")
    photoView.image = nil
    if let url = url {
      let placeholder = UIImage(named: "placeholder")
      photoView.kf.indicatorType = .activity
      // Start the image fetching process which will either check the cache or download from URL
      photoView.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.2)), .scaleFactor(UIScreen.main.scale)]) { result in
        switch result {
        case .failure(let error):
          print("Error fetching the image: \(error)")
          break
        case .success(_):
          break
        }
      }
    }
    
    titleLabel.text = data.title
    descriptionLabel.text = data.description
    self.invalidateIntrinsicContentSize()
  }

}
