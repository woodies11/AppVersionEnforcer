# AppVersionEnforcer

[![CI Status](http://img.shields.io/travis/Romson Preechawit/AppVersionEnforcer.svg?style=flat)](https://travis-ci.org/Romson Preechawit/AppVersionEnforcer)
[![Version](https://img.shields.io/cocoapods/v/AppVersionEnforcer.svg?style=flat)](http://cocoapods.org/pods/AppVersionEnforcer)
[![License](https://img.shields.io/cocoapods/l/AppVersionEnforcer.svg?style=flat)](http://cocoapods.org/pods/AppVersionEnforcer)
[![Platform](https://img.shields.io/cocoapods/p/AppVersionEnforcer.svg?style=flat)](http://cocoapods.org/pods/AppVersionEnforcer)

## Requirements

iOS > 8

Currently, AppVersionEnforcer only work with a very specific sever setting.

## Installation

AppVersionEnforcer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AppVersionEnforcer"
```

## Usage

Currently, AppVersionEnforcer only work with a very specific sever setting.

Simply create an instance of AppVersionEnforcer, with your base API URL, within the AppDelegate.
Then, call 'enforcer.checkVersion(<YOUR_BUNDLE_IDENTIFIER>, currentVersion: <APP_VERSION>)' in the application 'didFinishLaunchingWithOptions'.
And call 'enforcer.applicationDidBecomeActive(application)' in the 'applicationDidBecomeActive(application: UIApplication)'

```
// AppDelegate.swift

var window: UIWindow?
var enforcer: AppVersionEnforcer!

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
enforcer = AppVersionEnforcer(apiURL: "https://<YOUR_BASE_API_URL>/", window: window)
enforcer.checkVersion("<YOUR_BUNDLE_IDENTIFIER>", currentVersion: "1.0.0")
}


func applicationDidBecomeActive(application: UIApplication) {
enforcer.applicationDidBecomeActive(application)
}

```

The AppVersionEnforcer will communicate with the server and display update notice to the user depending on the parameters receive from the server


## Author

Romson Preechawit

## License

Copyright (c) 2016 Romson Preechawit

AppVersionEnforcer is licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.