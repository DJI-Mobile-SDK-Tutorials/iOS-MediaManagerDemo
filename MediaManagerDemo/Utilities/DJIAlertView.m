//
//  DJIAlertView.m
//  DJISdkDemo
//
//  Created by Ares on 16/4/15.
//  Copyright © 2016年 DJI. All rights reserved.
//

#import "DJIAlertView.h"

#define NavControllerObject(navController) UINavigationController* navController = (UINavigationController*)[[UIApplication sharedApplication] keyWindow].rootViewController;

@interface DJIAlertView()

@property(nonatomic, strong)UIAlertController* alertController;

@end


@implementation DJIAlertView

+(instancetype _Nullable) showAlertViewWithMessage:(NSString* _Nullable)message titles:(NSArray<NSString*> * _Nullable)titles action:(DJIAlertViewActionBlock _Nullable)actionBlock
{
    DJIAlertView* alertView = [[DJIAlertView alloc] init];
    
    alertView.alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    for (NSUInteger index = 0; index < titles.count; ++index) {
        UIAlertActionStyle actionStyle = (index == 0) ? UIAlertActionStyleCancel : UIAlertActionStyleDefault;
        UIAlertAction* alertAction = [UIAlertAction actionWithTitle:titles[index] style:actionStyle handler:^(UIAlertAction * _Nonnull action) {
            if (actionBlock) {
                actionBlock(index);
            }
        }];
        [alertView.alertController addAction:alertAction];
    }
    
    NavControllerObject(navController);
    [navController presentViewController:alertView.alertController animated:YES completion:nil];
    return alertView;
}

+(instancetype _Nullable) showAlertViewWithMessage:(NSString* _Nullable)message titles:(NSArray<NSString*> * _Nullable)titles textFields:(NSArray<NSString*>* _Nullable)textFields action:(DJIAlertInputViewActionBlock _Nullable)actionBlock
{
    DJIAlertView* alertView = [[DJIAlertView alloc] init];
    
    alertView.alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    for (NSUInteger index = 0; index < textFields.count; ++index) {
        [alertView.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = textFields[index];
        }];
    }
    
    NSArray* fieldViews = alertView.alertController.textFields;
    for (NSUInteger index = 0; index < titles.count; ++index) {
        UIAlertActionStyle actionStyle = (index == 0) ? UIAlertActionStyleCancel : UIAlertActionStyleDefault;
        UIAlertAction* alertAction = [UIAlertAction actionWithTitle:titles[index] style:actionStyle handler:^(UIAlertAction * _Nonnull action) {
            if (actionBlock) {
                actionBlock(fieldViews, index);
            }
        }];
        
        [alertView.alertController addAction:alertAction];
    }
    
    NavControllerObject(navController);
    [navController presentViewController:alertView.alertController animated:YES completion:nil];
    return alertView;
}

-(void) updateMessage:(nullable NSString *)message
{
    self.alertController.message = message;
}

-(void) dismissAlertView
{
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
}

@end
