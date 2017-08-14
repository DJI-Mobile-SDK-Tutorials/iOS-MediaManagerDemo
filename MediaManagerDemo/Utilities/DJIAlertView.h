//
//  DJIAlertView.h
//  DJISdkDemo
//
//  Created by Ares on 16/4/15.
//  Copyright © 2016年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void (^DJIAlertViewActionBlock)(NSUInteger buttonIndex);
typedef void (^DJIAlertInputViewActionBlock)(NSArray<UITextField*>* _Nullable textFields, NSUInteger buttonIndex);

@interface DJIAlertView : NSObject

+(instancetype _Nullable) showAlertViewWithMessage:(NSString* _Nullable)message titles:(NSArray<NSString*> * _Nullable)titles action:(DJIAlertViewActionBlock _Nullable)actionBlock;

+(instancetype _Nullable) showAlertViewWithMessage:(NSString* _Nullable)message titles:(NSArray<NSString*> * _Nullable)titles textFields:(NSArray<NSString*>* _Nullable)textFields action:(DJIAlertInputViewActionBlock _Nullable)actionBlock;

-(void) dismissAlertView;

-(void) updateMessage:(nullable NSString *)message;

@end
