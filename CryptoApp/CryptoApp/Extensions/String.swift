//
//  String.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 18/03/2025.
//

import Foundation

extension String {
    var asFormattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        guard let date = dateFormatter.date(from: self) else { return self }
        
        let shortFormatter = DateFormatter()
        shortFormatter.dateStyle = .short
        return shortFormatter.string(from: date)
    }
}
