//
//  RepoStore.swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/31/20.
//  Copyright © 2020 truman. All rights reserved.
//

import Foundation

class RepoStore {
    static let key = "truman.defaults.repo-store"
    static let defaults = UserDefaults.standard

    var repos: [TravisReposResponse.Repo] = []

    init() {
        refresh()
    }

    func refresh() {
        guard let repoData = UserDefaults.standard.object(forKey: RepoStore.key) as? Data else {
            return
        }
        guard let reposDefaults = try? JSONDecoder().decode([TravisReposResponse.Repo].self, from: repoData) else { return }
        self.repos = reposDefaults
    }

    func add(_ repo: TravisReposResponse.Repo) {
        guard repos.first(where: { $0.slug == repo.slug }) == nil else { return }
        repos.append(repo)
        persist()
    }

    func move(from fromIndex: Int, to toIndex: Int) {
        repos.swapAt(fromIndex, toIndex)
        persist()
    }

    func contains(_ repo: TravisReposResponse.Repo) -> Bool {
        guard repos.first(where: { $0.slug == repo.slug }) != nil else { return false }
        return true
    }

    func remove(_ repo: TravisReposResponse.Repo) {
        repos.removeAll(where: { $0.slug == repo.slug })
        persist()
    }

    func persist() {
        guard let data = try? JSONEncoder().encode(repos) else { return }
        UserDefaults.standard.set(data, forKey: RepoStore.key)
    }
}
