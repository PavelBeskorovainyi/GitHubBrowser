//
//  ViewController.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-22.
//

import UIKit
import Kingfisher

class RecentViewController: UIViewController {
    
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl: UIRefreshControl?
    private var selectedIndex: IndexPath?
    private var selectedImageIndex: IndexPath?
    private var repositoryDataSourse = [RepositoryObject]()
    private var tapGesture = UITapGestureRecognizer(target: self, action: #selector(showImage))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: cellIndentifier)
        tableView.estimatedRowHeight = 70
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(getAllData), for: .valueChanged)
        tableView.refreshControl = self.refreshControl
        
        refreshControl?.beginRefreshing()
        getAllData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController, let selectedIndex = selectedIndex,
           self.repositoryDataSourse.indices.contains(selectedIndex.row) {
            vc.repositoryModel = self.repositoryDataSourse[selectedIndex.row]
        }
    }
    
    @objc private func getAllData() {
        RepositoryObject.performRequest(with: .getAll) { [weak self] (isSuccess, response) in
            guard let self = self else {return}
            if isSuccess {
                self.repositoryDataSourse = response
            }
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                if isSuccess { self.tableView.reloadData() }
            }
        }
    }
    @objc public func presentImage(_ tap: UITapGestureRecognizer){
        let location = tap.location(in: tableView)
        if let tapIndexPath = tableView.indexPathForRow(at: location){
            let vc = AvatarImageViewController.createFromStoryboard()
                vc.avatarRepositoryModel = repositoryDataSourse[tapIndexPath.row]
                 navigationController?.pushViewController(vc, animated: true)
        }
    }

}


extension RecentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryDataSourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as? RepositoryTableViewCell {
            cell.setRepositoryModel(with: self.repositoryDataSourse[indexPath.row], windowType: .browse, view: self, selector: #selector(presentImage(_:)))
            
            cell.addFavoritesButton.tag = indexPath.row
            cell.addFavoritesButton.addTarget(self, action: #selector(addFavoritesButtonPressed(_:)), for: .touchUpInside)
            cell.avatarImageView.tag = indexPath.row
            
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = indexPath
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    @objc func showImage () {
        let vc = AvatarImageViewController.createFromStoryboard()
        self.present(vc, animated: true)
    }
    
    @objc private func addFavoritesButtonPressed(_ sender: UIButton?) {
        
        let alertController = UIAlertController(title: "ADD LINK TO FEATURE?", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self = self else {return}
            if let index = sender?.tag, self.repositoryDataSourse.indices.contains(index) {
                self.repositoryDataSourse[index].putObjectToRealm()
            }
        }
        let action2 = UIAlertAction(title: "Cancel", style: .destructive ){_ in
            alertController.dismiss(animated: true)
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        self.present(alertController, animated: true)
        
    }
}

