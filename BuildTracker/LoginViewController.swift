//
//  LoginViewController.swift
//  BuildTracker
//
//  Created by Christopher Truman on 4/2/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit
import SwiftUI

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
        label.text = "The app needs GitHub access to retrieve the repositories and build information about your Travis CI enabled projects."
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

        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(mockLogin))
        tapGesture.numberOfTouchesRequired = 2
        textButton.addGestureRecognizer(tapGesture)

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

    @objc func mockLogin() {
        GithubService.githubToken = GithubAccessTokenResponse(access_token: "e54f79677478efc6de07c3f203595ae6a74ecf36", token_type: "bearer", scope: "read:org,repo,user:email")
        GithubService.travisToken = TravisAccessTokenResponse(access_token: "2yDoD5ZZ9lUI4C6UihRSmQ")
        NotificationCenter.default.post(name: .oauth, object: nil)
    }

    @objc func dismissWebView() {
        guard !(presentedViewController is UITabBarController) else { return }
        guard let presented = presentedViewController else {
            presentMainVC()
            return
        }
        presented.dismiss(animated: true, completion: { [weak self] in
            self?.presentMainVC()
        })
    }

    func presentMainVC() {
        let tabVC = UIStoryboard.init(name: "Main", bundle: .main).instantiateViewController(identifier: "MainTabBarController")
        tabVC.modalPresentationStyle = .fullScreen
        present(tabVC, animated: true)
    }
}

// MARK: SwiftUI Preview
#if DEBUG
struct LoginViewControllerContainerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = LoginViewController

    func makeUIViewController(context: Context) -> UIViewControllerType {
        return LoginViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct LoginViewController_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginViewControllerContainerView().colorScheme(.light)
            LoginViewControllerContainerView().environment(\.sizeCategory, .accessibilityLarge).previewDevice("iPad (7th generation)").preferredColorScheme(.dark)
        }.previewLayout(.device)

    }
}
#endif
