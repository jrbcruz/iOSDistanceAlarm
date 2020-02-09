//
//  NotificationManager.swift
//  DistanceAlarm
//
//  Created by JR Cruz on 17/04/2019.
//  Copyright © 2019 CzarinaSy. All rights reserved.
//

import UIKit
import UserNotifications
import UIKit.UIApplication

class NotificationManager: NSObject {
    static var shared = NotificationManager()
    
    private override init(){
        super.init()
    }
    
    func triggerAlarm(after seconds: Double, identifier: String, title: String, message: String, category: String){
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings {settings in
            switch settings.authorizationStatus{
            case.notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]){
                    (success, error) in
                    if success {
                        self.triggerAlarm(after: seconds, identifier: identifier, title: title, message: message, category: category)
                    }
                    
                }
            case.authorized:
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = message
                content.sound = .default
                content.badge = 1
                content.categoryIdentifier = category
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
                
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                center.add(request, withCompletionHandler: { error in
                    if let error = error{
                        assertionFailure(error.localizedDescription)
                    }
                })
                
                //create notification action
                let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
                
                //create category with action
                let notificationCategory = UNNotificationCategory(identifier: category, actions: [deleteAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "" ,options: [])
                
                //added created category to notification center
                center.setNotificationCategories([notificationCategory])
                center.delegate = self
                
                
            default:
                break
            }
        }
        
    }
    
    
}

extension NotificationManager: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier{
        case "Delete":
            UIApplication.shared.applicationIconBadgeNumber -= 1
        default:
            break
        }
        completionHandler()
    }
}
