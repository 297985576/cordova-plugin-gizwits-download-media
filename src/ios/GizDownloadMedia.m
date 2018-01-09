#import "GizDownloadMedia.h"
#import "GizDownloadVideoTool.h"

typedef NS_ENUM(NSUInteger, GizDownloadMediaCallBack) {
    GizDownloadMediaCallBackProgress,
    GizDownloadMediaCallBackSuccess,
    GizDownloadMediaCallBackError,
};

@interface GizDownloadMedia()

@property(nonatomic, strong)CDVInvokedUrlCommand *command;
@property(nonatomic, assign)double proccess;

@end

@implementation GizDownloadMedia

- (void)gizDownload:(CDVInvokedUrlCommand*)command{
    self.command = command;

    if (command.arguments && command.arguments.firstObject) {
        id firstObj = command.arguments.firstObject;
        if ([firstObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *attrs = (NSDictionary *)firstObj;
            NSLog(@"\n--------------------- 【cordova-gizwits-download-media parameters】 ---------------------\n%@", attrs);
            
            if (attrs.count) {
                NSString *urlString = [attrs objectForKey:@"url"];
                if (urlString && urlString.length) {
                    [self startDownloadWithResourceUrl:urlString];
                } else{
                    [self downLoadHandleWithResultCode:GizDownloadMediaCallBackError msg:@"url error"];
                }
            }
        }
    }
}

- (void)gizCancelDownload:(CDVInvokedUrlCommand*)command{
    self.command = command;
    [[GizDownloadVideoTool sharedInstance].downloadTask cancel];
    NSLog(@"下载已取消");
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"下载已取消"] callbackId:self.command.callbackId];
    
}

- (void)startDownloadWithResourceUrl:(NSString *)url{
    __weak __typeof(self)weakSelf = self;
    [[GizDownloadVideoTool sharedInstance] downloadVideoWithUrl:url processCallBack:^(double process) {
        [weakSelf downLoadHandleWithResultCode:GizDownloadMediaCallBackProgress msg:[NSString stringWithFormat:@"%.2f%%",process*100]];
    } resultCallBack:^(NSError *error) {
        if (!error) {
            [weakSelf downLoadHandleWithResultCode:GizDownloadMediaCallBackSuccess msg:@"download successfully"];
        }else{
            [weakSelf downLoadHandleWithResultCode:GizDownloadMediaCallBackError msg:@"download failed"];
        }
    }];
}

- (void)downLoadHandleWithResultCode:(GizDownloadMediaCallBack)resultCode msg:(NSString *)msg{
    
    CDVPluginResult* pluginResult = nil;
    NSString *resultString = @"";
    
    if (resultCode == GizDownloadMediaCallBackProgress) {
        resultString = [NSString stringWithFormat:@"{\"progress\": \"%@\", \"completed\": \"false\"}", msg];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultString];
    } else if (resultCode == GizDownloadMediaCallBackSuccess){
        resultString = [NSString stringWithFormat:@"{\"progress\": \"100.00%%\", \"completed\": \"true\"}"];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultString];
    } else if (resultCode == GizDownloadMediaCallBackError){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
    }
    
    [pluginResult setKeepCallback:[NSNumber numberWithBool:(resultCode == GizDownloadMediaCallBackProgress)]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

@end
