//
//  AppDelegate.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import UIKit
import UserNotifications
import GooglePlaces
import FirebaseCore
import FirebaseMessaging

// unused
class AppDelegate: NSObject, UIApplicationDelegate {
	
	let gcmMessageIDKey = "gcm.Message_ID"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let env = {
            #if DEBUG
            return DebugENV()
            #else
            return ProdENV()
            #endif
        }()

		FirebaseApp.configure()

		// [START set_messaging_delegate]
		Messaging.messaging().delegate = self
		// [END set_messaging_delegate]

		// [START register_for_notifications]

		UNUserNotificationCenter.current().delegate = self

		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		UNUserNotificationCenter.current().requestAuthorization(
			options: authOptions,
			completionHandler: { _, _ in }
		)

		application.registerForRemoteNotifications()

		// [END register_for_notifications]


		GMSPlacesClient.provideAPIKey(env.GOOGLE_MAP_API_KEY)
        return true
    }

	func application(
		_ application: UIApplication,
		didReceiveRemoteNotification userInfo: [AnyHashable: Any]
	) async -> UIBackgroundFetchResult {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification

		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)

		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}

		// Print full message.
		print(userInfo)

		return UIBackgroundFetchResult.newData
	}

	func application(
		_ application: UIApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("Unable to register for remote notifications: \(error.localizedDescription)")
	}

	// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
	// If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
	// the FCM registration token.
	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		print("APNs token retrieved: \(deviceToken)")

		// With swizzling disabled you must set the APNs token here.
		// Messaging.messaging().apnsToken = deviceToken
	}
}

extension AppDelegate: UNUserNotificationCenterDelegate {
	// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		willPresent notification: UNNotification
	) async -> UNNotificationPresentationOptions {
		let userInfo = notification.request.content.userInfo

		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)

		// ...

		// Print full message.
		print(userInfo)

		// Change this to your preferred presentation option
		return [[.alert, .sound]]
	}

	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse
	) async {
		let userInfo = response.notification.request.content.userInfo

		// ...

		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)

		// Print full message.
		print(userInfo)
	}

}

extension AppDelegate: MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		print("Firebase registration token: \(String(describing: fcmToken))")

		let dataDict: [String: String] = ["token": fcmToken ?? ""]
		NotificationCenter.default.post(
			name: Notification.Name("FCMToken"),
			object: nil,
			userInfo: dataDict
		)
		// TODO: If necessary send token to application server.
		// Note: This callback is fired at each app startup and whenever a new token is generated.

		AuthenticationManager.shared.sendTokenToServer(token: fcmToken)
	}
}
