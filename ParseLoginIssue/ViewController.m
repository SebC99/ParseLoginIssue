//
//  ViewController.m
//  ParseLoginIssue
//
//  Created by amaury soviche on 09/06/15.
//
//
@import Parse;
#import "ViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "UIAlertView+Blocks.h"

@interface ViewController ()
@property(weak, nonatomic) IBOutlet UIButton *facebookButton;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *facebookActivityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.facebookActivityIndicator.hidden = YES;
}

- (IBAction)loginWithFacebookHandler:(id)sender {
    [self linkUserOrLoginOnFacebook:^(PFUser *user, NSError *error) {
      if (error != nil) {
          // Error with Facebook
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:NSLocalizedString(@"Facebook: error when trying to login", @"Alert message: Facebook: error when trying to login")
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"OK", @"Alert message: OK")
                                                    otherButtonTitles:nil];
          [alertView show];

      } else if (user == nil) {
          // User cancels the login to avoid deletion of current anonymous places

      } else {
          // User is successfully logged in

          [UIAlertView showWithTitle:@"Logged In !"
                             message:@"Now, we logout !"
                   cancelButtonTitle:@"OK"
                   otherButtonTitles:nil
                            tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              [PFUser logOut];
                              // We create a new anonymous user who use the app
                              [[PFUser currentUser] save];
                              [UIAlertView showWithTitle:@"Logged out" message:@"Please login again" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];

                            }];
      }
      if (self) {
          [self.facebookActivityIndicator stopAnimating];
          self.facebookButton.hidden = NO;
          self.view.userInteractionEnabled = YES;
      }
    }];
}

- (void)linkUserOrLoginOnFacebook:(void (^)(PFUser *, NSError *))completion {
    // Set permissions required for the Facebook user account
    NSArray *permissionsArray = @[ @"public_profile" ];

    // If the current account is not anonymous, we login to Facebook
    // The user is currently anonymous, we try to link his account to Facebook
    [PFFacebookUtils linkUserInBackground:[PFUser currentUser]
                      withReadPermissions:permissionsArray
                                    block:^(BOOL succeeded, NSError *error) {
                                      NSLog(@"succeeded: %@ | error: %@", @(succeeded), error);

                                      if (error == nil && succeeded == YES) {
                                          //INFO: account is saved in user prefs
                                          if (completion) completion([PFUser currentUser], nil);

                                      } else {
                                          //INFO: account already linked
                                          if (error.code == kPFErrorFacebookAccountAlreadyLinked) {
                                              // The account is link with another account
                                              // We have to test if the current anonymous account has some places
                                              // If yes, we have to alert the user
                                              // Then we login with this fb user
                                              [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:completion];

                                          } else {
                                              NSLog(@"Facebook login error: %@", error);
                                              if (completion) completion(nil, error);
                                          }
                                      }
                                    }];
}

@end
