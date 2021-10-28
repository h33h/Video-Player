//
//  VideoService.swift
//  VideoPlayer
//
//  Created by XXX on 25.10.21.
//

import Foundation

class VideoService {
    func getJsonData(completion: @escaping (Category?) -> Void) {
        var jsonFileString = ""
        let dir = Bundle.main.bundleURL
        let fileURL = dir.appendingPathComponent("json.txt")
        do {
            jsonFileString = try String(contentsOf: fileURL, encoding: .utf8)
        } catch { print(error.localizedDescription) }
        let decoder = JSONDecoder()
        let jsonData = Data(jsonFileString.utf8)
        let response = try? decoder.decode(JsonResponse.self, from: jsonData )
        guard let category = response?.categories?[0] else { return completion(nil) }
        completion(category)
    }
}
