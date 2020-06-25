//
//  RepoTableViewController .swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/30/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit

class RepoTableViewController: UITableViewController {

    var repoStore = RepoStore()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Repos"

        tableView.register(RepoBuildTableViewCell.self)
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(startEditing))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRepo))

        NotificationCenter.default.addObserver(self, selector: #selector(dismissWebView), name: .oauth, object: nil)
        guard GithubService.travisToken != nil else {
            present(GithubService.startAuthFlow, animated: true, completion: nil)
            return
        }
    }

    @objc func dismissWebView() {
        presentedViewController?.dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }

    @objc func addRepo() {
        let nav = UINavigationController(rootViewController: AccountsTableViewController())
        present(nav, animated: true, completion: nil)
    }

    @objc func startEditing() {
        setEditing(!isEditing, animated: true)
        navigationItem.leftBarButtonItem?.title = isEditing ? "Done" : "Edit"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        repoStore.refresh()
        tableView.reloadData()
        if RepoStore().repos.isEmpty {
            addRepo()
            return
        }
        GithubService.repos(ids: repoStore.ids, completion: { [weak self] response in
            switch response {
            case .success(let repos):
                self?.repoStore.update(repos.repos)
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        })

//        GithubService.reposNEW { _ in
//
//        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoStore.repos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RepoBuildTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let repo = repoStore.repos[indexPath.row]
        cell.configure(repo)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let repo = repoStore.repos[indexPath.row]
        navigationController?.pushViewController(BuildTableViewController(repo: repo), animated: true)
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        repoStore.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let repo = repoStore.repos[indexPath.row]
            repoStore.remove(repo)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

class RepoBuildTableViewCell: UITableViewCell {
    private let name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let recentBuild: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let recentBuildStatus: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return imageView
    }()

    private let disclosureIndicator: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(recentBuildStatus)
        recentBuildStatus.pinEdges(to: contentView, edges: .left, inset: 15, active: true)
        recentBuildStatus.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        contentView.addSubview(disclosureIndicator)
        disclosureIndicator.pinEdges(to: contentView, edges: .right, inset: 15, active: true)
        disclosureIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        contentView.addSubview(name)
        name.pinEdges(to: contentView, edges: .top, inset: 15, active: true)
        name.leadingAnchor.constraint(equalTo: recentBuildStatus.trailingAnchor, constant: 15).isActive = true
        name.trailingAnchor.constraint(lessThanOrEqualTo: disclosureIndicator.leadingAnchor, constant: -15).isActive = true

        contentView.addSubview(recentBuild)
        recentBuild.pinEdges(to: contentView, edges: .bottom, inset: 15, active: true)
        recentBuild.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10).isActive = true
        recentBuild.leadingAnchor.constraint(equalTo: recentBuildStatus.trailingAnchor, constant: 15).isActive = true
        recentBuild.trailingAnchor.constraint(lessThanOrEqualTo: disclosureIndicator.leadingAnchor, constant: -15).isActive = true
    }

    func configure(_ repo: TravisReposResponse.Repo) {
        name.text = repo.slug
        recentBuild.text = repo.durationText

        var imageName = "checkmark.circle.fill"
        recentBuildStatus.tintColor = .green
        if repo.last_build_state == "started" || repo.last_build_state == "created" {
            imageName = ""
            let activity = UIActivityIndicatorView(style: .medium)
            recentBuildStatus.addSubview(activity)
            activity.startAnimating()
        } else if repo.last_build_state != "passed" {
            imageName = "exclamationmark.triangle.fill"
            recentBuildStatus.tintColor = .red
        }
        let boldConfig = UIImage.SymbolConfiguration(weight: .bold).applying(UIImage.SymbolConfiguration(textStyle: .headline))
        recentBuildStatus.image = UIImage(systemName: imageName, withConfiguration:  boldConfig)?.withRenderingMode(.alwaysTemplate)
    }

    @objc func showAll() {

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
