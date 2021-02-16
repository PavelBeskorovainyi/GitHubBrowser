//
//  DetailViewController.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-25.
//

import UIKit
import Down
import SafariServices

class DetailViewController: UIViewController {
    
    @IBOutlet weak var readmeTextVIew: UITextView!
    public var featuredParent: Bool?
    public var repositoryModel: RepositoryObject?
    
    var readmeUrlVariants: [String] {
        var readmeList = [String]()
        if let repositoryModel = repositoryModel {
            let basicUrl = "https://raw.githubusercontent.com/\(repositoryModel.fullName)/master/README"
            readmeList.append(basicUrl)
            readmeList.append(basicUrl + ".md")
            readmeList.append(basicUrl + ".markdown")
            readmeList.append(basicUrl + ".txt")
            readmeList.append(basicUrl + ".doc")
            readmeList.append(basicUrl + ".me")
            readmeList.append(basicUrl + ".md")
            
        }
        return readmeList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = repositoryModel?.fullName
        self.readmeTextVIew.isSelectable = false
        let addFavoritesButton = UIBarButtonItem(image: UIImage(systemName: "plus") , style: UIBarButtonItem.Style.done, target: self, action: #selector(addToFavorites))
        let openSafariButton = UIBarButtonItem(title: "Safari", style: .done, target: self, action: #selector(openSafari))
        if featuredParent == true {
            self.navigationItem.rightBarButtonItem = openSafariButton
        } else {
            self.navigationItem.rightBarButtonItems = [addFavoritesButton, openSafariButton]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getReadmeContent { [weak self] (foundedString) in
            DispatchQueue.main.async {
                self?.readmeTextVIew.attributedText = try? Down(markdownString: foundedString).toAttributedString()
            }
        }
    }
    
    private func getReadmeContent(completion: @escaping (String) -> ()) {
        for readmeUrl in readmeUrlVariants {
            if let url = URL(string: readmeUrl) {
                URLSession.shared.dataTask(with: url) { (data, response, _) in
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode != 404 {
                            let readmeContent = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                            if readmeContent.isEmpty {
                                let text = "NO TEXT FOUND"
                                completion(text)
                            } else {
                                completion(readmeContent)
                               }
                            }
                        }
                    }.resume()
                }
            }
        }
        
        @objc private func addToFavorites() {
            let alertController = UIAlertController(title: "ADD LINK TO FEATURE?", message: "", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
                guard let self = self else {return}
                if let repositoryModel = self.repositoryModel, self.repositoryModel != nil {
                    repositoryModel.putObjectToRealm()
                }
            }
            let action2 = UIAlertAction(title: "Cancel", style: .destructive ){_ in
                alertController.dismiss(animated: true)
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            self.present(alertController, animated: true)
        }
        
        @objc private func openSafari() {
            guard let fullName = self.repositoryModel?.fullName, let url = URL(string: "https://github.com/\(fullName)") else {return}
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    extension DetailViewController: SFSafariViewControllerDelegate {
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            self.navigationController?.popViewController(animated: true)
        }
    }
