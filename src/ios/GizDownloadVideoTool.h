#import <Foundation/Foundation.h>

@interface GizDownloadVideoTool : NSObject<NSURLSessionDelegate>


@property (nonatomic, copy) NSString *fullPath;

@property (nonatomic, copy) void (^processCallBackBlock)(double process);
@property (nonatomic, copy) void (^resultCallBackBlock)(NSError *result);

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

+ (instancetype)sharedInstance;

- (void)downloadVideoWithUrl:(NSString *)videoUrl processCallBack:(void (^)(double process))processBlock resultCallBack:(void (^)(NSError *result))resultBlock;

@end



