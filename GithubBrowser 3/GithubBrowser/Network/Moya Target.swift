//
//  Moya Target.swift
//  GithubBrowser
//
//  Created by Track Ensure on 2021-03-01.
//

import Foundation
import Moya

enum RequestTarget {
    case requestWithParameters(page: Int, searchText: String?)
}

extension RequestTarget: TargetType {
    var baseURL: URL {
        let uRL = URL(string: "https://api.github.com/")
        return uRL!
    }
    
    var path: String {
        switch self {
        case .requestWithParameters:
            return "repositories"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        var parameters = [String:Any]()
        switch self {
        case .requestWithParameters(let page, let searchText):
            parameters["per_page"] = 100
            parameters["since"] = page
            if searchText != nil {
                parameters["q"] = searchText
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
