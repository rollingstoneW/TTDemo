//
//  TTShareManager.m
//  TTKit
//
//  Created by rollingstoneW on 15/12/9.
//  Copyright © 2015年 TTKit. All rights reserved.
//

#import "TTShareManager.h"

#define noQQ     @"你还没有安装QQ哦"
#define noWeiXin @"你还没有安装微信哦"


#define WX_ACCESS_TOKEN @"access_token"
#define WX_OPEN_ID @"openid"
#define WX_REFRESH_TOKEN @"refresh_token"
#define WX_UNION_ID @"unionid"
#define WX_BASE_URL @"https://api.weixin.qq.com/sns"


@interface TTShareManager()
//@property (strong,nonatomic) TencentOAuth  *tencentOAuth;
//@property (strong) SinaWeibo  *sinaweibo;
//@property (nonatomic,copy) void(^WXLoginBlock)(NSString *);
//@property (nonatomic,copy) void(^QQLoginBlock)(NSString *,NSString *,uint64_t);
@end

@implementation TTShareManager
{
    NSDictionary *actionItem;
    NSString *shareText;
    UIImage *shareImage;
    NSString *WXState;
}

//- (id)init{
//    if (self = [super init]) {
//        // 初始化新浪微博
////        self.sinaweibo = [[SinaWeibo alloc] initWithAppKey:[TTKitThirdPartyKeyManager sharedInstance].getWeiBoAPPKey appSecret:[TTKitThirdPartyKeyManager sharedInstance].getWeiBoAPPSecret appRedirectURI:@"http://zhidao.baidu.com" ssoCallbackScheme:@"sinaweibo.20131220.TTKit://share.callback" andDelegate:self];
////        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
////        NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
////        if ([sinaweiboInfo objectForKeySafely:@"AccessTokenKey"] && [sinaweiboInfo objectForKeySafely:@"ExpirationDateKey"] && [sinaweiboInfo objectForKeySafely:@"UserIDKey"])
////        {
////            _sinaweibo.accessToken = [sinaweiboInfo objectForKeySafely:@"AccessTokenKey"];
////            _sinaweibo.expirationDate = [sinaweiboInfo objectForKeySafely:@"ExpirationDateKey"];
////            _sinaweibo.userID = [sinaweiboInfo objectForKeySafely:@"UserIDKey"];
////        }
////        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sinaweiboLoginSuccess:) name: @"kSinaWeiboLoginSuccss" object: nil];
//    }
//    return self;
//}
//
//- (void) dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//#pragma mark -- public method
//+ (BOOL)registWechatWithAppID:(NSString *)appID AndDescription:(NSString *)description{
//    return [WXApi registerApp:appID enableMTA:false];
//}
//
//+ (void)registQQWithAppID:(NSString *)appID AndDelegate:(id<TencentSessionDelegate>)delegate{
//    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:appID andDelegate:delegate];
//    if (tencentOAuth){
//        [TTShareManager sharedInstance].tencentOAuth = tencentOAuth;
//    }
//}
//
//- (void)loginWithQQ:(void(^)(NSString *,NSString *,uint64_t))complete{
//    if (![TencentOAuth iphoneQQInstalled]) {
//        [self.tencentOAuth authorize:@[@"get_simple_userinfo"] localAppId:[TTKitThirdPartyKeyManager sharedInstance].getTencentShareAPPKey inSafari:YES];
//    }else{
//        [self.tencentOAuth authorize:@[@"get_simple_userinfo"] localAppId:[TTKitThirdPartyKeyManager sharedInstance].getTencentShareAPPKey inSafari:NO];
//    }
//    self.QQLoginBlock = complete;
//}
//- (void)loginWithWX:(void(^)(NSString *))complete{
//    if (![WXApi isWXAppInstalled]) {
//        [self showAToast:noWeiXin];
//        return;
//    }
//    NSString *md5Cuid = [TTKitCommunicationTool md5WithEncodiong:NSUTF8StringEncoding string:[[APPInfoManager sharedInstance] cuid]];
//    WXState = [TTKitCommunicationTool md5WithEncodiong:NSUTF8StringEncoding string:[md5Cuid stringByAppendingString:[NSString stringWithFormat:@"%f",[NSDate date].timeIntervalSince1970]]];
//
//    SendAuthReq *req = [[SendAuthReq alloc] init];
//    req.scope = @"snsapi_userinfo";
//    req.state = WXState;
//    [WXApi sendReq:req];
//    self.WXLoginBlock = complete;
//}
//
//- (void)shareWeiboWithData:(TTShareData *)shareEntity AndShareContentType:(ShareContentType)ShareContentType completion:(TTShareCompleteBlock)completeBlock{
//    UIImage *thumbImg =  shareEntity.contentImage ? shareEntity.contentImage :shareEntity.logoImage;
//    if (shareEntity.logoImage.size.height  > 100 && shareEntity.logoImage.size.width > 200) {
//        thumbImg = [shareEntity.logoImage resizedImageWithMaxSize:CGSizeMake(200, 100) interpolationQuality:kCGInterpolationDefault];
//    }
//    shareText = [actionItem objectForKeySafely: @"value"];
//    shareImage = thumbImg;
//
//    shareText = shareEntity.title;
//    if (shareEntity.content) {
//        shareText = [shareText stringByAppendingFormat:@":%@", shareEntity.content];
//    }
//    if (ShareContentType == ShareContentTypeWebpage) {
//        shareText = [shareText stringByAppendingFormat:@"%@", shareEntity.webpageUrl];
//    }
//    NSString *weiboOfficialWeiboNameAndLinkString = @"（想了解更多？@作业帮App，下载APP:http://www.TTKitang.com/）";
//    shareText = [shareText stringByAppendingString:weiboOfficialWeiboNameAndLinkString];
//
//    if (_sinaweibo.isAuthValid) {
//        [self showAToast:@"正在分享到微博"];
//        [self sendMsg2Weibo];
//    } else {
//        [_sinaweibo logIn];
//    }
//
//    self.callBackBlock = completeBlock;
//}
//
//- (void)shareQQWithData:(TTShareData *)shareEntity QQType:(ShareTencentType)type completion:(TTShareCompleteBlock)completeBlock{
//    if (![TencentOAuth iphoneQQInstalled]) {
//        [self showAToast:noQQ];
//        return;
//    }
//
//
//    NSData *imageData;
//    if (UIImagePNGRepresentation(shareEntity.logoImage) == nil) {
//        imageData = UIImageJPEGRepresentation(shareEntity.logoImage, 1);
//    }else{
//        imageData = UIImagePNGRepresentation(shareEntity.logoImage);
//    }
//
//    NSString *titleString;
//    if (type == ShareTencentTypeQQ && shareEntity.shouldReplaceTitleForQQ) {
//        titleString = [UIDevice tt_appDisplayName];
//    }else{
//        titleString = shareEntity.title;
//    }
//    SendMessageToQQReq *req;
//
//    if (shareEntity.shareType == TTShareDataTypeWebUrl) {
//        QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:shareEntity.webpageUrl]
//                                                            title:titleString   // shareEntity.title
//                                                      description:shareEntity.content
//                                                 previewImageData:imageData];
//        req = [SendMessageToQQReq reqWithContent:newsObj];
//    }else if (shareEntity.shareType == TTShareDataTypeImage){
//        NSData *imageData;
//        if (UIImagePNGRepresentation(shareEntity.contentImage) == nil) {
//            imageData = UIImageJPEGRepresentation(shareEntity.contentImage, 1);
//        }else{
//            imageData = UIImagePNGRepresentation(shareEntity.contentImage);
//        }
//        UIImage *newImage = [shareEntity.contentImage resizedImageWithMaxSize:CGSizeMake(shareEntity.contentImage.size.width*.2f, shareEntity.contentImage.size.height*.2f) interpolationQuality:kCGInterpolationLow];
//        newImage = [newImage compression:1 maxSize:1024*3];
//        NSData *preViewImageData;
//        if (UIImagePNGRepresentation(newImage) == nil) {
//            preViewImageData = UIImageJPEGRepresentation(newImage, 1);
//        }else{
//            preViewImageData = UIImagePNGRepresentation(newImage);
//        }
//        if (type == ShareTencentTypeQQ) {
//            QQApiImageObject *imageObj = [QQApiImageObject objectWithData:imageData previewImageData:preViewImageData title:titleString description:shareEntity.content imageDataArray:nil];
//            req = [SendMessageToQQReq reqWithContent:imageObj];
//        }else{
//            QQApiImageArrayForQZoneObject *imageQZObj = [QQApiImageArrayForQZoneObject objectWithimageDataArray:@[imageData] title:nil];
//            req = [SendMessageToQQReq reqWithContent:imageQZObj];
//        }
//    } else if (shareEntity.shareType == TTShareDataTypeMusic) {
//        QQApiAudioObject *audioObj = [QQApiAudioObject objectWithURL:[NSURL URLWithString:shareEntity.webpageUrl]
//                                                               title:titleString
//                                                         description:shareEntity.content
//                                                    previewImageData:imageData];
//        audioObj.flashURL = [NSURL URLWithString:shareEntity.musicDataUrl];
//        req = [SendMessageToQQReq reqWithContent:audioObj];
//    }else if (shareEntity.shareType == TTShareDataTypeFile){
//        //http://wiki.connect.qq.com/ios-登录及分享
//        QQApiFileObject *fileObj = [QQApiFileObject objectWithData:shareEntity.fileData previewImageData:nil title:@"" description:@""];
//        NSString *replaceString = [titleString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];///<当前版本分享SDK遇到/分享不出去，替换成其他字符_
//        fileObj.fileName =[replaceString stringByAppendingPathExtension:shareEntity.fileExtension];
//        [fileObj setCflag:kQQAPICtrlFlagQQShareDataline];
//        req = [SendMessageToQQReq reqWithContent:fileObj];
//    }
//
//    switch (type) {
//        case ShareTencentTypeQQ:{
//            QQApiSendResultCode sendResult = [QQApiInterface sendReq:req]; // 将内容分享到qq
//            self.callBackBlock = completeBlock;
//            if (sendResult){
//            }
//        }
//            break;
//
//        case ShareTencentTypeQZone:{
//            //将内容分享到qzone
//            QQApiSendResultCode sendResult = [QQApiInterface SendReqToQZone:req];
//            if (sendResult){
//            }
//            self.callBackBlock = completeBlock;
//
//        }
//            break;
//        default:
//            break;
//    }
//
//}
//
//
//- (void)shareWechatWithData:(TTShareData *)shareEntity wechatType:(ShareWechatType)type completion:(TTShareCompleteBlock)completeBlock{
//
//    // 判断微信是否安装
//    if (![WXApi isWXAppInstalled]) {
//        [self showAToast:noWeiXin];
//        return;
//    }
//    // 微信好友音频分享暂时没有权限，所以改成网页消息分享
//    if (type == ShareWechatTypeSceneSession && shareEntity.shareType == TTShareDataTypeMusic) {
//        shareEntity.shareType = TTShareDataTypeWebUrl;
//        // 朋友圈不支持小程序，所以转成Image或者Web
//    } else if (type == ShareWechatTypeTimeLine && shareEntity.shareType == TTShareDataTypeMiniProgram) {
//        if (shareEntity.contentImage) {
//            shareEntity.shareType = TTShareDataTypeImage;
//        } else {
//            shareEntity.shareType = TTShareDataTypeWebUrl;
//        }
//    }
//
//    WXMediaMessage *message = [WXMediaMessage message];
//    id ext = nil;
//    if (shareEntity.shareType == TTShareDataTypeWebUrl) {
//        ext = [WXWebpageObject object];
//        ((WXWebpageObject *)ext).webpageUrl = shareEntity.webpageUrl;
//        [message setThumbImage:shareEntity.logoImage];
//    }else if (shareEntity.shareType == TTShareDataTypeImage){
//        ext = [WXImageObject object];
//        NSData *imageData;
//        if (UIImagePNGRepresentation(shareEntity.contentImage) == nil) {
//            imageData = UIImageJPEGRepresentation(shareEntity.contentImage, 1);
//        }else{
//            imageData = UIImagePNGRepresentation(shareEntity.contentImage);
//        }
//        ((WXImageObject *)ext).imageData = imageData;
//        UIImage *newImage = [shareEntity.contentImage resizedImageWithMaxSize:CGSizeMake(shareEntity.contentImage.size.width*.2f, shareEntity.contentImage.size.height*.2f) interpolationQuality:kCGInterpolationLow];
//        [message setThumbImage:[newImage compression:1 maxSize:1024*3]];
//    } else if (shareEntity.shareType == TTShareDataTypeMusic) {
//        WXMusicObject *musicObject = [WXMusicObject object];
//        musicObject.musicUrl = shareEntity.webpageUrl;
//        musicObject.musicDataUrl = shareEntity.musicDataUrl;
//        ext = musicObject;
//
//        if (shareEntity.logoImage) {
//            [message setThumbImage:shareEntity.logoImage];
//        }
//    } else if (shareEntity.shareType == TTShareDataTypeFile){
//        WXFileObject *fileObject = [WXFileObject object];
//        fileObject.fileExtension = shareEntity.fileExtension;
//        fileObject.fileData = shareEntity.fileData;
//        ext =fileObject;
//        if (shareEntity.logoImage) {
//            [message setThumbImage:shareEntity.logoImage];
//        }
//    } else if (shareEntity.shareType == TTShareDataTypeMiniProgram) {
//        WXMiniProgramObject *object = [WXMiniProgramObject object];
//        object.userName = shareEntity.miniProgramId;
//        object.path = shareEntity.miniProgramPath;
//        object.webpageUrl = shareEntity.webpageUrl;
//        object.hdImageData = UIImageJPEGRepresentation(shareEntity.contentImage, 1);
//        ext = object;
//    }
//
//    message.title = shareEntity.title;
//    message.description = shareEntity.content;
//    message.mediaObject = ext;
//
//    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
//    req.bText = NO;
//    req.message = message;
//    req.scene = type;
//    [WXApi sendReq:req];
//
//    self.callBackBlock = completeBlock;
//}
//
//
//#pragma mark -- QQ delegate
//- (void)tencentDidLogin{
//    if (!isNull(self.QQLoginBlock)) {
//        self.QQLoginBlock([self.tencentOAuth getUserOpenID],[self.tencentOAuth accessToken],[[self.tencentOAuth expirationDate] timeIntervalSince1970]);
//    }
//}
//- (void)tencentDidNotNetWork{
//    [self showAToast:@"网络错误"];
//}
//- (void)tencentDidNotLogin:(BOOL)cancelled{
//    [TTKitNlog logWithEventType:kEventTypeClick labe:LOGIN_BINDTHIRDPARTY_GET_TOKEN params:@{@"type" : @(1),@"result" : @(0)}];
//    if (cancelled) {
//        [self showAToast:@"您取消了授权"];
//    }else{
//        [self showAToast:@"授权失败"];
//    }
//}
//- (void)onReq:(QQBaseReq *)req{
//}
//- (void)isOnlineResponse:(NSDictionary *)response{
//}
//
//- (void)getUserInfoResponse:(APIResponse*) response{
//}
//
//#pragma mark -- WeiXin delegate
//-(void) onResp:(id)resp{
//    if ([resp isKindOfClass:[SendMessageToWXResp class]]) { // 微信
//        SendMessageToWXResp *WXResp = (SendMessageToWXResp *)resp;
//        if (WXResp.errCode == 0) {
//            if (self.callBackBlock) {
//                self.callBackBlock(WXResp.errStr,YES);
//            }
//        }else if (WXResp.errCode == -1 || WXResp.errCode == -2 || WXResp.errCode == -3 || WXResp.errCode == -4 || WXResp.errCode == -5){
//            if (self.callBackBlock) {
//                self.callBackBlock(WXResp.errStr,NO);
//            }
//        }
//    }else if ([resp isKindOfClass:[SendMessageToQQResp class]]) {   //QQ Qzone
//        SendMessageToQQResp *QQResp = (SendMessageToQQResp *)resp;
//        if ([QQResp.result integerValue] == 0) {
//            if (self.callBackBlock) {
//                self.callBackBlock(QQResp.errorDescription,YES);
//            }
//        }else {
//            if (self.callBackBlock) {
//                self.callBackBlock(QQResp.errorDescription, NO);
//            }
//        }
//    }else if ([resp isKindOfClass:[SendAuthResp class]]) {
//        SendAuthResp *temp = (SendAuthResp *)resp;
//        if ([temp.state isEqualToString:WXState]) {
//            if (!isNull(self.WXLoginBlock)) {
//                self.WXLoginBlock(temp.code);
//            }else{
//                [TTKitNlog logWithEventType:kEventTypeClick labe:LOGIN_BINDTHIRDPARTY_GET_TOKEN params:@{@"type" : @(2),@"result" : @(0)}];
//            }
//        }else{
//            [self showAToast:@"授权失败"];
//            [TTKitNlog logWithEventType:kEventTypeClick labe:LOGIN_BINDTHIRDPARTY_GET_TOKEN params:@{@"type" : @(2),@"result" : @(0)}];
//        }
//
//    }
//}
//#pragma mark -- WeiBo delegate
//- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error{
//    if (self.callBackBlock) {
//        self.callBackBlock(error,NO);
//    }
//}
//
//- (void) request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result{
//    if (self.callBackBlock) {
//        self.callBackBlock(result,YES);
//    }
//}
//
//- (void) sinaweiboDidLogIn:(SinaWeibo *)sinaweibo{
//    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
//                              sinaweibo.accessToken, @"AccessTokenKey",
//                              sinaweibo.expirationDate, @"ExpirationDateKey",
//                              sinaweibo.userID, @"UserIDKey",
//                              sinaweibo.refreshToken, @"refresh_token", nil];
//    [[NSUserDefaults standardUserDefaults] setValue:authData forKey:@"SinaWeiboAuthData"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    [self sendMsg2Weibo];
//
//}
//- (void) sinaweiboLoginSuccess: (NSNotification *) noti
//{
//    int expVal = [[noti.userInfo objectForKeySafely: @"remind_in"] intValue];
//    NSDate *expirationDate = (expVal == 0)? [NSDate distantFuture] : [NSDate dateWithTimeIntervalSinceNow:expVal];
//
//    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
//                              [noti.userInfo objectForKeySafely: @"access_token"], @"AccessTokenKey",
//                              expirationDate, @"ExpirationDateKey",
//                              [noti.userInfo objectForKeySafely: @"uid"], @"UserIDKey", nil];
//    [[NSUserDefaults standardUserDefaults] setValue:authData forKey:@"SinaWeiboAuthData"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    _sinaweibo.accessToken = [authData objectForKeySafely:@"AccessTokenKey"];
//    _sinaweibo.expirationDate = [authData objectForKeySafely:@"ExpirationDateKey"];
//    _sinaweibo.userID = [authData objectForKeySafely:@"UserIDKey"];
//
//    [self performSelector: @selector(sendMsg2Weibo) withObject: nil afterDelay: 0.3];
//
//}
//- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo{
//    if (self.callBackBlock) {
//        NSError *error = [NSError errorWithDomain:@"SINA_WEIBO_LOGIN_DOMAIN" code:10023 userInfo:nil];
//        self.callBackBlock(error,NO);
//    }
//}
//
//#pragma mark -- private method
//- (void)showAToast:(NSString *)toast{
//    MBProgressHUD *tipHud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    tipHud.labelFont = UI_NORMAL_FONT(16);
//    tipHud.mode = MBProgressHUDModeText;
//    tipHud.labelText = toast;
//    tipHud.margin = 10.f;
//    tipHud.removeFromSuperViewOnHide = YES;
//    [tipHud hide:YES afterDelay:1.5f];
//}
//
//- (void)sendMsg2Weibo
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   shareText, @"status",
//                                   nil];
//    NSString *postUrl = @"statuses/share.json";
//    if (!shareImage) {
//        [params setObject:shareImage forKeySafely:@"pic"];
//        //        postUrl = @"statuses/upload.json";
//    }
//    [_sinaweibo requestWithURL:postUrl
//                        params:params
//                    httpMethod:@"POST"
//                      delegate:self];
//}

@end
