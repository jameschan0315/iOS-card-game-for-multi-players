//
//  AppDelegate.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/26/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	
	private let navigationController: UINavigationController = {
		let navigationController = UINavigationController()
		navigationController.navigationBar.isTranslucent = false
		return navigationController
	}()
	
	private var mainCoordinator: DashboardContainerCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

		
		UINavigationBar.appearance().barTintColor = UIColor.init(white: 0, alpha: 0.2)
		UINavigationBar.appearance().tintColor = UIColor.init(white: 0.7, alpha: 1)
		UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.init(white: 0.7, alpha: 1)]
        
        #if DEBUG
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection10.bundle")?.load()
        //for tvOS:
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/tvOSInjection10.bundle")?.load()
        //Or for macOS:
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection10.bundle")?.load()
        #endif
		
		// UIApplication.sharedApplication().statusBarHidden = true
		
//		// Configure tracker from GoogleService-Info.plist.
//		var configureError:NSError?
//		GGLContext.sharedInstance().configureWithError(&configureError)
//		assert(configureError == nil, "Error configuring Google services: \(configureError)")
//
//		// Optional: configure GAI options.
//		let gai = GAI.sharedInstance()
//		gai.trackUncaughtExceptions = true  // report uncaught exceptions
//		gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release

//		window = UIWindow()
//		window?.rootViewController = navigationController
//		let coordinator = DashboardContainerCoordinator(navigationController: navigationController as! UINavigationControllerType)
//		coordinator.start()
//		window?.makeKeyAndVisible()
//		
//		mainCoordinator = coordinator
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
