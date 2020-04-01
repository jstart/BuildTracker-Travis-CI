//
//  Image.swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/31/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit

extension UIImageView {
    func load(urlString: String?) {
        guard let url = URL(string: urlString ?? "") else { return}
        alpha = 0.0

        image = UIImage(systemName: "person.crop.circle", withConfiguration: UIImage.SymbolConfiguration(textStyle: .largeTitle))
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data else { return }
            let networkImage = UIImage(data: data)
            DispatchQueue.main.async { [weak self] in
                self?.image = networkImage
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.alpha = 1.0
                })
            }
        }).resume()
    }
}
