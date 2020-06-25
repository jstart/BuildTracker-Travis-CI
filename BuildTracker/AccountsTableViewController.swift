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

        let header = SearchOptionView()
        header.searchAction = { [weak self] in
            self?.navigationController?.pushViewController(SearchRepoTableViewController(memberName: ""), animated: true)
        }
        tableView.tableHeaderView = header
        header.frame.size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        tableView.tableHeaderView = header
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Add a New Repo"
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
            self.tableView.refreshControl = nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts?.accounts.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AccountTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        guard let account = accounts?.accounts[indexPath.row] else { return cell }
        cell.configure(account)
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
    private let orgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        return imageView
    }()

    private let name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let login: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(orgImageView)
        orgImageView.pinEdges(to: contentView, edges: .left, inset: 15, active: true)
        orgImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        contentView.addSubview(name)
        name.pinEdges(to: contentView, edges: [.top, .right], inset: 15, active: true)
        name.leadingAnchor.constraint(equalTo: orgImageView.trailingAnchor, constant: 15).isActive = true

        contentView.addSubview(login)
        login.pinEdges(to: contentView, edges: [.right, .bottom], inset: 15, active: true)
        login.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10).isActive = true
        login.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
    }

    func configure(_ repo: TravisAccountsResponse.Account) {
        orgImageView.load(urlString: repo.avatar_url)
        name.text = repo.name
        login.text = repo.login
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SearchOptionView: UIView {
    let button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Search by Text", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.placeholderText, for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedString = NSMutableAttributedString(string: "Or\n\n\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)])
        attributedString.append(NSAttributedString(string: "Browse by Organization", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var searchAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(button)
        button.pinEdges(to: self, edges: .top, inset: 35, active: true)
        button.pinEdges(to: self, edges: [.left, .right], inset: 15, active: true)
        button.addTarget(self, action: #selector(searchByText), for: .touchUpInside)

        addSubview(label)
        label.pinEdges(to: self, edges: [.left, .bottom, .right], inset: 15, active: true)
        label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 35).isActive = true
    }

    @objc func searchByText() {
        searchAction?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
