//
//  BuildTableViewController.swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/30/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit

class BuildTableViewController: UITableViewController {

    let repo: TravisReposResponse.Repo

    var builds: [TravisBuildsResponse.Build]?

    init(repo: TravisReposResponse.Repo) {
        self.repo = repo
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = repo.slug

        tableView.register(BuildTableViewCell.self)
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        if RepoStore().contains(repo) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRepo))
        }

        refresh()
    }

    @objc func remove() {
        RepoStore().remove(repo)
        navigationController?.popViewController(animated: true)
    }

    @objc func refresh() {
        tableView.refreshControl?.beginRefreshing()
        GithubService.buildStatus(repoSlug: repo.slug, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.builds = response.builds
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
            self.tableView.refreshControl?.endRefreshing()
        })
    }

    @objc func addRepo() {
        RepoStore().add(repo)
        // UITabBarController doesn't forward viewWillAppear when this VC is dismissed AFAIK
        ((presentingViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.viewControllers.last?.viewWillAppear(true)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return builds?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BuildTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        guard let build = builds?[indexPath.row] else { return cell }
        cell.textLabel?.text = (build.pull_request_title ?? "Triggered by \(build.event_type)")
        cell.detailTextLabel?.text = build.durationText + ", " + build.finishedText
        let boldConfig = UIImage.SymbolConfiguration(weight: .bold).applying(UIImage.SymbolConfiguration(textStyle: .headline))

        var imageName = "checkmark.circle.fill"
        cell.tintColor = .green

        if build.state != "passed" {
            imageName = "exclamationmark.triangle.fill"
            cell.tintColor = .red
        }
        cell.accessoryView = UIImageView(image: UIImage(systemName: imageName, withConfiguration:  boldConfig)?.withRenderingMode(.alwaysTemplate))

        if build.state == "started" {
            let activity = UIActivityIndicatorView(style: .medium)
            cell.accessoryView = activity
            activity.startAnimating()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let build = builds?[indexPath.row] else { return }
        UIApplication.shared.open(URL(string: "https://travis-ci.com/github/\(repo.slug)/builds/\(build.id)")!, options: [:], completionHandler: nil)
    }
}

class BuildTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
