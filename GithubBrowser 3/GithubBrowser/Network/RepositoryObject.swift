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
