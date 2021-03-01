//
//  FeaturedViewController.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-25.
//

import UIKit
import RealmSwift

class FeaturedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var repositoryDataSourse = [RepositoryObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: cellIndentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllData()
    }
    
    func getAllData() {
      let realm = try! Realm()
      let storedData = realm.objects(RealmRepositoryObject.self)
      self.repositoryDataSourse.removeAll()
      for stored in storedData {
        self.repositoryDataSourse.append(RepositoryObject(from: stored))
      }
      self.tableView.reloadData()
    }
    
}

extension FeaturedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryDataSourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as? RepositoryTableViewCell {
            cell.setRepositoryModel(with: self.repositoryDataSourse[indexPath.row], windowType: .featured,  view: self, selector: #selector(presentImage(_:)))
            return cell
        }
        return UITableViewCell()
    }
    
    @objc public func presentImage(_ tap: UITapGestureRecognizer){
        let location = tap.location(in: tableView)
        if let tapIndexPath = tableView.indexPathForRow(at: location){
            let controller = AvatarImageViewController.createFromStoryboard()
                controller.avatarRepositoryModel = repositoryDataSourse[tapIndexPath.row]
                 navigationController?.pushViewController(controller, animated: true)
        }
    }
}
