//
//  SearchViewController.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-25.
//

import UIKit
import NVActivityIndicatorView

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noResultImageView: UIImageView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    private var repositoryDataSourse = [RepositoryObject]()
    private var searchTimer: Timer?
    private var selectedIndex: IndexPath?
    private var arrowImage = UIImageView(image: UIImage(named: "arrow"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: cellIndentifier)
        tableView.estimatedRowHeight = 50
        
        self.noResultImageView.image = UIImage(named: "noResult")
        self.noResultImageView.frame.size = self.tableView.frame.size
        self.noResultImageView.center = self.view.center
        
        self.noResultImageView.contentMode = .center
        self.noResultImageView.isHidden = true
        
        self.activityIndicator.type = .ballBeat
        self.activityIndicator.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.height / 2 - self.view.frame.height / 6, width: self.view.frame.width, height: self.view.frame.height / 3)
        self.activityIndicator.color = .systemRed
        self.activityIndicator.isHidden = true
        self.activityIndicator.contentMode = .topLeft
        
        self.view.addSubview(arrowImage)
        self.arrowImage.frame.size.width = self.view.frame.size.width
        self.arrowImage.frame.size.height = self.view.frame.size.height / 2
        self.arrowImage.frame.origin = CGPoint(x: self.tableView.frame.origin.x, y: 150)
        self.arrowImage.contentMode = .redraw
        self.arrowImage.isHidden = false
        self.tableView.isHidden = true
        
        registerKeyboardNotifications ()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController, let selectedIndex = selectedIndex,
           self.repositoryDataSourse.indices.contains(selectedIndex.row) {
            vc.repositoryModel = self.repositoryDataSourse[selectedIndex.row]
        }
    }
    deinit {
        removeKeyboardNotifications()
    }
    private func getAllData(with text: String) {
        if let text = text.applyingTransform(.toLatin, reverse: false) {
            RepositoryObject.performRequest(with: .getSearchResult(searhText: text)) { [weak self] (isSuccess, response) in
                guard let self = self else {return}
                
                if isSuccess {
                    if response.count == 0 {
                        DispatchQueue.main.async {
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                            self.noResultImageView.isHidden = false
                            self.tableView.isHidden = true
                            self.arrowImage.isHidden = true
                        }
                    } else {
                        self.repositoryDataSourse = response
                        DispatchQueue.main.async {
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                            self.noResultImageView.isHidden = true
                            self.tableView.isHidden = false
                            self.tableView.reloadData()
                            self.arrowImage.isHidden = true
                        }
                    }
                } else {
                    self.repositoryDataSourse.removeAll()
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        self.noResultImageView.isHidden = false
                        self.tableView.isHidden = true
                        self.arrowImage.isHidden = true
                    }
                }
            }
        }
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
//MARK:- Keyboard appereance
extension SearchViewController {
    private func registerKeyboardNotifications () {
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
  @objc private func keyboardWillShow (_ notification: Notification) {
        let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardFrame.cgRectValue.height
//        tableView.contentOffset = CGPoint(x: 0, y: keyboardHeight + self.additionalSafeAreaInsets.bottom + (self.tabBarController?.accessibilityFrame.height ?? CGFloat(0)))
//      tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: keyboardHeight).isActive = true
//    tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - keyboardHeight), animated: true)
    tableView.scrollRectToVisible(CGRect(origin: CGPoint(x: self.tableView.frame.minX, y: self.tableView.frame.minY - keyboardHeight) ,
                                         size: self.tableView.frame.size), animated: true)
        arrowImage.isHidden = true
        tableView.isHidden = false
        self.searchBar.becomeFirstResponder()
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        self.searchBar.resignFirstResponder()
    }
    
    private func removeKeyboardNotifications () {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
}

//MARK: - table view etxension
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryDataSourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as? RepositoryTableViewCell {
            cell.setRepositoryModel(with: self.repositoryDataSourse[indexPath.row], windowType: .search, searchText: self.searchBar.text,  view: self, selector: #selector(presentImage(_:)))
            cell.addFavoritesButton.tag = indexPath.row
            cell.addFavoritesButton.addTarget(self, action: #selector(addFavoritesButtonPressed(_:)), for: .touchUpInside)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.searchBar.resignFirstResponder()
        self.selectedIndex = indexPath
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
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
//MARK: - searchbar extension
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let badLetters = ["ш", "щ", "ж", "я", "ч", "ь", "э", "ю", "ё", "ъ"]
        for ch in badLetters {
            if !searchText.lowercased().contains(ch) {
                if searchText.count >= 1 {
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = false
                        self.activityIndicator.startAnimating()
                        self.tableView.isHidden = true
                        self.arrowImage.isHidden = true
                    }
                    self.searchTimer?.invalidate()
                    self.searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] (_) in
                        self?.getAllData(with: searchText.lowercased())
                    })
                } else {
                    self.searchTimer?.invalidate()
                    self.repositoryDataSourse.removeAll()
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        self.tableView.isHidden = true
                        self.arrowImage.isHidden = false
                        self.noResultImageView.isHidden = true
                    }
                }
            } else {
                self.repositoryDataSourse.removeAll()
                self.getAllData(with: "")
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
}

