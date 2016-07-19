//
//  VersionData.swift
//  AppVersionEnforcer
//
//  Created by Romson Preechawit (RWP) on 7/18/2559 BE.
//  Copyright © 2559 RWP. All rights reserved.
//

import UIKit

internal class VersionData: NSObject {
    
    var allowDontShowAgain: Bool = false
    var canRepeatAlert: Bool = false
    var enableLink: Bool = false
    var isForced: Bool = false
    
    var repeatAlertEvery: Int!
    var updatedAt: UInt64!
    
    var versionDescription: String!
    var linkTitle: String!
    var linkURL: String!
    var version: String!
    var title: String!
    
    internal private(set) var versionDataDict: NSDictionary!
    
    init?(versionDataDict: NSDictionary) {
        
        super.init()
        
        guard let allowDontShowAgain = versionDataDict["allow_dont_show_again"] as? Bool,
            repeatAlertEveryString = versionDataDict["repeat_alert_every"] as? String,
            canRepeatAlert = versionDataDict["can_repeat_alert"] as? Bool,
            description = versionDataDict["description"] as? String,
            enableLink = versionDataDict["enable_link"] as? Bool,
            linkTitle = versionDataDict["link_title"] as? String,
            repeatAlertEvery = Int(repeatAlertEveryString),
            linkURL = versionDataDict["link_url"] as? String,
            updatedAtString = versionDataDict["updated_at"] as? String,
            title = versionDataDict["title"] as? String,
            version = versionDataDict["version"] as? String,
            isForced = versionDataDict["is_forced"] as? Bool
            
            else {
                print("Oops Something went wrong!")
                return
        }
        
        self.versionDataDict = versionDataDict
        
        self.allowDontShowAgain = allowDontShowAgain
        self.canRepeatAlert = canRepeatAlert
        self.enableLink = enableLink
        self.isForced = isForced
        
        self.repeatAlertEvery = repeatAlertEvery
        
        guard let updatedAt = UInt64(updatedAtString) else {
            print("cannot parse update at")
            return
        }
        
        self.updatedAt = updatedAt
        
        self.versionDescription = description
        self.linkTitle = linkTitle
        self.linkURL = linkURL
        self.version = version
        self.title = title
        
    }
    
}
