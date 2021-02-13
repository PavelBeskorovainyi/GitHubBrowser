//
//  RepositoryTableViewCell.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-25.
//

import UIKit
import Kingfisher

class RepositoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var repositoryName: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var starsCount: UILabel!
    @IBOutlet weak var addFavoritesButton: UIButton!
    
    @IBOutlet weak var topForksLabelAnchor: NSLayoutConstraint!
    @IBOutlet weak var topUpdateLabelAnchor: NSLayoutConstraint!
    @IBOutlet weak var bottomUpdateLabelAnchor: NSLayoutConstraint!
    @IBOutlet weak var forksLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var updateLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextViewConstraint: NSLayoutConstraint!
    

    
    private var repositoryModel: RepositoryObject?
    
    public func setRepositoryModel(with model: RepositoryObject, windowType: WindowType = .browse, searchText: String? = nil, view: Any, selector: Selector) {
        
        self.descriptionTextView.sizeToFit()
        self.descriptionTextView.isScrollEnabled = false
        
        if windowType != .search {
            repositoryName.attributedText = NSAttributedString(string: model.fullName)
            descriptionTextView.attributedText = NSAttributedString(string: model.repDescription ?? "")
        } else if let searchText = searchText {
            repositoryName.attributedText = self.higlightText(in: model.fullName, with: searchText)
            descriptionTextView.attributedText = self.higlightText(in: model.repDescription ?? "", with: searchText)
        }
        
        self.repositoryModel = model
        if model.repDescription == nil {
            descriptionTextView.frame.size.height = CGFloat(0)
            topTextViewConstraint.constant = CGFloat(0)
            topForksLabelAnchor.constant = CGFloat(0)
        }
        
        switch (model.forksCount, model.language) {
        case (nil, nil), (0, nil): languageLabel.isHidden = true
            [topForksLabelAnchor, forksLabelHeightConstraint].forEach({$0?.constant = CGFloat(0)})
        case(_, nil): languageLabel.text = "\(model.forksCount!) forks"
        case (nil, _), (0, _): languageLabel.text = "\(model.language!)"
        default: languageLabel.text = "\(model.forksCount!) forks | \(model.language!)"
        }
        
        if model.stargazersCount == nil || model.stargazersCount == 0 { starsCount.isHidden = true }
        else { starsCount.text = String(model.stargazersCount!) + "⭐️" }
        
        if model.updatedAt == nil && model.createdAt == nil {
            updateDateLabel.isHidden = true
            [bottomUpdateLabelAnchor, topUpdateLabelAnchor, updateLabelHeightConstraint].forEach({$0?.constant = CGFloat(0)})
        }
        
        var dateString = model.updatedAt
        if dateString == nil {dateString = model.createdAt}
        if let dateString = dateString {
            updateDateLabel.text = dateString.getStringDateAgo()
        } else {updateDateLabel.text = nil}
        
        if let avatarUrl = URL(string: repositoryModel?.owner.avatarUrl ?? "") {
            avatarImageView.kf.indicatorType = .activity
            avatarImageView.kf.setImage(with: avatarUrl)
        }
        
        let tapGesture = UITapGestureRecognizer(target: view, action: selector)
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
        
        
        addFavoritesButton.isHidden = windowType == .featured
    }
    
    
    private func higlightText(in inputText: String, with searchText: String) -> NSMutableAttributedString {
        let text = inputText as NSString
        let color = UIColor.red
        let attributedString = NSMutableAttributedString(string: inputText)
        var ranges = [NSRange]()
        var range = NSRange()
        
        var startLocation = 0
        repeat {
            range = text.range(of: searchText,
                               options: .caseInsensitive,
                               range: NSRange(location: startLocation, length: text.length - startLocation))
            if range.location != NSNotFound {
                startLocation = range.location + range.length
                ranges.append(range)
            }
        } while range.location != NSNotFound
        
        let attributes = [NSAttributedString.Key.foregroundColor: color]
        for range in ranges {
            attributedString.addAttributes(attributes, range: range)
        }
        
        return attributedString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc func showImage (_ completion: (_ isTapped: Bool) -> ()) {
        
    }
}
