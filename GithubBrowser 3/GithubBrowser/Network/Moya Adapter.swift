//
//  Moya Adapter.swift
//  GithubBrowser
//
//  Created by Track Ensure on 2021-03-01.
//

import Foundation
import PromiseKit
import Moya

struct Provider {
    static private let provider = MoyaProvider<RequestTarget>()
    
    static func getDataFromServerWithParameters(page: Int, searchText: String? = nil) -> Promise<[RepositoryObject]> {
        return Promise { seal in
            provider.request(.requestWithParameters(page: page, searchText: searchText)) {
                result in
                switch result {
                case .success(let response):
                    do {
                        let gitPages = try JSONDecoder().decode([RepositoryObject].self, from: response.data)
                        seal.fulfill(gitPages)
                    } catch let error {
                        debugPrint(error.localizedDescription)
                        seal.reject(error)
                    }
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    seal.reject(error)
                }
            }
        }
    }
}
