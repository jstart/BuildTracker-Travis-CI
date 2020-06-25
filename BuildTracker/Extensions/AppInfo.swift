//
//  AppInfo.swift
//  Core
//
//  Created by Colin, Robert on 1/14/20.
//  Copyright © 2020 Sony NMS. All rights reserved.
//

import UIKit

public extension Bundle {
    enum Key: String {
        case appVersion = "CFBundleShortVersionString"
        case build = "CFBundleVersion"
        case displayName = "CFBundleName"
    }

    func stringFromInfoDictionary(forKey key: Key) -> String {
        object(forInfoDictionaryKey: key.rawValue) as? String ?? ""
    }
}

public struct AppInfo {
    public static var appVersion: String { Bundle.main.stringFromInfoDictionary(forKey: .appVersion) }
    public static var build: String { Bundle.main.stringFromInfoDictionary(forKey: .build) }
    public static var displayName: String { Bundle.main.stringFromInfoDictionary(forKey: .displayName) }
    
    public static var currentVersion: String { "Version \(appVersion) (\(build))" }
    public static var userAgent: String {
        "\(displayName)/\(appVersion) \(deviceName) \(deviceVersion) \(CFNetworkString) \(darwinString)"
    }
    
    // MARK: - Private
    
    private static var CFNetworkString: String { "CFNetwork/\(CFNetworkVersion)" }
    private static var CFNetworkVersion: String {
        Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    private static var darwinString: String { "Darwin/\(darwinVersion)" }
    private static var darwinVersion: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let d = Data(bytes: &systemInfo.release, count: Int(_SYS_NAMELEN))
        
        return String(bytes: d, encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? ""
    }
    
    private static var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let d = Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN))
        
        return String(bytes: d, encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? ""
    }
    
    private static var deviceVersion: String { "\(UIDevice.current.systemName)/\(UIDevice.current.systemVersion)" }
}
