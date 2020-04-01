//
//  AccountsTableViewController.swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/30/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit

class AccountsTableViewController: UITableViewController {

    var accounts: TravisAccountsResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AccountTableViewCell.self)
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Organizations"
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.beginRefreshing()
        GithubService.accounts { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let result):
                self.accounts = result
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts?.accounts.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AccountTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        guard let account = accounts?.accounts[indexPath.row] else { return cell }
        cell.imageView?.load(urlString: account.avatar_url)
        cell.textLabel?.text = account.name
        cell.detailTextLabel?.text = account.login
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let account = accounts?.accounts[indexPath.row] else { return }
        guard let memberAccount = accounts?.accounts.first(where: { $0.type == "user" }) else { return }

        navigationController?.pushViewController(AddRepoTableViewController(memberName: memberAccount.login, account: account), animated: true)
    }
}

class AccountTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
