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

        var durationText: String {
            guard let duration = duration else { return "" }
            if duration < 60 {
                return "Duration: \(duration) seconds"
            }
            return "Duration: \(duration / 60) minutes"
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
        let commited_at: Date?
        let author_name: String
        let author_email: String
        let committer_name: String
        let committer_email: String
        let compare_url: String
        let pull_request_number: Int?
    }

    let commits: [Commit]
}

struct TravisReposResponse: Codable {
    struct Repo: Codable {
        let id: Int
        let slug: String
        let description: String?
        let last_build_id: Int?
        let last_build_number: String?
        let last_build_state: String?
        let last_build_duration: Int?
        let last_build_language: String?
        let last_build_started_at: Date?
        let last_build_finished_at: Date?
        let active: Bool?
        let github_language: String?
    }
    let repos: [Repo]
}

struct TravisAccountsResponse: Codable {
    struct Account: Codable {
        let repos_count: Int
        let name: String
        let type: String
        let id: Int
        let login: String
        let avatar_url: String?
    }
    let accounts: [Account]
}
