//
//  File.swift
//  
//
//  Created by Bibin Jacob Pulickal on 28/03/20.
//

import Foundation
import UIKit.UIImageView

let cache = NSCache<NSString, UIImage>()

public protocol URLStringConvertible {
    func asUrl() -> URL?
    func asString() -> NSString
}

extension String: URLStringConvertible {
    public func asUrl() -> URL? { URL(string: self) }
    public func asString() -> NSString { NSString(string: self) }
}

extension URL: URLStringConvertible {
    public func asUrl() -> URL? { self }
    public func asString() -> NSString { NSString(string: absoluteString) }
}

extension UIImageView {

    public func loadImage(_ url: URLStringConvertible?, alwaysFetch: Bool = false) {
        ImageLoader.loadImage(url) { [weak self] image in
            self?.image = image
        }
    }
}

public enum ImageLoader {

    static func loadImage(_ url: URLStringConvertible?, alwaysFetch: Bool = false, _ completion: @escaping (UIImage?) -> Void) {
        guard let url = url?.asUrl() else {
            completion(nil)
            return
        }
        if let image = cache.object(forKey: url.asString()) {
            completion(image)
            if alwaysFetch {
                loadImageFromNetwork(url, completion)
            }
        } else {
            loadImageFromNetwork(url, completion)
        }
    }

    private static func loadImageFromNetwork(_ url: URL, _ completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        cache.setObject(image, forKey: url.asString())
                        completion(image)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
}