//
//  AppDelegate.m
//  ExampleApp-OSX
//
//  Created by Marcus Westin on 6/8/13.
//  Copyright (c) 2013 Marcus Westin. All rights reserved.
//

#import "AppDelegate.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"

@implementation AppDelegate {
    WebView* _webView;
    WebViewJavascriptBridge* _bridge;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self _initWebView];
    //[self _createObjcButtons];
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

@end
