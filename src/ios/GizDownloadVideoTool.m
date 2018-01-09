#import "GizDownloadVideoTool.h"
#import <UIKit/UIKit.h>

@implementation GizDownloadVideoTool

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GizDownloadVideoTool *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

//下载视频
- (void)downloadVideoWithUrl:(NSString *)videoUrl processCallBack:(void (^)(double process))processBlock resultCallBack:(void (^)(NSError *result))resultBlock{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //2.请求路径
    NSURL *url = [NSURL URLWithString:videoUrl];
    //3.创建task
    _downloadTask = [session downloadTaskWithURL:url];
    //4.启动task
    [_downloadTask resume];
    self.processCallBackBlock = ^(double process) {
        processBlock(process);
    };
    self.resultCallBackBlock = ^(NSError *result) {
        resultBlock(result);
    };
}


#pragma mark -NSURLSessionDownloadDelegate Function
// 下载数据的过程中会调用的代理方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if (self.processCallBackBlock) {
        self.processCallBackBlock(1.0 * totalBytesWritten / totalBytesExpectedToWrite);
    }
    NSLog(@"下载进度：%f",1.0 * totalBytesWritten / totalBytesExpectedToWrite);
}

// 重新恢复下载的代理方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

// 写入数据到本地的时候会调用的方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    _fullPath =
    [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
     stringByAppendingPathComponent:downloadTask.response.suggestedFilename];;
    [[NSFileManager defaultManager] moveItemAtURL:location
                                            toURL:[NSURL fileURLWithPath:_fullPath]
                                            error:nil];
}
// 请求完成，错误调用的代理方法
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (self.resultCallBackBlock) {
        if (error) {
            self.resultCallBackBlock(error);
            NSLog(@"下载失败");
        }else{
            [self saveVideo:_fullPath];
            NSLog(@"下载成功，正在保存");
        }
    }
}

- (void)saveVideo:(NSString *)videoPath{
    if (videoPath) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

//保存视频完成之后的回调
- (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    [[NSFileManager defaultManager] removeItemAtPath:_fullPath error:nil];
    if (self.resultCallBackBlock) {
        self.resultCallBackBlock(error);
    }
    if (error) {
        NSLog(@"保存失败");
    }else{
        NSLog(@"保存成功");
    }
}


@end
