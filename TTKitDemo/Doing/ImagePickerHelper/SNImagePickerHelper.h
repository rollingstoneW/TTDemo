//
//  SNImagePickerHelper.h
//  Uhouzz
//
//  Created by 韦振宁 on 16/5/17.
//  Copyright © 2016年 Uhouzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^PHAssetRequestImageCompletion)(UIImage *image, NSError *error);
typedef void(^PHAssetRequestVideoURLCompletion)(NSURL *URL, NSError *error);

@interface PHAsset (Query)

@property (nonatomic, strong) UIImage *fullScreenImage;
@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, strong) NSURL *videoURL;

- (void) requestFullScreenImageWithCompletion:(PHAssetRequestImageCompletion)completion;
- (void) requestOriginalImageWithCompletion:(PHAssetRequestImageCompletion)completion;
- (void) requestImageWithSize:(CGSize)size Completion:(PHAssetRequestImageCompletion)completion;

- (void) requestVideoURLWithCompletion:(PHAssetRequestVideoURLCompletion)completion;

+ (void) compressVideoWithInputURL:(NSURL *)inputURL
                         outputURL:(NSURL *)outputURL
                        completion:(void (^)(BOOL succeed))completion;
- (void) compressVideoWithOutputURL:(NSURL *)outputURL completion:(void (^)(BOOL succeed))completion;

@end

@interface SNImagePickerHelper : NSObject

@property (nonatomic, assign) BOOL videoEnabled; // default is NO
@property (nonatomic, assign) NSInteger maximumNumberOfSelection; // default is 1
@property (nonatomic, copy) dispatch_block_t startRequestImagesBlock;

- (void) showImagePickerActionSheetWithCameraHandler:(void (^)(PHAsset *asset))camera
                                        albumHandler:(void (^)(NSArray <PHAsset *> *assets))album
                                    inViewController:(UIViewController *)vc;

- (void) showCameraWithCompletion:(void (^)(PHAsset *asset))completion
                 inViewController:(UIViewController *)vc;

- (void) showImagePickerWithCompletion:(void (^)(NSArray <PHAsset *> *assets))completion
                      inViewController:(UIViewController *)vc;

@end
