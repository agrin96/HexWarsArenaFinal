//
//  AppDelegate.swift
//  HexWars
//
//  Created by Aleksandr Grin on 8/5/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: MainScreen())

        //State restoration
        if GameState.sharedInstance().wasGameSaved != nil {
            if GameState.sharedInstance().wasGameSaved! == true {
                let gameScene = NSKeyedUnarchiver.unarchiveObject(withFile: sceneFilePath) as? GameScene

                //Push a GameScene if we restore a game to a new GVC instance.
                let vc = GameViewController()
                vc.gameScene = gameScene

                (window?.rootViewController as! UINavigationController).pushViewController(vc, animated: false)
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let rootVC = window?.rootViewController as? UINavigationController {
            for vc in rootVC.viewControllers{
                if vc is GameViewController {
                    (vc as! GameViewController).saveCurrentGame()
                }
            }
        }
        GameState.saveGameState()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

