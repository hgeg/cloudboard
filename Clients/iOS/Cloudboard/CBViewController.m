//
//  CBViewController.m
//  Cloudboard
//
//  Created by Ali Can Bülbül on 9/23/13.
//  Copyright (c) 2013 Can Bülbül. All rights reserved.
//

#import "CBViewController.h"
#import "PNJSONSerialization.h"
#import "Toast+UIView.h"

#define API_KEY @"H4vlwkm8tvO8"
#define API_SECRET @"UZepT6F8abA80DK1ilCz"
#define uniqueID [NSString stringWithFormat:@"cboard-ios-07219PQ0047-%@",@"QP569"]

@interface CBViewController ()

@end

@implementation CBViewController
@synthesize clipView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self synchronize];
    clipDict = [[NSMutableDictionary alloc] initWithCapacity:5];
    [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-56806acb-9c46-4008-b8cb-899561b7a762" subscribeKey:@"sub-26001c28-a260-11e1-9b23-0916190a0759" secretKey:@"sec-MGNhZWJmZmQtOTZlZS00ZjM3LWE4ZTYtY2Q3OTM0MTNhODRj"]];
    [PubNub connect];
    
    PNChannel *channel_user = [PNChannel channelWithName:@"Hgeg" shouldObservePresence:YES];
    [PubNub subscribeOnChannel:channel_user];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePasteboard:) name:@"CBChangePasteboard" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronize) name:@"invokeSync" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updatePasteboard:(NSNotification *) notification {
    NSDictionary *dict = notification.userInfo[@"message"];
    NSLog(@"%@ - %@ : %d",dict[@"uniqueID"],uniqueID,[dict[@"uniqueID"] isEqualToString:uniqueID]);
    if ([dict[@"uniqueID"] isEqualToString:uniqueID]) return;
    [self synchronize];
}

- (IBAction) push:(id)sender{
    [clipView setText:[UIPasteboard generalPasteboard].string];
    int timestamp = [[NSDate date] timeIntervalSince1970];
    
    NSDictionary *queryDict = @{@"user":@"Hgeg", @"timestamp":[NSNumber numberWithInt:timestamp], @"data":clipView.text, @"key":API_KEY, @"signature":[self md5:[NSString stringWithFormat:@"%d&%@&%@",timestamp,[self md5:@"sokoban"],API_SECRET]], @"uniqueID":uniqueID};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:queryDict options:0 error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://hgeg.io/cloudboard/set/"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        //NSLog(@"%@\n%@",response,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            [[NSUserDefaults standardUserDefaults] setObject:clipText forKey:@"CBlocalClipboard"];
            [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}


- (void) synchronize{
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *post = [NSString stringWithFormat:@"user=Hgeg&timestamp=%d&key=%@&signature=%@",timestamp,API_KEY,
                      [self md5:[NSString stringWithFormat:@"%d&%@&%@",timestamp,[self md5:@"sokoban"],API_SECRET]]
                      ];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://hgeg.io/cloudboard/get/"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                clipText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [self.clipView setText:clipText];
                [[NSUserDefaults standardUserDefaults] setObject:clipText forKey:@"CBlocalClipboard"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.view makeToast:@"Clipboard Updated"];
            });
    }];
}

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

@end
