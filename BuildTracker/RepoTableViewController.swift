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

        tableView.register(RepoTableViewCell.self)
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
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoStore.repos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RepoTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let repo = repoStore.repos[indexPath.row]
        cell.textLabel?.text = repo.slug
        cell.detailTextLabel?.text = repo.description
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
