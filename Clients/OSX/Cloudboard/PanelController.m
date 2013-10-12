#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"

#define OPEN_DURATION .1
#define CLOSE_DURATION .1

#define SEARCH_INSET 10

#define POPUP_HEIGHT 180
#define PANEL_WIDTH 280
#define MENU_ANIMATION_DURATION .1

#define API_KEY @"H4vlwkm8tvO8"
#define API_SECRET @"UZepT6F8abA80DK1ilCz"
#define uniqueID [NSString stringWithFormat:@"cboard-osx-4001K7Q9715-%@",@"KT09F"]

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize textField = _textField;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startObserver:) name:@"CBStartObserver" object:nil];
    }
    return self;
}

- (void) startObserver {
    [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-56806acb-9c46-4008-b8cb-899561b7a762" subscribeKey:@"sub-26001c28-a260-11e1-9b23-0916190a0759" secretKey:@"sec-MGNhZWJmZmQtOTZlZS00ZjM3LWE4ZTYtY2Q3OTM0MTNhODRj"]];
    [PubNub connect];
    
    PNChannel *channel_user = [PNChannel channelWithName:@"Hgeg" shouldObservePresence:YES];
    [PubNub subscribeOnChannel:channel_user];
    
    [self performSelectorInBackground:@selector(pollClipboard) withObject:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePasteboard:) name:@"CBChangePasteboard" object:nil];
}

- (void)dealloc{}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    // Resize panel
    NSRect panelRect = [[self window] frame];
    panelRect.size.height = POPUP_HEIGHT;
    [[self window] setFrame:panelRect display:NO];
    
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
    
    NSRect textRect = [self.textField frame];
    textRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
    textRect.origin.x = SEARCH_INSET;
    textRect.size.height = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET * 3 - 30;
    textRect.origin.y = SEARCH_INSET + 40;
    
    if (NSIsEmptyRect(textRect))
    {
        [self.textField setHidden:YES];
    }
    else
    {
        [self.textField setFrame:textRect];
        [self.textField setHidden:NO];
    }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];

    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}


- (void) pollClipboard {
    clipText = @"";
    [self synchronize];
    while (true) {
        if (![clipText isEqualToString:[[NSPasteboard generalPasteboard] stringForType:NSStringPboardType]]) {
            NSLog(@"new data");
            [self push:nil];
        }
        sleep(1);
    }
}

- (void) updatePasteboard:(NSNotification *) notification {
    NSLog(@"Invoked UpdatePasteBoard:");
    NSDictionary *dict = notification.userInfo[@"message"];
    NSLog(@"%@ - %@ : %d",dict[@"uniqueID"],uniqueID,[dict[@"uniqueID"] isEqualToString:uniqueID]);
    if ([dict[@"uniqueID"] isEqualToString:uniqueID]) return;
    [self synchronize];
}

- (IBAction) push:(id)sender{
    clipText = [[NSPasteboard generalPasteboard] stringForType:NSStringPboardType];
    [self.textField setStringValue:clipText];
    int timestamp = [[NSDate date] timeIntervalSince1970];
    
    NSDictionary *queryDict = @{@"user":@"Hgeg", @"timestamp":[NSNumber numberWithInt:timestamp], @"data":clipText, @"key":API_KEY, @"signature":[self md5:[NSString stringWithFormat:@"%d&%@&%@",timestamp,[self md5:@"sokoban"],API_SECRET]], @"uniqueID":uniqueID};
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
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://hgeg.io/cloudboard/get/"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            clipText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self.textField setStringValue:clipText];
            [[NSUserDefaults standardUserDefaults] setObject:clipText forKey:@"CBlocalClipboard"];
            [[NSUserDefaults standardUserDefaults] synchronize];
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
