//
//  FirstViewController.swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/30/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit

class BuildTableViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard GithubService.builds == nil else {
            for (index, build) in GithubService.builds!.builds.enumerated() {
                let label = UILabel(frame: CGRect(x: 0, y: index * 20, width: 400, height: 20))
                label.text = build.pull_request_title
                view.addSubview(label)
            }
            return
        }
        present(GithubService.startAuthFlow, animated: true, completion: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissWebView), name: .oauth, object: nil)

    }

    @objc func dismissWebView() {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
