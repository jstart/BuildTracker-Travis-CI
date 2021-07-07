//
//  GithubService.swift
//  BuildTracker
//
//  Created by Christopher Truman on 3/30/20.
//  Copyright © 2020 truman. All rights reserved.
//

import Foundation
import SafariServices

struct GithubAccessTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let scope: String
}

struct TravisAccessTokenResponse: Codable {
    let access_token: String
}

struct GithubService {
    static let baseURL = "https://api.travis-ci.com/"
    static var githubToken: GithubAccessTokenResponse? {
        didSet {
            guard let data = try? JSONEncoder().encode(githubToken) else { return }
            UserDefaults.standard.set(data, forKey: "GithubToken")
        }
    }
    static var travisToken: TravisAccessTokenResponse? {
        didSet {
            guard let data = try? JSONEncoder().encode(travisToken) else { return }
            UserDefaults.standard.set(data, forKey: "TravisToken")
        }
    }
    static var userAccount: TravisAccountsResponse.Account? {
        didSet {
            guard let data = try? JSONEncoder().encode(userAccount) else { return }
            UserDefaults.standard.set(data, forKey: "UserAccount")
        }
    }

    static func logout() {
        githubToken = nil
        UserDefaults.standard.removeObject(forKey: "GithubToken")
        travisToken = nil
        UserDefaults.standard.removeObject(forKey: "TravisToken")
        userAccount = nil
        UserDefaults.standard.removeObject(forKey: "UserAccount")
        UserDefaults.standard.synchronize()
    }

    static func load() {
        guard let githubTokenData = UserDefaults.standard.object(forKey: "GithubToken") as? Data,
            let travisTokenData = UserDefaults.standard.object(forKey: "TravisToken") as? Data else {
                return
        }
        guard let githubTokenDefault = try? JSONDecoder().decode(GithubAccessTokenResponse.self, from: githubTokenData),
            let travisTokenDefault = try? JSONDecoder().decode(TravisAccessTokenResponse.self, from: travisTokenData) else { return }
        githubToken = githubTokenDefault
        travisToken = travisTokenDefault

        guard let userAccountData = UserDefaults.standard.object(forKey: "UserAccount") as? Data else { return }
        guard let userAccountDefault = try? JSONDecoder().decode(TravisAccountsResponse.Account.self, from: userAccountData) else { return }
        userAccount = userAccountDefault
    }

    static var startAuthFlow: SFSafariViewController {
        let webVC = SFSafariViewController(url: URL(string: "https://github.com/login/oauth/authorize?allow_signup=false&client_id=\(githubClientID)&state=\(state)&scope=read:org%20repo_deployment%20repo:status%20user:email%20repo")!)
        return webVC
    }

    static func authenticate(code: String) {
        var request = URLRequest(url: URL(string: "https://github.com/login/oauth/access_token")!)
        request.httpMethod = "POST"

        let json = ["client_id": githubClientID,
                    "client_secret": githubSecret,
                    "code": code,
                    "state": state]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])

        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data else {
                // error handling
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let json = try JSONDecoder().decode(GithubAccessTokenResponse.self, from: data)
                githubToken = json
                let token = json.access_token
                GithubService.travisAuth(token: token)
            } catch {
                // Parse error handling
                print(error)
            }
        }).resume()
    }

    static func travisAuth(token: String) {
        var request = URLRequest(url: URL(string: "https://api.travis-ci.com/auth/github")!)
        request.httpMethod = "POST"

        let json = ["github_token": token]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])

        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/vnd.travis-ci.2.1+json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data else {
                // error handling
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let json = try JSONDecoder().decode(TravisAccessTokenResponse.self, from: data)
                travisToken = json
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .oauth, object: nil)
                }
            } catch {
                // Parse error handling
            }
        }).resume()
    }

    static func accounts(_ completion: @escaping (Result<TravisAccountsResponse, Error>) -> Void) {
        let completion: (Result<TravisAccountsResponse, Error>) -> Void = { response in
            if case let .success(response) = response {
                userAccount = response.accounts.first(where: { $0.type == "user" })
            }

            completion(response)
        }
        travisRequest(path: "accounts", completion: completion)
    }

    static func buildStatus(repoSlug: String, completion: @escaping (Result<TravisBuildsResponse, Error>) -> Void) {
        travisRequest(path: "repos/\(repoSlug)/builds", completion: completion)
    }

    static func logs(buildID: String, completion: @escaping (Result<TravisReposResponse, Error>) -> Void) {
        travisRequest(path: "build/\(buildID)/log", completion: completion)
    }

    static func restart(buildID: String, completion: @escaping (Result<TravisReposResponse, Error>) -> Void) {
        travisRequest(method: "POST", path: "builds/\(buildID)/restart", completion: completion)
    }

    static func cancel(buildID: String, completion: @escaping (Result<TravisReposResponse, Error>) -> Void) {
        travisRequest(method: "POST", path: "builds/\(buildID)/cancel", completion: completion)
    }

    static func repos(owner: String, memberName: String, _ completion: @escaping (Result<TravisReposResponse, Error>) -> Void) {
        travisRequest(path: "repos?active=true&slug=\(owner)&member=\(memberName)", completion: completion)
    }

    static func repos(ids: [String], completion: @escaping (Result<TravisReposResponse, Error>) -> Void) {
        travisRequest(path: "repos?ids=\(ids.joined(separator: ","))", completion: completion)
    }

    static func reposNEW(completion: @escaping (Result<TravisReposResponse, Error>) -> Void) {
        travisRequest(path: "repos?repository.active=true&sort_by=current_build%3Adesc&limit=30&include=build.branch%2Cbuild.commit%2Cbuild.created_by%2Cbuild.request%2Crepository.current_build%2Crepository.default_branch%2Crepository.email_subscribed%2Cowner.github_id%2Cowner.installation", completion: completion)
    }
    //https://api.travis-ci.com/repos?repository.active=true&sort_by=current_build%3Adesc&limit=30&include=build.branch%2Cbuild.commit%2Cbuild.created_by%2Cbuild.request%2Crepository.current_build%2Crepository.default_branch%2Crepository.email_subscribed%2Cowner.github_id%2Cowner.installation

    static func searchRepos(query: String, completion: @escaping (Result<TravisReposResponse, Error>) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        travisRequest(path: "repos?search=\(query)&active=true", completion: completion)
    }

    static func logs(jobID: String, completion: @escaping (Result<TravisReposResponse, Error>) -> Void) {
        // {\"log\":{\"id\":292169929,\"job_id\":315546877,\"type\":\"Log\",\"body\":
        // https://docs.travis-ci.com/api/?http#logs
        travisRequest(path: "jobs/\(jobID)/log", completion: completion)
    }

    static func restart(jobID: String, completion: @escaping (Result<TravisReposResponse, Error>) -> Void) {
        travisRequest(method: "POST", path: "jobs/\(jobID)/restart", completion: completion)
    }

    static func cancel(jobID: String, completion: @escaping (Result<TravisReposResponse, Error>) -> Void) {
        travisRequest(method: "POST", path: "jobs/\(jobID)/cancel", completion: completion)
    }

    static func travisRequest<T: Codable>(method: String =
    "GET", path: String, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = method

        request.addValue("token \(travisToken!.access_token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/vnd.travis-ci.2.1+json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(error ?? URLError(.unknown))) }
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let json = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(json)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }).resume()
    }
}
