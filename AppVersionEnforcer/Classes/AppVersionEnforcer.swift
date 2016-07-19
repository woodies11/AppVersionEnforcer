//
//  AppVersionEnforcer.swift
//  AppVersionEnforcer
//
//  Created by Romson Preechawit (RWP) on 7/18/2559 BE.
//  Copyright © 2559 RWP. All rights reserved.
//

import UIKit
import Alamofire

public class AppVersionEnforcer: NSObject {
    
    private var currentAlert: UIAlertController?
    private var forcingAlert: Bool = false
    
    // =============================================
    
    private let USER_REPEAT_COUNTDOWN: String = "AVEuserRepeatCountdown"
    private let USER_HAS_PENDING_REPEAT: String = "AVEuserHasPendingRepeat"
    private let USER_VERSION_DATA_DICT: String = "AVEuserVersionData"
    private let USER_DONT_SHOW_AGAIN: String = "AVEuserDontShowAgain"
    private let USER_IS_FORCED: String = "AVEuserIsForced"
    
    // --------------------------------
    
    private var userRepeatCountdown: Int = -1
    private var userHasPendingRepeat: Bool = false
    private var userVersionDataDict: NSDictionary?
    private var userDontShowAgain: Bool = false
    private var userIsForced: Bool = false
    
    // =============================================
    
    private let PARAM_PACKAGE = "package"
    private let PARAM_PLATFORM = "platform"
    private let PARAM_CURRENT_VERSION = "current_version"
    
    private let PLATFORM: String = "ios"
    
    // =============================================
    
    private var apiURL: String!
    private var window: UIWindow!
    
    private let API_GET_CURRENT_VERSION: String = "getCurrentVersion"
    private let API_GET_PLATFORM_LINK: String = "getPlatformLink"
    
    // =============================================
    
    internal var currentVersion: VersionData?
    
    /**
     * Init object with
     * @param apiURL = base api url
     * @param window = main window to show alert on
     */
    public init(apiURL: String, window: UIWindow?) {
        self.apiURL = apiURL
        
        if self.apiURL.characters.last != "/" {
            self.apiURL.append("/" as Character)
        }
        
        self.window = window
        super.init()
        self.getUserDefaultVersionData()
    }
    
    /**
     * Load and recreate data from userDefault
     */
    private func getUserDefaultVersionData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userRepeatCountdown = userDefaults.integerForKey(USER_REPEAT_COUNTDOWN)
        userHasPendingRepeat = userDefaults.boolForKey(USER_HAS_PENDING_REPEAT)
        userVersionDataDict = userDefaults.dictionaryForKey(USER_VERSION_DATA_DICT)
        userDontShowAgain = userDefaults.boolForKey(USER_DONT_SHOW_AGAIN)
        userIsForced = userDefaults.boolForKey(USER_IS_FORCED)
        
