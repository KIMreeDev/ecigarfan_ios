//
//  QRCodeReaderViewController.h
//  ECExpert
//
//  Created by renchunyu on 15/1/22.
//  Copyright (c) 2015年 renchunyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QRCodeReaderDelegate.h"

/**
 * The `QRCodeReaderViewController` is a simple QRCode Reader/Scanner based on
 * the `AVFoundation` framework from Apple. It aims to replace ZXing or ZBar
 * for iOS 7 and over.
 */
@interface QRCodeReaderViewController : UIViewController

#pragma mark - Managing the Delegate
/** @name Managing the Delegate */

/**
 * @abstract The object that acts as the delegate of the receiving QRCode
 * reader.
 */
@property (nonatomic, weak) id<QRCodeReaderDelegate> delegate;

#pragma mark - Creating and Inializing QRCode Readers
/** @name Creating and Inializing QRCode Readers */

/**
 * @abstract Initializes a view controller to read QRCodes from a displayed
 * video preview and a cancel button to be go back.
 * @param cancelTitle The title of the cancel button.
 */
- (id)initWithCancelButtonTitle:(NSString *)cancelTitle;

/**
 * @abstract Creates a view controller to read QRCodes from a displayed
 * video preview and a cancel button to be go back.
 * @param cancelTitle The title of the cancel button.
 * @see initWithCancelButtonTitle:
 */
+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle;

#pragma mark - Checking the Metadata Items Types
/** @name Checking the Metadata Items Types */

/**
 * @abstract Returns whether you can scan a QRCode with the current device.
 * @return a Boolean value indicating whether you can scan a QRCode with the current device.
 */
+ (BOOL)isAvailable;

#pragma mark - Managing the Block
/** @name Managing the Block */

/**
 * @abstract Sets the completion with a block that executes when a QRCode or when the user did
 * stopped the scan.
 * @param completionBlock The block to be executed. This block has no return value and takes
 * one argument: the `resultAsString`. If the user stop the scan and that there is no response
 * the `resultAsString` argument is nil.
 */
- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock;

@end