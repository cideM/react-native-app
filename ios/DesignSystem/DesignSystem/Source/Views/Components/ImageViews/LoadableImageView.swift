//
//  LoadableImageView.swift
//  Common
//
//  Created by Manaf Alabd Alrahim on 18.10.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class LoadableImageView: UIImageView {
    private var isCancelled = false
    private var task: URLSessionDataTask?
    public func loadImage(from url: URL) {
        isCancelled = false
        let request = URLRequest(url: url)
        self.task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            DispatchQueue.main.async { [weak self] in
                if let self, let data {
                    if !self.isCancelled {
                        self.image = UIImage(data: data)
                    }
                }
            }
        }
        self.task?.resume()
    }

    public func cancel() {
        isCancelled = true
        self.task?.cancel()
    }
}
