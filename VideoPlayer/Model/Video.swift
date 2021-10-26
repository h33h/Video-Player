//
//  Video.swift
//  VideoPlayer
//
//  Created by XXX on 25.10.21.
//

import Foundation

struct Video: Codable {
    var description: String?
    var sources: [String]?
    var subtitle: String?
    var thumb: String?
    var title: String?
    func getThumbUrl() -> URL? {
        guard let source = sources?[0],
              let indexOfLastSlash = source.lastIndex(of: "/"),
              let thumb = thumb else { return nil }
        return URL(string: String(source.prefix(upTo: indexOfLastSlash) + "/" + thumb))
    }
}
