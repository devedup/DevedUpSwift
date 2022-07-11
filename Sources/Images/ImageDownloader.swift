//
//  File.swift
//  
//
//  Created by David Casserly on 11/07/2022.
//

import Foundation
import UIKit

struct ImageDownloadError: Error {}

public actor ImageDownloader {
    
    private enum CacheEntry {
        case inProgress(Task<UIImage, Error>)
        case ready(UIImage)
    }
    
    private var cache: [URL: CacheEntry] = [:]
    
    func cancel(url: URL) {
        if let cached = cache[url] {
            switch cached {
            case .ready(_):
                break // too late...
            case .inProgress(let task):
                cache[url] = nil
                task.cancel()
            }
        }
    }
    
    func image(from url: URL) async throws -> UIImage? {
        if let cached = cache[url] {
            switch cached {
            case .ready(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        let task = Task {
            try await downloadImage(from: url)
        }
        
        cache[url] = .inProgress(task)
        
        do {
            let image = try await task.value
            cache[url] = .ready(image)
            return image
        } catch {
            cache[url] = nil
            throw error
        }
    }
    
    private func downloadImage(from url: URL) async throws -> UIImage {
        if #available(iOS 15.0, *) {
            let fetchTask = Task { () -> UIImage in
                let (data, _) = try await URLSession.shared.data(from: url)
                try Task.checkCancellation()
                if let image = UIImage(data: data) {
                    return image
                } else {
                    throw ImageDownloadError()
                }
            }
            return try await fetchTask.value
        } else {
            preconditionFailure("We're not using this yet... it's for the future")
        }
    }
    
}
