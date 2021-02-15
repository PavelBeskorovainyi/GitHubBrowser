//
//  RepositoryObject.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-22.
//

import Foundation
import RealmSwift

struct SearchResults: Codable {
  var totalCount: Int
  var incompleteResults: Bool
  var items: [RepositoryObject]
  
  enum CodingKeys: String, CodingKey {
    case items
    case totalCount = "total_count"
    case incompleteResults = "incomplete_results"
  }
}

class RepositoryObject: Codable {
  var fullName: String
  var repDescription: String?
  var owner: Owner
  var updatedAt: String?
  var createdAt: String?
  var forksCount: Int?
  var language: String?
  var stargazersCount: Int?
  
  enum CodingKeys: String, CodingKey {
    case owner, language
    case fullName = "full_name"
    case repDescription = "description"
    case updatedAt = "updated_at"
    case createdAt = "created_at"
    case forksCount = "forks_count"
    case stargazersCount = "stargazers_count"
  }
  
  init(from realm: RealmRepositoryObject) {
    self.fullName = realm.fullName
    self.repDescription = realm.repDescription
    self.updatedAt = realm.updatedAt
    self.owner = Owner(avatarUrl: realm.avatarUrl)
    self.createdAt = realm.createdAt
    self.forksCount = realm.forksCount.value
    self.language = realm.language
    self.stargazersCount = realm.stargazersCount.value
  }
  
  func putObjectToRealm(){
    let realm = try! Realm()
    let realmObject = RealmRepositoryObject(from: self)
    try! realm.write({
        realm.add(realmObject, update: .all)
    })
  }
    func deleteObject(){
        let realm = try! Realm()
        let realmObject = RealmRepositoryObject(from: self)
        try! realm.write({
            realm.add(realmObject, update: .all)
            realm.delete(realmObject)
        })
    }

  
  static func performRequest(with requestType: RequestType = .getAll, completion: @escaping (_ isSuccess: Bool, _ response: [RepositoryObject]) -> ()) {
    var repStringURL = ""
    switch requestType {
    case .getAll: repStringURL = "https://api.github.com/repositories?since=1&per_page=100"
    case .getSearchResult(let searhText): repStringURL = "https://api.github.com/search/repositories?q=\(searhText)&page=1&per_page=100"
    }
    
    guard let repURL = URL(string: repStringURL) else {return}
    
    URLSession.shared.dataTask(with: repURL) { (data, response, error) in
      var result = [RepositoryObject]()
      guard data != nil else {
        print("NO DATA")
        completion(false, result)
        return
      }
            
      guard error == nil else {
        print(error!.localizedDescription)
        completion(false, result)
        return
      }
      
      do {
        switch requestType {
        case .getAll: result = try JSONDecoder().decode([RepositoryObject].self, from: data!)
        case .getSearchResult(_): result = try JSONDecoder().decode(SearchResults.self, from: data!).items
        }
        print(result.count)
        completion(true, result)
      } catch {
        print(error.localizedDescription)
        completion(false, result)
      }
    }.resume()
  }
}

struct Owner: Codable {
  var avatarUrl: String?
  
  enum CodingKeys: String, CodingKey {
    case avatarUrl = "avatar_url"
  }
}

enum RequestType {
  case getAll
  case getSearchResult(searhText: String)
}

enum WindowType {
  case browse
  case search
  case featured
}
