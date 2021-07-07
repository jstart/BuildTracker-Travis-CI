//
//  SettingsTableViewController.swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/30/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit
import MessageUI

private enum SettingsSection: Int, CaseIterable {
    case account
//    case preferences
    case information
    case version

    var title: String {
        switch self {
        case .account:
            return "ACCOUNT"
//        case .preferences:
//            return "PREFERENCES"
        case .information:
            return "INFORMATION"
        case .version:
            return "Version: \(AppInfo.appVersion), Build: \(AppInfo.build)"
        }
    }

    var numberOfRows: Int {
        switch self {
        case .account:
            return Account.allCases.filter { $0.shouldShow }.count
//        case .preferences:
//            return Preferences.allCases.count
        case .information:
            return Information.allCases.count
        case .version:
            return 0
        }
    }
}

private enum Account: Int, CaseIterable {
    case signIn
    case signOut

    var title: String {
        switch self {
        case .signIn:
            return "Sign In"
        case .signOut:
            guard let login = GithubService.userAccount?.login else { return "Sign Out"}
            return "\(login) - Sign Out"
        }
    }

    var shouldShow: Bool {
        switch self {
        case .signIn:
            return GithubService.travisToken == nil
        case .signOut:
            return GithubService.travisToken != nil
        }
    }

    var accessoryView: UIImageView {
        switch self {
        default:
            return UIImageView(image: UIImage(systemName: "chevron.right"))
        }
    }
}

private enum Preferences: Int, CaseIterable {
    case toggle

    var accessoryView: UISwitch {
        switch self {
        default:
            return UISwitch()
        }
    }
}

private enum Information: Int, CaseIterable {
    case travisStatus
    case sendFeedback
    case twitter

    var title: String {
        switch self {
        case .travisStatus:
            return "Check Travis CI Status (traviscistatus.com)"
        case .sendFeedback:
            return "Send Feedback via Email"
        case .twitter:
            return "Find me on Twitter @iAmChrisTruman"
        }
    }

    var accessoryView: UIImageView {
        switch self {
        default:
            return UIImageView(image: #imageLiteral(resourceName: "arrowRight"))
        }
    }
}

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(dismissWebView), name: .oauth, object: nil)
        tableView.register(UITableViewCell.self)
    }

    @objc func dismissWebView() {
        presentedViewController?.dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = SettingsSection(rawValue: section) else { return "" }
        return section.title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        return section.numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }

        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier)!

        switch section {
        case .account:
            let accountItems = Account.allCases.filter { $0.shouldShow }
            let row = accountItems[indexPath.row]
            cell.textLabel?.text = row.title
            cell.accessoryView = row.accessoryView
//        case .preferences:
//            guard let row = Preferences(rawValue: indexPath.row) else { return UITableViewCell() }
//            cell.textLabel?.text = row.title
//            cell.accessoryView = row.accessoryView
        case .information:
            let row = Information.allCases[indexPath.row]
            cell.textLabel?.text = row.title
        case .version:
            return UITableViewCell()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        switch section {
        case .account:
            let accountItems = Account.allCases.filter { $0.shouldShow }
            let row = accountItems[indexPath.row]

            switch row {
            case .signIn:
                present(GithubService.startAuthFlow, animated: true, completion: nil)
            case .signOut:
                GithubService.logout()
                RepoStore().removeAll()
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }

//        case .preferences:
//            break
        case .information:
            let row = Information.allCases[indexPath.row]

            switch row {
            case .travisStatus:
                UIApplication.shared.open(URL(string:"https://www.traviscistatus.com/")!)
            case .sendFeedback:
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["cleetruman@gmail.com"])
                    mail.setMessageBody("I think the app should...", isHTML: true)

                    present(mail, animated: true)
                }
            case .twitter:
                UIApplication.shared.open(URL(string:"https://twitter.com/iAmChrisTruman")!)
            }
        case .version:
            break
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

