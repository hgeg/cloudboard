//
//  CBViewController.h
//  Cloudboard
//
//  Created by Ali Can Bülbül on 9/23/13.
//  Copyright (c) 2013 Can Bülbül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface CBViewController : UIViewController <UITextFieldDelegate>
{
    NSString *clipText;
    NSMutableDictionary *clipDict;
}
@property (weak, nonatomic) IBOutlet UITextView *clipView;

- (void) synchronize;
- (IBAction) push:(id)sender;
- (NSString *) md5:(NSString *) input;

@end
