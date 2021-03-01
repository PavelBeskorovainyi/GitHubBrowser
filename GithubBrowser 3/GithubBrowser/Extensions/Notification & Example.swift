//
//  Notification & Example.swift
//  GithubBrowser
//
//  Created by Павел Бескоровайный on 11.02.2021.
//

import Foundation

extension Notification.Name {
  static let created = Notification.Name("created")
}

extension Notification.Name {
  func post(center: NotificationCenter = NotificationCenter.default,
            object: Any? = nil,
            userInfo: [AnyHashable : Any]? = nil) {
    center.post(name: self, object: object, userInfo: userInfo)
  }
  
  @discardableResult
  func onPost(center: NotificationCenter = NotificationCenter.default,
              object: Any? = nil, queue: OperationQueue? = nil,
              using: @escaping (Notification) -> Void) -> NSObjectProtocol {
    return center.addObserver(forName: self, object: object,
                              queue: queue, using: using)
  }
}

extension Notification {
  static func removeObservers(observers: [Any], center: NotificationCenter = NotificationCenter.default) {
    for observer in observers {
      center.removeObserver(observer)
    }
  }
}
