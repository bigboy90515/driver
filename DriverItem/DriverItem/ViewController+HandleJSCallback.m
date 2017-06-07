//
//  ViewController+HandleJSCallback.m
//  DriverItem
//
//  Created by liangscofield on 2017/2/24.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "ViewController+HandleJSCallback.h"

#import "WXApi.h"
#import "WechatAuthSDK.h"
#import "WXApiObject.h"

@implementation ViewController (HandleJSCallback)

#pragma mark - handleJavaScriptCallBack

// 参数phones：发短信的手机号码的数组，数组中是一个即单发,多个即群发。
- (void)showMessageView:(NSArray *)phones
                  title:(NSString *)title
                   body:(NSString *)body
{
    if([MFMessageComposeViewController canSendText]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            controller.recipients = phones;
            controller.navigationBar.tintColor = [UIColor redColor];
            controller.body = body;
            controller.messageComposeDelegate = self;
            [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
            [self presentViewController:controller animated:YES completion:nil];
        });
        
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"该设备不支持短信功能"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)skipPhonePicForResult:(NSString *)callBackFun url:(NSString *)url key:(NSString *)key
{
    self.currentCallBackFun = callBackFun;
    self.currentUrl = url;
    self.currentKey = key;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIActionSheet *pActionSheet = [[UIActionSheet alloc] initWithTitle:@"您要选择?"
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"拍照上传",@"相册上传", nil];
        [pActionSheet showInView:self.view];
    });
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        });
        
        
    }
    else if (buttonIndex == 1)
    {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        });
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    NSLog(@"选择完毕----image:%@-----info:%@",image,editingInfo);
    
    [self uploadImageFunWithImage:image];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}

- (void)uploadImageFunWithImage:(UIImage *)image
{
    [self startLoadingWithMessage:@"上传图片中" withAnimated:YES];
    WeakObjectDef(self);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //接收类型不一致请替换一致text/html或别的
    
    NSDictionary *parameters =@{@"key":self.currentKey};
    
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"image/jpeg",@"image/png",@"application/octet-stream",@"text/json",nil];
    
    NSString *uploadPicUrl = [NSString stringWithFormat:@"%@%@",kMainHostUrl,self.currentUrl];
    
    [manager POST:uploadPicUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
        NSData *imageData = UIImageJPEGRepresentation(image,0.8);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =@"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:imageData
                                    name:self.currentKey
                                fileName:fileName
                                mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress *_Nonnull uploadProgress) {
        
        NSLog(@"上传进度  %2f", uploadProgress.completedUnitCount/(CGFloat)uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"上传成功");
        [weakself stopLoading];
        [self progressHUD].labelText = @"加载中...";
        
        
        NSHTTPURLResponse * taskresponse =(NSHTTPURLResponse *) task.response;
        NSLog(@"(long)taskresponse.statusCodegetimgarr  %ld",(long)taskresponse.statusCode );
        
        if ((long)taskresponse.statusCode == 200)
        {
            NSDictionary *dic = (NSDictionary * )responseObject;
            NSString *keyValue = [self changeStringJsonModel:dic];
            
            JSValue *squareFunc = self.context[self.currentCallBackFun];
            [squareFunc callWithArguments:@[self.currentKey,keyValue]];
        }
        
    } failure:^(NSURLSessionDataTask *_Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"上传失败");
        [weakself stopLoading];
        [self progressHUD].labelText = @"加载中...";
        
    }];
    
}

// 字典转字符串
- (NSString *)changeStringJsonModel:(NSDictionary *)dictModel
{
    if ([NSJSONSerialization isValidJSONObject:dictModel])
    {
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictModel options:NSJSONWritingPrettyPrinted error:nil];
        NSString * jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonStr;
    }
    return nil;
}


- (void)handleShareAction:(GWWeChatShareInfo *)weChatShareInfo
{
    if ([WXApi isWXAppInstalled] == NO) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"你还没有安装微信,请先安装!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        });
        
    } else {
        
        self.weChatShareInfo = weChatShareInfo;
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.description = weChatShareInfo.desc;
        message.title = weChatShareInfo.title;
        NSUInteger maxLenTitle = 256;
        if (message.title.length > maxLenTitle) {
            message.title = [message.title substringToIndex:maxLenTitle-1];
        }
        
        NSUInteger maxLen = 500;
        if (message.description.length > maxLen) {
            message.description = [message.description substringToIndex:maxLen-1];
        }
        UIImage *defaultImage = [UIImage imageNamed:@"logo"];
        NSData *thumbData = UIImageJPEGRepresentation(defaultImage, 0.9);
        
        [message setThumbData:thumbData];
        
        WXWebpageObject* webPageObject = [WXWebpageObject object];
        webPageObject.webpageUrl = weChatShareInfo.url;
        message.mediaObject = webPageObject;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = weChatShareInfo.isTimelineCb ? WXSceneTimeline : WXSceneSession;
        [WXApi sendReq:req];
        
    }
}

- (NSString *)handleUpdatingLocation:(NSTimeInterval)timeInterval totalTime:(NSTimeInterval)totalTime
{
    return nil;
    
//    NSTimeInterval startTime = 0;
//    
//    while(totalTime > startTime) {
//        
//        if ([GWJSObjectInfo hasLocationSuccess]) {
//            return [GWJSObjectInfo getCurrnetLocationInfo];
//        }
//        
//        [self.locationManager startUpdatingLocation];
//        startTime += timeInterval;
//        [NSThread sleepForTimeInterval:timeInterval];
//    }
//    
//    return nil;
}



@end
