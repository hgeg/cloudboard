#import "MenubarController.h"
#import "PanelController.h"

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate, PNDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;

- (IBAction)togglePanel:(id)sender;

@end
