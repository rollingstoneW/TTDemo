////
////  SNImagePickerHelper.m
////  Uhouzz
////
////  Created by 韦振宁 on 16/5/17.
////  Copyright © 2016年 Uhouzz. All rights reserved.
////
//
//#import "SNImagePickerHelper.h"
//#import "AVCaptureDevice+SNPermission.h"
//#import <MobileCoreServices/UTCoreTypes.h>
//#import "UIImage+SNExtension.h"
//#import <objc/runtime.h>
//#import "NSBundle+AppSource.h"
//
//@implementation PHAsset (Query)
//
//- (void) requestFullScreenImageWithCompletion:(PHAssetRequestImageCompletion)completion {
//    if (self.fullScreenImage) {
//        TTSafeBlock(completion, self.fullScreenImage, nil);
//        return;
//    }
//    CGSize size;
//    
//    CGFloat scale_width = CGRectGetWidth([UIScreen mainScreen].bounds) * [UIScreen mainScreen].scale;
//    CGFloat scale_height = CGRectGetHeight([UIScreen mainScreen].bounds) * [UIScreen mainScreen].scale;
//    
//    CGFloat screenRatio = scale_width / scale_height;
//    CGFloat imageRatio = self.pixelWidth / self.pixelHeight;
//    
//    if (self.pixelWidth > scale_width && self.pixelHeight > scale_height) {
//        if (imageRatio > screenRatio) {
//            size = CGSizeMake(scale_width, scale_width / self.pixelWidth * self.pixelHeight);
//        } else if (imageRatio < screenRatio) {
//            size = CGSizeMake(scale_height, scale_height / self.pixelHeight * self.pixelWidth);
//        } else {
//            size = CGSizeMake(scale_width, scale_height);
//        }
//    } else {
//        size = CGSizeMake(self.pixelWidth, self.pixelHeight);
//    }
//    
//    @weakify(weakSelf);
//    [self requestImageWithSize:size completion:^(UIImage *image, NSError *error) {
//        if (image) {
//            image = [UIImage fixOrientation:image];
//            weakSelf.fullScreenImage = image;
//        }
//        kSafeBlock(completion, image, error);
//    }];
//}
//
//- (void) requestOriginalImageWithCompletion:(PHAssetRequestImageCompletion)completion {
//    if (self.originalImage) {
//        kSafeBlock(completion, self.originalImage, nil);
//        return;
//    }
//    
//    @weakify(weakSelf);
//    [self requestImageWithSize:PHImageManagerMaximumSize Completion:^(UIImage *image, NSError *error) {
//        if (image) {
//            image = [UIImage fixOrientation:image];
//            weakSelf.originalImage = image;
//        }
//        kSafeBlock(completion, image, error);
//    }];
//}
//
//- (void) requestImageWithSize:(CGSize)size completion:(PHAssetRequestImageCompletion)completion {
//    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
//    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//    option.resizeMode = PHImageRequestOptionsResizeModeFast;
//    option.networkAccessAllowed = YES;
//    
//    [[PHImageManager defaultManager] requestImageForAsset:self
//                                               targetSize:size
//                                              contentMode:PHImageContentModeAspectFill
//                                                  options:option
//                                            resultHandler:
//     ^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
//         kSafeBlock(completion, result, info[PHImageErrorKey]);
//     }];
//}
//
//- (void) requestVideoURLWithCompletion:(PHAssetRequestVideoURLCompletion)completion {
//    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
//    option.networkAccessAllowed = YES;
//    
//    [[PHImageManager defaultManager] requestAVAssetForVideo:self
//                                                    options:option
//                                              resultHandler:^(AVAsset *newAsset, AVAudioMix *_Nullable audioMix, NSDictionary *_Nullable info)
//     {
//         if ([newAsset isKindOfClass:[AVURLAsset class]]) {
//             AVURLAsset *URLAsset = (AVURLAsset *)newAsset;
//             self.videoURL = URLAsset.URL;
//             kSafeBlock(completion, URLAsset.URL, nil);
//             return;
//         }
//         kSafeBlock(completion, nil, info[PHImageErrorKey]);
//     }];
//}
//
//+ (instancetype) assetWithMediaInfo:(NSDictionary *)info {
//    PHAsset *asset = [[PHAsset alloc] init];
//    
//    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
//    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
//        UIImage *image;
//        if ([info objectForKey:UIImagePickerControllerEditedImage]) {
//            image = [info objectForKey:UIImagePickerControllerEditedImage];
//        } else {
//            image = [info objectForKey:UIImagePickerControllerOriginalImage];
//        }
//        image = [UIImage fixOrientation:image];
//        asset.fullScreenImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.3)];
//        asset.originalImage = image;
//        [asset setValue:@(PHAssetMediaTypeImage) forKey:@"mediaType"];
//    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
//        asset.videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
//        asset.fullScreenImage = [UIImage thumbImageWithVideoPath:asset.videoURL.path];
//        [asset setValue:@(PHAssetMediaTypeVideo) forKey:@"mediaType"];
//    }
//    
//    return asset;
//}
//
//+ (void) compressVideoWithInputURL:(NSURL *)inputURL outputURL:(NSURL *)outputURL completion:(void (^)(BOOL))completion
//{
//    if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
//        [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
//    }
//    
//    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
//    AVAssetExportSession *session =
//    [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
//    session.outputURL = outputURL;
//    session.outputFileType = AVFileTypeQuickTimeMovie;
//    [session exportAsynchronouslyWithCompletionHandler:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (completion) {
//                completion(session.status == AVAssetExportSessionStatusCompleted);
//            }
//        });
//    }];
//}
//
//- (void) compressVideoWithOutputURL:(NSURL *)outputURL completion:(void (^)(BOOL))completion {
//    [PHAsset compressVideoWithInputURL:self.videoURL outputURL:outputURL completion:completion];
//}
//
//- (void) setFullScreenImage:(UIImage *)fullScreenImage {
//    objc_setAssociatedObject(self, @selector(fullScreenImage), fullScreenImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (void) setOriginalImage:(UIImage *)originalImage {
//    objc_setAssociatedObject(self, @selector(originalImage), originalImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (void) setVideoURL:(NSURL *)videoURL {
//    objc_setAssociatedObject(self, @selector(videoURL), videoURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (UIImage *) fullScreenImage {
//    return objc_getAssociatedObject(self, @selector(fullScreenImage));
//}
//
//- (UIImage *) originalImage {
//    return objc_getAssociatedObject(self, @selector(originalImage));
//}
//
//- (NSURL *) videoURL {
//    return objc_getAssociatedObject(self, @selector(videoURL));
//}
//
//@end
//
//@interface SNImagePickerHelper () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
//QBImagePickerControllerDelegate>
//
//@property (nonatomic, copy) void (^ cameraHandler)(PHAsset *);
//@property (nonatomic, copy) void (^ albumHandler)(NSArray *);
//
//@end
//
//@implementation SNImagePickerHelper
//SNSingletonM(Helper);
//
//- (void) showImagePickerActionSheetWithCameraHandler:(void (^)(PHAsset *))camera albumHandler:(void (^)(NSArray<PHAsset
//    *> *))album                     inViewController:(UIViewController *)vc {
//    @weakify(weakSelf);
//    PSTAlertController *actionSheet = [PSTAlertController actionSheetWithTitle:nil];
//    [actionSheet addAction:[PSTAlertAction actionWithTitle:SN_STR(@"拍照") handler:^(PSTAlertAction *action) {
//        kStrongSelf(strongSelf);
//        [strongSelf showCameraWithCompletion:camera inViewController:vc];
//    }]];
//    [actionSheet addAction:[PSTAlertAction actionWithTitle:SN_STR(@"从相册选择") handler:^(PSTAlertAction *action) {
//        kStrongSelf(strongSelf);
//        [strongSelf showImagePickerWithCompletion:album inViewController:vc];
//    }]];
//    [actionSheet addAction:[PSTAlertAction actionWithTitle:SN_STR(@"取消") style:PSTAlertActionStyleCancel handler:nil]];
//    [actionSheet showWithSender:nil controller:vc animated:YES completion:nil];
//}
//
//- (void) showCameraWithCompletion:(void (^)(PHAsset *))completion inViewController:(UIViewController *)vc {
//    [AVCaptureDevice sn_authCameraWithCompletion:^(AVCaptureAuthorizationType type) {
//        if (type == AVCaptureAuthorizationTypeAuthorized) {
//            self.cameraHandler = completion;
//
//            NSMutableArray *mediaTypes = @[(NSString *)kUTTypeImage].mutableCopy;
//            if (self.videoEnabled) {
//                [mediaTypes addObject:(NSString *)kUTTypeMovie];
//            }
//            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//            imagePicker.mediaTypes = mediaTypes;
//            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//            imagePicker.delegate = self;
//            [vc presentViewController:imagePicker animated:YES completion:nil];
//        } else {
//            @weakify(weakSelf);
//            PSTAlertController *alert = [PSTAlertController alertWithTitle:nil
//                                                                   message:[NSString stringWithFormat:@"允许%@访问你的相机，方便发送图片和拍摄。", [NSBundle appDisplayName]]];
//            [alert addCancelActionWithHandler:nil];
//            [alert addAction:[PSTAlertAction actionWithTitle:SN_STR(@"确定") handler:^(PSTAlertAction *action) {
//                [weakSelf openSettingsAboutThisAppIfCan];
//            }]];
//            [alert showWithSender:nil controller:vc animated:YES completion:nil];
//            kSafeBlock(completion, nil);
//        }
//    }];
//}
//
//- (void) showImagePickerWithCompletion:(void (^)(NSArray<PHAsset *> *))completion inViewController:(UIViewController *)
//    vc {
//    [AVCaptureDevice sn_authAlbumWithCompletion:^(AVCaptureAuthorizationType type) {
//        if (type == AVCaptureAuthorizationTypeAuthorized) {
//            self.albumHandler = completion;
//
//            QBImagePickerController *imagePicker = [QBImagePickerController new];
//            imagePicker.allowsMultipleSelection = self.maximumNumberOfSelection > 1;
//            imagePicker.showsNumberOfSelectedAssets = self.maximumNumberOfSelection > 1;
//            imagePicker.delegate = self;
//            if (self.maximumNumberOfSelection > 1) {
//                // 在用户选择照片的时候的提示语
//                imagePicker.prompt =
//                [NSString stringWithFormat:SN_STR(@"你最多可以选择%ld张照片"), self.maximumNumberOfSelection];
//            }
//            imagePicker.maximumNumberOfSelection = self.maximumNumberOfSelection;
//            [vc presentViewController:imagePicker animated:YES completion:nil];
//        } else {
//            @weakify(weakSelf);
//
//            PSTAlertController *alert = [PSTAlertController alertWithTitle:nil
//                                                                   message:[NSString stringWithFormat:@"允许%@访问你的相册，方便发送图片和拍摄。", [NSBundle appDisplayName]]];
//            [alert addCancelActionWithHandler:nil];
//            [alert addAction:[PSTAlertAction actionWithTitle:SN_STR(@"确定") handler:^(PSTAlertAction *action) {
//                [weakSelf openSettingsAboutThisAppIfCan];
//            }]];
//            [alert showWithSender:nil controller:vc animated:YES completion:nil];
//
//            kSafeBlock(completion, nil);
//        }
//    }];
//}
//
//- (void) qb_imagePickerController:(QBImagePickerController *)imagePickerController
//           didFinishPickingAssets:(NSArray *)assets {
//    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
//
//    kSafeBlock(self.startRequestImagesBlock);
//    
//    NSMutableArray *tempAssets = [NSMutableArray array];
//    for (PHAsset *asset in assets) {
//        [asset requestFullScreenImageWithCompletion:^(UIImage *image, NSError *error) {
//            [tempAssets addObject:asset];
//            if (tempAssets.count == assets.count) {
//                kSafeBlock(self.albumHandler, tempAssets);
//            }
//        }];
//    }
//}
//
//- (void) qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
//    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
//    
//    kSafeBlock(self.albumHandler, nil);
//}
//
//- (void)    imagePickerController:(UIImagePickerController *)picker
//    didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
//    [picker dismissViewControllerAnimated:YES completion:nil];
//
//    kSafeBlock(self.cameraHandler, [PHAsset assetWithMediaInfo:info]);
//}
//
//- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [picker dismissViewControllerAnimated:YES completion:nil];
//
//    kSafeBlock(self.cameraHandler, nil);
//}
//
//- (void) openSettingsAboutThisAppIfCan {
//    NSURL *URL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//
//    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
//        [[UIApplication sharedApplication] openURL:URL];
//    }
//}
//
//@end
