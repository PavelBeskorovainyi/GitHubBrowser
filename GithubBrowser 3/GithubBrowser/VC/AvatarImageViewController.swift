//
//  AvatarImageViewController.swift
//  GithubBrowser
//
//  Created by Павел Бескоровайный on 11.02.2021.
//

import UIKit
import Kingfisher

class AvatarImageViewController: UIViewController, StoryboardInitializable {
    
    var imageScrollView: ImageScrollView?
    var avatarRepositoryModel: RepositoryObject?
    
    var imageAvatar = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageScrollView = ImageScrollView(frame: self.view.bounds)
        self.view.addSubview(imageScrollView!)
        self.setupImageScrollView()

        if let avatarUrl = URL(string: avatarRepositoryModel?.owner.avatarUrl ?? "") {
            imageAvatar.kf.indicatorType = .activity
            imageAvatar.kf.setImage(with: avatarUrl)
        }
        imageScrollView?.set(image: imageAvatar.image ?? UIImage())
        self.title = avatarRepositoryModel?.fullName
        self.imageScrollView?.zoom(to: CGRect(origin: CGPoint(
                                                x: self.imageScrollView!.contentSize.width / 2 - self.view.frame.size.width / 2,
                                                y: self.imageScrollView!.contentSize.height / 2 - self.view.frame.size.height / 2),
                                              size: CGSize(width: 200, height: 200)), animated: false)
    }
    
    private func setupImageScrollView() {
        imageScrollView?.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        imageScrollView?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        imageScrollView?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        imageScrollView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        imageScrollView?.contentOffset = self.view.center
        imageScrollView?.center = self.view.center
    }
}
