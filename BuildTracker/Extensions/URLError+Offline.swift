//
//  URLError+Offline.swift
//  Core
//
//  Created by Christopher Truman on 2/21/20.
//  Copyright © 2020 Sony NMS. All rights reserved.
//

import Foundation

extension URLError {
    var isOffline: Bool {
        return code == .timedOut ||
            code == .cannotConnectToHost ||
            code == .dataNotAllowed ||
            code == .timedOut ||
            code == .notConnectedToInternet ||
            code == .cannotFindHost
    }
}