        if let dataDict = userVersionDataDict {
            currentVersion = VersionData(versionDataDict: dataDict)
        }
    }

    /**
     * Clear userDefault
     */
    private func clearUserDefaultVersionData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(USER_REPEAT_COUNTDOWN)
        userDefaults.removeObjectForKey(USER_HAS_PENDING_REPEAT)
        userDefaults.removeObjectForKey(USER_VERSION_DATA_DICT)
        userDefaults.removeObjectForKey(USER_DONT_SHOW_AGAIN)
        userDefaults.removeObjectForKey(USER_IS_FORCED)
        
        userIsForced = false
        userDontShowAgain = false
        userHasPendingRepeat = false
        
    }
    
    /**
     * Initiate version enforcing and show alert/notice depending on the data and option from sever
     * AppVersionEnforcer will find the newest recommended version from "is_recommended" value
     * if "is_forced" is true, only "Update" option will be available
     * @param package - App's Bundle identifier
     * @param currentVersion - current app version
     */
    public func checkVersion(package: String, currentVersion: String) {
        requestVersionHistoryData(package, currentVersion: currentVersion) { (response) in
            
            guard let versionDatas = response.result.value  as? [AnyObject] else {
                print("ERROR! No Value Found!")
                return
            }
            
            var lastestVersionData: AnyObject?
            var isForced: Bool = false
            
            // loop through each version data, finding any recommended and forced
            for versionData in versionDatas {
                if let _isForced = versionData["is_forced"] as? Bool where _isForced {
                    isForced = _isForced
                }
                
                // once a recommended version is found, there is no need to search for more but
                // the loop must continue to find if there is any forced update
                if lastestVersionData == nil {
                    if let isRecommended = versionData["is_recommended"] as? Bool
                        where isRecommended{
                        
                        lastestVersionData = versionData;
                        
                    }
                }
            }
            
            var newData: VersionData?
            
            // if a version is found then this will not be nil
            if let lastestVersionData = lastestVersionData as? NSDictionary {
                // process new data
                newData = VersionData(versionDataDict: lastestVersionData)
            } else {
                print("No Recommended Version Found")
            }
            
            let (_data, isNew) = self.compareAndSelectVersionData(self.currentVersion, new: newData)
            
            // select which version to user, local or server, depending on which on is newer
            guard let data = _data else {
                print("No Data Found")
                return
            }
            
            
            self.processVersionData(data, isForced: isForced, isNew: isNew)
            
        }
    }
    
    /**
     * Helper method to start requesting data using with Constant parameters set in the class
     * called by the checkVersion() function and receive propagated data from there
     */
    private func requestVersionHistoryData(
        package: String,
        currentVersion: String,
        completionHandler: Response<AnyObject, NSError> -> Void) {
        
        var params: [String:String] = [String:String]()
        params[PARAM_PACKAGE] = package
        params[PARAM_CURRENT_VERSION] = currentVersion
        params[PARAM_PLATFORM] = PLATFORM
        
        Alamofire.request(.GET, apiURL+API_GET_CURRENT_VERSION, parameters: params)
            .responseJSON(completionHandler: completionHandler)
        
    }
    
    
    /**
     * Select which version to user, local or server, depending on which is newer
     * if both version are exactly the same, local is prefer so that user's
     * previous decision is retained
     */
    private func compareAndSelectVersionData(old: VersionData?, new: VersionData?)
        -> (data: VersionData?, isNew: Bool) {
        // both present - compare
        if let old = old, new = new {
            // prefered local version, if they are exactly the same, for user's ignore setting
            if old.updatedAt >= new.updatedAt {
                print("O N, O")
                return (old, false)
            } else {
                print("O N, N")
                return (new, true)
            }
        }
        
        // has old data but no new data, should check version
        if let _ = old {
            
            // TODO: will compare version
            
            // clear local data
            clearUserDefaultVersionData()
            print("O -, -")
            return (nil, false)
        }
        
        // there is new data but no old data
        if let new = new {
            print("- N, N")
            return (new, true)
        }
        
        // default case: nither new nor old data found, do nothing
        print("- -, -")
        return (nil, false)
    }
    
    /**
     * Read the current countdown counter and see if it's time to show the alert
     * will reset counter to default value if alert is shown
     */
    private func handleRepeatMessage(versionData: VersionData, isForced: Bool, isNew: Bool) {
        // decrement counter
        userRepeatCountdown -= 1
        print("COUNTDOWN \(userRepeatCountdown)")
        
        if userRepeatCountdown > 0 {
            NSUserDefaults.standardUserDefaults()
                .setInteger(userRepeatCountdown, forKey: USER_REPEAT_COUNTDOWN)
            return
        }
        
        // reset counter
        userRepeatCountdown = versionData.repeatAlertEvery;
        NSUserDefaults.standardUserDefaults()
            .setInteger(versionData.repeatAlertEvery, forKey: USER_REPEAT_COUNTDOWN)
        
        createAndShowAlert(versionData, isForced: isForced, isNew: isNew)
        
    }
    
    /**
     * Decide what to do with the versionData and call appropiate function to handle each case
     */
    private func processVersionData(versionData: VersionData, isForced: Bool, isNew: Bool) {
        print("FORCED: \(isForced)")
        print("NEW: \(isNew)")
        print("DONT SHOW AGAIN \(userDontShowAgain)")
        print(versionData.versionDataDict)
        
        // if isForced, show alert and ignore other cases
        if isForced {
            createAndShowAlert(versionData, isForced: isForced, isNew: isNew)
            return
        }
        
        // if not forced and user mark as don't show again
        if !isNew && userDontShowAgain {
            print("never shown")
            return
        }
        
        // if old version is passed, handle repeated
        if !isNew && versionData.canRepeatAlert && userHasPendingRepeat {
            print("old version, can repeat")
            handleRepeatMessage(versionData, isForced: isForced, isNew: isNew)
            return
        }
        
        // default
        print("default case")
        createAndShowAlert(versionData, isForced: isForced, isNew: isNew)
        
    }
    
    /**
     * Extract data from the versionData object, create, populate, and show alert
     */
    private func createAndShowAlert(versionData: VersionData, isForced: Bool, isNew: Bool) {
        print("creating alert")
        
        NSUserDefaults.standardUserDefaults()
            .setBool(false, forKey: self.USER_HAS_PENDING_REPEAT)
        
        // create alertController
        let alert: UIAlertController = UIAlertController(
            title: versionData.title,
            message: versionData.versionDescription,
            preferredStyle: .Alert)
        
        // add updateLink
        alert.addAction(UIAlertAction(title: "Update", style: .Default, handler: { (action) in
            self.handleUpdateRedirect()
        }))
        
        if !isForced {
            // if there is a link
            if versionData.enableLink {
                alert.addAction(UIAlertAction(
                    title: versionData.linkTitle, style: .Default, handler:
                    { (action) in
                        self.handleLink(versionData.linkURL)
                }))
            }
            
            // If alert is allow to be ignored (Don't show again)
            if versionData.allowDontShowAgain {
                alert.addAction(UIAlertAction(title: "Don't Show Again", style: .Default, handler:
                    { (action) in
                        NSUserDefaults.standardUserDefaults()
                            .setBool(true, forKey: self.USER_DONT_SHOW_AGAIN)
                        NSUserDefaults.standardUserDefaults()
                            .setObject(versionData.versionDataDict,
                                forKey: self.USER_VERSION_DATA_DICT)
                }))
            }
            
            // Dismiss Function
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) in
                alert.dismissViewControllerAnimated(true, completion: nil)
                NSUserDefaults.standardUserDefaults()
                    .setBool(true, forKey: self.USER_HAS_PENDING_REPEAT)
            }))
            
            //--------------------------------------------------------
            
            // Store Countdown Value along with the Version Data
            if versionData.canRepeatAlert {
                if isNew {
                    NSUserDefaults.standardUserDefaults()
                        .setInteger(versionData.repeatAlertEvery,
                                    forKey: self.USER_REPEAT_COUNTDOWN)
                    NSUserDefaults.standardUserDefaults()
                        .setObject(versionData.versionDataDict,
                                   forKey: self.USER_VERSION_DATA_DICT)
                }
            }
            
        } else {
            self.forcingAlert = true
        }
        
        self.currentAlert = alert;
        showAlert(alert)
        
    }
    
    /**
     * Helper method to show alert to the window received at init()
     */
    private func showAlert(alert: UIAlertController) {
        dispatch_async(dispatch_get_main_queue(), {
            guard let window = self.window else {
                return
            }
            alert.dismissViewControllerAnimated(false, completion: nil)
            window.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        })

        
    }
    
    /**
     * Call this function in AppDelegate applicationDidBecomeActive() 
     * to enforce alert upon user returning to the application
     */
    public func applicationDidBecomeActive(application: UIApplication) {
        if let alert = self.currentAlert where self.forcingAlert {
            showAlert(alert)
        }
    }
    
    /**
     * Create URL from String and redirect user to the URL, add "http://" if needed
     */
    private func handleLink(urlString: String) {
        print(urlString)
        
        let _URL = NSURL(string: urlString)
        guard let URL = _URL else {
            print("ERROR! Invalid URL")
            return
        }
        
        var tempURL: NSURL? = URL
        
        if !UIApplication.sharedApplication().canOpenURL(URL) {
            if !(urlString.containsString("http://") ||  urlString.containsString("https://")) {
                tempURL = addHTTPtoLink(urlString)
            }
        }
        
        guard let finalizedURL = tempURL else {
            print("ERROR! Invalid URL (2)")
            return
        }
        
        
        print(finalizedURL.absoluteString)
        UIApplication.sharedApplication().openURL(finalizedURL)
        
    }
    
    /**
     * Helper function to add "http://" to a given string
     * return NSURL
     */
    private func addHTTPtoLink(urlString: String) -> NSURL? {
        let _urlString = "http://" + urlString
        let _URL = NSURL(string: _urlString)
        return _URL!
    }
    
    /**
     * Request update link from the server and redirect user to the link
     */
    private func handleUpdateRedirect() {
        Alamofire.request(.GET, apiURL+API_GET_PLATFORM_LINK, parameters: [PARAM_PLATFORM:PLATFORM])
            .responseJSON { (response) in
         
                guard let linkData = response.result.value else {
                    print("ERROR! No Value Found!")
                    return
                }
                
                if let platform = linkData["platform"] as? String
                    where platform == self.PLATFORM {
                    
                    guard let urlString = linkData["link"] as? String,
                        URL = NSURL(string: urlString) else {
                            
                        print("Invalid update link!")
                        return
                            
                    }
                    
                    UIApplication.sharedApplication().openURL(URL)
                    
                }
                
        }
    }
    

}
