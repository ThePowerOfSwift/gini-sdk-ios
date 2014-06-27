# Gini iOS SDK

An SDK for integrating Gini technology into other apps. With this SDK you will be able to extract semantic information from various types of documents.


## Installation

For maximum convenience we rely on the excellent dependency manager [Cocoapods](http://www.cocoapods.org).
To install the Gini iOS SDK simply add the following repository to your Cocoapods installation

    $ pod repo add gini-podspecs https://github.com/gini/gini-podspecs.git

and include the pod in your Podfile

    pod 'Gini-iOS-SDK'

Then run
    
    $ pod install
    
in your project directory and open the generated Xcode workspace.


## Register your App with Gini

See the [API Documentation](http://developer.gini.net/gini-api/html/guides/oauth2.html#first-of-all-register-your-application-with-gini).

Please notice that your app needs to implement a custom URL scheme in order to get the session information when the
user logs in to Gini. Therefore, you need to provide a redirect_uri when registering you app with Gini. The
redirect_uri should be `your-app-scheme://gini-authorization-finished` (where "your-app-scheme"
is replaced with your actual custom URL scheme).


## Integrate the Gini iOS SDK

Import the header in your app delegate header file

    #import <GiniSDK.h>

Create an instance of the GiniSDK with your chosen clientID and the custom URL scheme

    GiniSDK *giniSDK = [GiniSDK giniSDKWithAppURLScheme:@"YOUR_APP_URL_SCHEME" clientID:@"YOUR_CLIENT_ID"];

In your app, register your custom URL scheme together with an abstract name of the URL scheme (reverse DNS-style of the 
identifier), by adding the information to your Plist file. Please refer to the 
[section "Implementing Custom URL Schemes" in the Apple Documentation](https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/AdvancedAppTricks/AdvancedAppTricks.html#//apple_ref/doc/uid/TP40007072-CH7-SW50) 
for details.

	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>YOUR_IDENTIFIER</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>YOUR_APP_URL_SCHEME</string>
			</array>
		</dict>
	</array>


Your app needs to repond on the app delegate to the incoming URL. Do this by implementing the following delegate method

    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
    {
        return [_giniSDK.sessionManager handleURL:url];
    }


## Usage

Learn how to use the Gini API at the [Gini Developer Portal](http://developer.gini.net):

- [Gini API Documentation](http://developer.gini.net/gini-api/)
- [Gini iOS SDK Documentation](http://developer.gini.net/gini-sdk-ios/)


## Usage in Swift code

In order to use the Gini SDK in Swift code, you first need to add a bridge header file. A good tutorial how to add a
bridge header file can be found at [Medium](https://medium.com/@stigi/swift-cocoapods-da09d8ba6dd2).

Inside the bridging header, you must import the Gini SDK by adding the following line:

    #import <Gini-iOS-SDK/GiniSDK.h>

After that, you can use all Gini classes inside your Swift code.


Copyright (c) 2014, [Gini GmbH](http://www.gini.net)
