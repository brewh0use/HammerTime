//
//  AppDelegate.m
//  ExampleApp-OSX
//
//  Created by Robert Brauer on 21/05/14.
//  Copyright (c) 2014 Robert Brauer. All rights reserved.
//

#import "AppDelegate.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"

@implementation AppDelegate {
    WebView* _webView;
    WebViewJavascriptBridge* _bridge;
    NSString* _currentAppName;
    CFTimeInterval _sessionTime;
    Boolean appHasPermission;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // See if we have accessibility permissions, and if not, prompt the user to
    // visit System Preferences.
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    appHasPermission = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
    
    //Set up Web UI
    [self _initWebView];
        //[self _createObjcButtons];
    
    _sessionTime = CACurrentMediaTime(); //Start initial tracking session
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(theAction)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)_initWebView {
    
    //Create Views
    NSView* contentView = _window.contentView;
    _webView = [[WebView alloc] initWithFrame:contentView.frame];
    _webView.preferences.userStyleSheetEnabled = YES;
    _webView.preferences.userStyleSheetLocation = [[NSBundle mainBundle] URLForResource:@"UI" withExtension:@"css"];
    [_webView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    [contentView addSubview:_webView];
    
    //Create Bridge
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    //Send a message to UI
    [_bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
        NSLog(@"objc got response! %@", responseData);
    }];
    
    /*[_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];*/
    
    /*[_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];*/
    
    //Load page
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"UI" ofType:@"html"];
    NSString* html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [[_webView mainFrame] loadHTMLString:html baseURL:nil];
}

/*- (void)_createObjcButtons {
 NSButton *messageButton = [[NSButton alloc] initWithFrame:NSMakeRect(5, 0, 120, 40)];
 [messageButton setTitle:@"Send message"];
 [messageButton setBezelStyle:NSRoundedBezelStyle];
 [messageButton setTarget:self];
 [messageButton setAction:@selector(_sendMessage)];
 [_webView addSubview:messageButton];
 
 NSButton *callbackButton = [[NSButton alloc] initWithFrame:NSMakeRect(120, 0, 120, 40)];
 [callbackButton setTitle:@"Call handler"];
 [callbackButton setBezelStyle:NSRoundedBezelStyle];
 [callbackButton setTarget:self];
 [callbackButton setAction:@selector(_callHandler)];
 [_webView addSubview:callbackButton];
}

- (void)_sendMessage {
    [_bridge send:@"A string sent from ObjC to JS" responseCallback:^(id response) {
        NSLog(@"sendMessage got response: %@", response);
    }];
}

- (void)_callHandler {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}*/

-(void) theAction {
    NSRunningApplication* runningApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    //NSLog(@"Active application is: %@", runningApp.bundleIdentifier );
    
    if (![_currentAppName isEqualToString:runningApp.localizedName]) //Check if it's a new app... if so, list it and add time stamp
    {
        CFTimeInterval elapsedTime = CACurrentMediaTime() - _sessionTime; //how long the app has been used
        _sessionTime = CACurrentMediaTime(); //new session start
        
        NSDate *now = [NSDate date]; //get the current time for display
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"HH:mm"];
        
        NSLog(@"%@ (%i sec) - %@ \n", [outputFormatter stringFromDate:now], (int) (elapsedTime + 0.5), _currentAppName);
        
        _currentAppName = runningApp.localizedName; //new app
        
        pid_t pid = [runningApp processIdentifier];
        
        if (!appHasPermission) {
            return; // we don't have accessibility permissions
            
            // Get the accessibility element corresponding to the frontmost application.
            AXUIElementRef appElem = AXUIElementCreateApplication(pid);
            if (!appElem) {
                return;
            }
            
            // Get the accessibility element corresponding to the frontmost window
            // of the frontmost application.
            AXUIElementRef window = NULL;
            if (AXUIElementCopyAttributeValue(appElem,
                                              kAXFocusedWindowAttribute, (CFTypeRef*)&window) != kAXErrorSuccess) {
                CFRelease(appElem);
                return;
            }
            
            // Finally, get the title of the frontmost window.
            CFStringRef title = NULL;
            AXError result = AXUIElementCopyAttributeValue(window, kAXTitleAttribute,
                                                           (CFTypeRef*)&title);
            
            // At this point, we don't need window and appElem anymore.
            CFRelease(window);
            CFRelease(appElem);
            
            if (result != kAXErrorSuccess) {
                // Failed to get the window title.
                return;
            }
            
            // Success! Now, do something with the title, e.g. copy it somewhere.
            
            // Once we're done with the title, release it.
            CFRelease(title);
        }
    }
}

@end
