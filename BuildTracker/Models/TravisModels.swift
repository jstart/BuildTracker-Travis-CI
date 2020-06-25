//
//  TravisModels.swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/31/20.
//  Copyright © 2020 truman. All rights reserved.
//

import Foundation

struct TravisBuildsResponse: Codable {
    struct Build: Codable {
        let commit_id: Int
        let duration: Int?
        let finished_at: Date?
        let id: Int
        let job_ids: [Int]
        let number: String
        let event_type: String
        let pull_request: Bool
        let pull_request_number: Int?
        let pull_request_title: String?
        let repository_id: Int
        let started_at: Date?
        let state: String

        var startedText: String {
            guard let started = started_at else { return "" }
            let formatter = RelativeDateTimeFormatter()
            return "Started \(formatter.localizedString(for: started, relativeTo: Date()))"
        }

        var durationText: String {
            guard let duration = duration else { return "" }
            if duration < 60 {
                return "Duration: \(duration) seconds"
            }
            let minutes = duration / 60
            return "Duration: \(minutes) minute\(minutes == 1 ? "" : "s")"
        }

        var finishedText: String {
            guard let finished = finished_at else { return "" }
            let formatter = RelativeDateTimeFormatter()
            return "Finished \(formatter.localizedString(for: finished, relativeTo: Date()))"
        }
    }
    let builds: [Build]

    struct Commit: Codable {
        let id: Int
        let sha: String
        let branch: String
        let tag: String?
        let message: String
        let committed_at: Date?
        let author_name: String
        let author_email: String
        let committer_name: String
        let committer_email: String
        let compare_url: String
        let pull_request_number: Int?

        var committedAtText: String {
            guard let committed = committed_at else { return "" }
            let formatter = RelativeDateTimeFormatter()
            return "Triggered \(formatter.localizedString(for: committed, relativeTo: Date()))"
        }
    }

    let commits: [Commit]
}

struct TravisReposResponse: Codable {
    class Repo: Codable {
        let id: Int
        let slug: String
        let description: String?
        var last_build_id: Int?
        var last_build_number: String?
        var last_build_state: String?
        var last_build_duration: Int?
        var last_build_language: String?
        var last_build_started_at: Date?
        var last_build_finished_at: Date?
        var active: Bool?
        let github_language: String?

        var durationText: String {
            if last_build_state == "canceled" {
                return "Last Build Canceled"
            }
            guard let duration = last_build_duration else {
                guard let lastState = last_build_state else { return "" }
                guard let finished = last_build_started_at else { return "" }
                let formatter = RelativeDateTimeFormatter()
                return "Last Build \(lastState.capitalized) \(formatter.localizedString(for: finished, relativeTo: Date()))"
            }
            if duration < 60 {
                return "Duration: \(duration) seconds"
            }
            return "Duration: \(duration / 60) minutes"
        }
    }
    let repos: [Repo]
}

struct TravisAccountsResponse: Codable {
    struct Account: Codable {
        let repos_count: Int
        let name: String?
        let type: String
        let id: Int
        let login: String
        let avatar_url: String?
    }
    let accounts: [Account]
}
