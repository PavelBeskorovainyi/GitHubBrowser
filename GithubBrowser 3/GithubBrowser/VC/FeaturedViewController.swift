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
    private var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: cellIndentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        self.editButtonItem.action = #selector(edit)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    @objc private func edit() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            self.editButtonItem.title = "Done"
        } else {
            self.editButtonItem.title = "Edit"
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController, let selectedIndex = selectedIndex,
           self.repositoryDataSourse.indices.contains(selectedIndex.row) {
            vc.repositoryModel = self.repositoryDataSourse[selectedIndex.row]
            vc.featuredParent = true
        }
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.repositoryDataSourse[indexPath.row].deleteObject()
            self.repositoryDataSourse.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = indexPath
        self.performSegue(withIdentifier: "showDetail", sender: self)
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
