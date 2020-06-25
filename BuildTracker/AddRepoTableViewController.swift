//
//  AddRepoTableViewController.swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/30/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit

class AddRepoTableViewController: UITableViewController {

    var memberName: String
    var account: TravisAccountsResponse.Account
    var activeRepos: [TravisReposResponse.Repo]?
    var repos: [TravisReposResponse.Repo]?

    init(memberName: String, account: TravisAccountsResponse.Account) {
        self.memberName = memberName
        self.account = account
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RepoTableViewCell.self)
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = ""
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.beginRefreshing()

        GithubService.searchRepos(query: account.login) { [weak self] response in
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
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.refreshControl = nil
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return section == 0 ? "Active" : "Inactive"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return activeRepos?.count ?? 0
        }
        return repos?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RepoTableViewCell = tableView.dequeueReusableCell(for: indexPath)
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

class RepoTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        detailTextLabel?.numberOfLines = 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
}
