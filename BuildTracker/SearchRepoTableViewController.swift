//
//  SearchRepoTableViewController.swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/30/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit

class SearchRepoTableViewController: UITableViewController, UISearchBarDelegate {

    var memberName: String
    var activeRepos: [TravisReposResponse.Repo]?
    var repos: [TravisReposResponse.Repo]?

    var searchBar: UISearchBar?
    var searching = false

    init(memberName: String) {
        self.memberName = memberName
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RepoTableViewCell.self)
        tableView.tableFooterView = UIView()

        searchBar = UISearchBar(frame: CGRect(x: 10, y: 0, width: view.frame.width, height: 80))
        searchBar?.autocapitalizationType = .none
        searchBar?.delegate = self
        tableView.tableHeaderView = searchBar

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = ""
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searching = true
        tableView.reloadData()
        GithubService.searchRepos(query: searchBar.text ?? "") { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let result):
                self.activeRepos = result.repos.filter { $0.active == true }
                self.repos = result.repos.filter { $0.active == false || $0.active == nil }
                self.activeRepos?.sort(by: { first, second in
                    guard let firstStarted = first.last_build_started_at else { return false }
                    guard let secondStarted = second.last_build_started_at else { return false }

                    return firstStarted > secondStarted
                })
            case .failure(let error):
                print(error)
            }
            self.searching = false
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return searching ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searching {
            return nil
        }
        return section == 0 ? "Active" : "Inactive"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return 1
        }
        if section == 0 {
            return activeRepos?.count ?? 0
        }
        return repos?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RepoTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if searching {
            cell.textLabel?.text = "Searching..."
            let activity = UIActivityIndicatorView(style: .medium)
            cell.accessoryView = activity
            activity.startAnimating()
            return cell
        }
        switch indexPath.section {
        case 0:
            guard let repo = activeRepos?[indexPath.row] else { return cell }
            cell.textLabel?.text = repo.slug
            cell.detailTextLabel?.text = repo.description
        case 1:
            guard let repo = repos?[indexPath.row] else { return cell }
            cell.textLabel?.text = repo.slug
            cell.detailTextLabel?.text = repo.description
        default:
            fatalError()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard searching == false else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        var repo: TravisReposResponse.Repo?
        switch indexPath.section {
        case 0:
            repo = activeRepos?[indexPath.row]
        case 1:
            repo = repos?[indexPath.row]
        default:
            fatalError()
        }
        guard let currentRepo = repo else { return }
        navigationController?.pushViewController(BuildTableViewController(repo: currentRepo), animated: true)
    }
}
