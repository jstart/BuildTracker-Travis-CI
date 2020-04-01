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
        GithubService.repos(owner: account.login, memberName: memberName) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let result):
                self.repos = result.repos
                self.repos?.sort(by: {first, second in
                    return first.last_build_started_at != nil
                })
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.refreshControl?.isEnabled = false
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RepoTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        guard let repo = repos?[indexPath.row] else { return cell }
        cell.textLabel?.text = repo.slug
        cell.detailTextLabel?.text = repo.description
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let repo = repos?[indexPath.row] else { return }
        navigationController?.pushViewController(BuildTableViewController(repo: repo), animated: true)
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
}
