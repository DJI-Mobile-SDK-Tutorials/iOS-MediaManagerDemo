# iOS-MediaManagerDemo

## Introduction

This demo is designed for you to learn how to use `DJIMediaManager` to interact with the file system on the SD card of the aircraft's camera. You can use it to preview photos, play videos, download or delete files and so on.

## Requirements

 - iOS 9.0+
 - Xcode 8.0+
 - DJI iOS SDK 4.16.1
 - DJI iOS UX SDK 4.14
 - DJIWidget 1.6.4

## SDK Installation with CocoaPods

Since this project has been integrated with [DJI iOS SDK CocoaPods](https://cocoapods.org/pods/DJI-SDK-iOS) now, please check the following steps to install **DJISDK.framework** using CocoaPods after you downloading this project:

**1.** Install CocoaPods

Open Terminal and change to the download project's directory, enter the following command to install it:

~~~
sudo gem install cocoapods
~~~

The process may take a long time, please wait. For further installation instructions, please check [this guide](https://guides.cocoapods.org/using/getting-started.html#getting-started).

**2.** Install SDK with CocoaPods in the Project

Run the following command in the project's path:

~~~
pod install
~~~

If you install it successfully, you should get the messages similar to the following:

~~~
Analyzing dependencies
Downloading dependencies
Installing DJI-SDK-iOS (4.16.1)
Installing DJI-UXSDK-iOS (4.14)
Installing DJIWidget (1.6.4)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `MediaManagerDemo.xcworkspace` for this project from now on.
Pod installation complete! There is 1 dependency from the Podfile and 1 total pod
installed.
~~~

> **Note**: If you saw "Unable to satisfy the following requirements" issue during pod install, please run the following commands to update your pod repo and install the pod again:
> 
> ~~~
> pod repo update
> pod install
> ~~~

## Supported DJI Products

 - Mavic 2 Series
 - Mavic Pro
 - Spark
 - Phantom 4 Pro
 - Phantom 4 Advanced
 - Inspire 2

## Tutorial

For this demo's tutorial: **Creating a Media Manager Application**, please refer to <https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/MediaManagerDemo.html>.

## Feedback

We’d love to hear your feedback for this demo and tutorial.

Please use **Stack Overflow** [dji-sdk](https://stackoverflow.com/questions/tagged/dji-sdk) or **email** [dev@dji.com](dev@dji.com) when you meet any problems of using this demo. At a minimum please let us know:

* Which DJI Product you are using?
* Which iOS Device and iOS version you are using?
* A short description of your problem includes debug logs or screenshots.
* Any bugs or typos you come across.

## License

iOS-MediaManagerDemo is available under the MIT license. Please see the LICENSE file for more info.

## Join Us

DJI is looking for all kinds of Software Engineers to continue building the Future of Possible. Available positions in Shenzhen, China and around the world. If you are interested, please send your resume to <software-sz@dji.com>. For more details, and list of all our global offices, please check <https://we.dji.com/jobs_en.html>.

DJI 招软件工程师啦，based在深圳，如果你想和我们一起把DJI产品做得更好，请发送简历到 <software-sz@dji.com>.  详情请浏览 <https://we.dji.com/zh-CN/recruitment>.

