//
//  RealmRepositoryObject.swift
//  GithubBrowser
//
//  Created by Павел Бескоровайный on 11.02.2021.
//

import Foundation
import RealmSwift

class RealmRepositoryObject: Object {
  @objc dynamic var fullName: String = ""
  @objc dynamic var repDescription: String?
  @objc dynamic var avatarUrl:  String?
  @objc dynamic var updatedAt: String?
  @objc dynamic var createdAt: String?
  var forksCount = RealmOptional<Int>()
  @objc dynamic var language: String?
  var stargazersCount = RealmOptional<Int>()
  
  override class func primaryKey() -> String? {
    return "fullName"
  }
  
  convenience init(from codableModel: RepositoryObject) {
    self.init()
    self.fullName = codableModel.fullName
    self.repDescription = codableModel.repDescription
    self.avatarUrl = codableModel.owner.avatarUrl
    self.updatedAt = codableModel.updatedAt
    self.createdAt = codableModel.createdAt
    self.forksCount = RealmOptional(codableModel.forksCount)
    self.language = codableModel.language
    self.stargazersCount = RealmOptional(codableModel.stargazersCount)
  }
}
