<h1 align="center" id="title">Flavor Flash</h1>

<pre id="description">
Flavor Flash is an app that foodie can record and share everyday meals in the "Food Prints" community.
Join Flavor Flash to share and explore restaurants with your friends!</pre>

## What can you do on Flavor Flash?

- Generates random food category for mealtime and recommends nearby restaurants to save your time on deciding what to eat.

- Capture daily meals using your device's front & back camera simultaneously, and submit your "foodprint".

- Checking out your friends foodprints by commenting and liking their "foodprint" posts.

- Browse your own foodprint history on map, and checkout friend's foodprints by overlaying map annotations.

- Add friend by scanning QRCode.

- Chat with your foodie friend 1 on 1.

- Light / Dark mode in-app toggle.

- (Un deployed) Food share live stream functionality undeployed.（Due to App Store review with a high chance of rejection）

## Screen Shots

### LoginPage

<img src="./Screenshots/login_dark.png" width="200"/><img src="./Screenshots/login_light.png" width="200"/>

### HomePage

<table>
  <tr align="center">
    <td>Landing Page</td>
     <td>Restaurant Map Search</td>
     <td>Restaurant Detail</td>
  </tr>
  <tr>
    <td><img src="./Screenshots/home_dark.png" width="200"/></td>
    <td><img src="./Screenshots/restaurant-search_dark.png" width="200"/></td>
    <td><img src="./Screenshots/restaurant-detail_dark.png" width="200"/></td>
  </tr>
    <tr>
    <td><img src="./Screenshots/home_light.png" width="200"/></td>
    <td><img src="./Screenshots/restaurant-search_light.png" width="200"/></td>
    <td><img src="./Screenshots/restaurant-detail_light.png" width="200"/></td>
  </tr>
 </table>

### Flavor Flash Page

<table>
  <tr align="center">
    <td>Photo stream previewing</td>
     <td>Photo editing</td>
     <td>Submit page</td>
  </tr>
  <tr>
    <td><img src="./Screenshots/flavor-flash_dark.PNG" width="200"/></td>
    <td><img src="./Screenshots/captured_dark.PNG" width="200"/></td>
    <td><img src="./Screenshots/leave-foodprint_dark.PNG" width="200"/></td>
  </tr>
    <tr>
    <td><img src="./Screenshots/flavor-flash_light.PNG" width="200"/></td>
    <td><img src="./Screenshots/captured_light.PNG" width="200"/></td>
    <td><img src="./Screenshots/leave-foodprint_light.PNG" width="200"/></td>
  </tr>
 </table>

### Foodprint Community

<table>
  <tr align="center">
    <td>Landing Page</td>
     <td>Comment sheet</td>
     <td>ChatRoom</td>
  </tr>
  <tr>
    <td><img src="./Screenshots/foodprint_dark.png" width="200"/></td>
    <td><img src="./Screenshots/foodprint-comment_dark.png" width="200"/></td>
    <td><img src="./Screenshots/chatroom_dark.png" width="200"/></td>
  </tr>
    <tr>
    <td><img src="./Screenshots/foodprint_light.png" width="200"/></td>
    <td><img src="./Screenshots/foodprint-comment_light.png" width="200"/></td>
    <td><img src="./Screenshots/chatroom_light.png" width="200"/></td>
  </tr>
 </table>

### Profile

<table>
  <tr align="center">
    <td>Landing Page</td>
     <td>User foodprints map display</td>
     <td>Friend foodprint map annotation overlay</td>
  </tr>
  <tr align="center">
    <td><img src="./Screenshots/profile_dark.png" width="200"/></td>
    <td><img src="./Screenshots/profile-foodprint-overlay_dark.png" width="200"/></td>
    <td><img src="./Screenshots/profile-foodprint_dark.png" width="200"/></td>
  </tr>
    <tr align="center">
    <td><img src="./Screenshots/profile_light.png" width="200"/></td>
    <td><img src="./Screenshots/profile-foodprint-overlay_light.png" width="200"/></td>
    <td><img src="./Screenshots/profile-foodprint_light.png" width="200"/></td>
  </tr>
 </table>

### Style Guide

<img src="./Screenshots/TextStyleGuide.png" alt="TextStyleGuide" width="300"/>
<img src="./Screenshots/ButtonStyleGuide.png" alt="ButtonStyleGuide" width="300"/>
<img src="./Screenshots/CornerRadiusStyleGuide.png" alt="CornerRadiusStyleGuide" width="300"/>
<img src="./Screenshots/ToggleStyleGuide.png" alt="ToggleStyleGuide" width="300"/>

## Feature Implementation Overview

- Developed with SwiftUI, implementing the MVVM architecture coupled with Combine for enhanced flexibility and maintainability.

- Designed flexible custom UI components, incorporating a comprehensive style guide through ViewModifiers to ensure a unified and flexible app interface.

- Managed concurrent code effectively by leveraging Swift's new language features, which involved encapsulating SDK completionHandler closures within asynchronous functions.

- Bridged UIKit components(UIView / UIViewController) into SwiftUI views.

- Capturing and Previewing both food and facial images simultaneously using user’s front and back cameras, utilizing AVFoundation's API to proficiently manipulate the user's device camera.

- Implemented live streaming food sharing functionality using WebRTC, with Cloud Firestore serving as the signaling client for communication.

- Analyzed food images by category via CoreML + Vision, using a self-trained model created with CreateML for enhanced accuracy and customization.

- Search nearby restaurant data provided by Google Places API, and then render geographic data via MapKit.

- Implemented chat functionality by actively observing Cloud Firestore collection for real-time communication.

- (Undeployed) Foodie live streaming utilizing [WebRTC](https://github.com/stasel/WebRTC), implemented by designing a signaling client for observing Firestore collection.

## Tech Stack

- [SwiftUI](https://developer.apple.com/documentation/swiftui/) - A modern framework to declare user interfaces for any Apple platform
- [Combine](https://developer.apple.com/documentation/combine) - Provides a declarative Swift API for processing values over time
- [AVFoundation](https://github.com/unocss/unocss) - Work with audiovisual assets, control device cameras, process audio, and configure system audio interactions.

- [MapKit](https://developer.apple.com/documentation/mapkit) - Display map or satellite imagery within your app, call out points of interest, and determine placemark information for map coordinates
- [CoreML](https://developer.apple.com/documentation/coreml) - Integrate machine learning models into apple platform apps.
- [Vision](https://developer.apple.com/documentation/vision) - Apply computer vision algorithms to perform a variety of tasks on input images and video.
- [WebRTC](https://github.com/stasel/WebRTC) - WebRTC Binaries for iOS and macOS
- [SwiftLint](https://github.com/realm/SwiftLint) - Xcode code style linting.
