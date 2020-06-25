//
//  LoginViewController.swift
//  BuildTracker
//
//  Created by Christopher Truman on 4/2/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "github"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 64).isActive = true
        button.heightAnchor.constraint(equalToConstant: 64).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let textButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.setTitle("Login with GitHub", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.placeholderText, for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let text: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "The app needs GitHub access to retreive the repositories and build information about your Travis CI enabled projects."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard GithubService.travisToken == nil else {
            
//            tabBar.heightAnchor.constraint(equalToConstant: 83).isActive = true
            return
        }
        NotificationCenter.default.addObserver(self, selector: #selector(dismissWebView), name: .oauth, object: nil)

        view.addSubview(loginButton)
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)

        view.addSubview(textButton)
        textButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 25).isActive = true
        textButton.addTarget(self, action: #selector(login), for: .touchUpInside)

        view.addSubview(text)
        text.pinEdges(to: view.safeAreaLayoutGuide, edges: [.left, .right], inset: 40, active: true)
        text.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        text.topAnchor.constraint(equalTo: textButton.bottomAnchor, constant: 25).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard GithubService.travisToken == nil else {
            let tabVC = UIStoryboard.init(name: "Main", bundle: .main).instantiateViewController(identifier: "MainTabBarController")
            tabVC.modalPresentationStyle = .fullScreen
            present(tabVC, animated: false)
            return
        }
    }

    @objc func login() {
        present(GithubService.startAuthFlow, animated: true, completion: nil)
    }

    @objc func dismissWebView() {
        presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            let tabVC = UIStoryboard.init(name: "Main", bundle: .main).instantiateViewController(identifier: "MainTabBarController")
            tabVC.modalPresentationStyle = .fullScreen
            self?.present(tabVC, animated: true)
        })
    }
}
