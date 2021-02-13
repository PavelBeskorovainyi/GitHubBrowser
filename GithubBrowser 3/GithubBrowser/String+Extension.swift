//
//  String+Extension.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-27.
//

import Foundation

extension String {
  func getStringDateAgo() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    if let date = dateFormatter.date(from: self) {
      var resultUpdatesAgo = "Updated "
      var difference : (years:Int, days:Int, hours:Int) = (0,0,0)
      
      if let years = Calendar.current.dateComponents([.year], from: date, to: Date()).year,
         let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day,
         let hours = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour {
        difference = (years:years, days:days, hours:hours)
      }
      switch difference {
      case (let year,_,_) where year == 1: resultUpdatesAgo += "a year ago"
      case (let year,_,_) where year > 1: resultUpdatesAgo += "\(year) years ago"
      case (_,let day,_) where day == 1: resultUpdatesAgo += "a day ago"
      case (_,let day,_) where day > 1: resultUpdatesAgo += "\(day) days ago"
      case (_,_,let hour) where hour == 1: resultUpdatesAgo += "an hour ago"
      case (_,_,let hour) where hour > 1: resultUpdatesAgo += "\(hour) hours ago"
      default:
        resultUpdatesAgo = ""
      }
      return resultUpdatesAgo
    }
    return nil
  }
}
