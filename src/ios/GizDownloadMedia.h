#import <Cordova/CDV.h>

@interface GizDownloadMedia : CDVPlugin

- (void)gizDownload:(CDVInvokedUrlCommand*)command;
- (void)gizCancelDownload:(CDVInvokedUrlCommand*)command;

@end
