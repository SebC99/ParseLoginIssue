//
//  MAPParametersAccountLoginViewController.m
//  mapstr
//
//  Created by Sebastien on 30/03/2015.
//  Copyright (c) 2015 Hulab. All rights reserved.
//

#import "MAPParametersAccountLoginViewController.h"
#import "MAPUsersManager.h"

#import "MAPTextField.h"
#import "MAPRoundBorderedImageView.h"
#import "UIAlertView+Blocks.h"

@interface MAPParametersAccountLoginViewController ()


@property (weak, nonatomic) IBOutlet UILabel                    *introductionTextLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *facebookWarningLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *FBorEmailLabel;

@property (weak, nonatomic) IBOutlet UIButton                  *facebookButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *facebookActivityIndicator;

@property (weak, nonatomic) IBOutlet UIView                    *profilePictureContainerView;
@property (weak, nonatomic) IBOutlet MAPRoundBorderedImageView *accountPhoto;

@property (weak, nonatomic) IBOutlet MAPTextField              *firstNameTextField;
@property (weak, nonatomic) IBOutlet MAPTextField              *lastNameTextField;
@property (weak, nonatomic) IBOutlet MAPTextField              *emailTextField;
@property (weak, nonatomic) IBOutlet MAPTextField              *passwordTextField;
@property (weak, nonatomic) IBOutlet MAPTextField              *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton                  *emailLoginButton;
@property (weak, nonatomic) IBOutlet UIButton                  *emailSignupButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *loginActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView   *signupActivityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintAboveEmail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintBelowPassword;


@property (strong, nonatomic) UITapGestureRecognizer           *tapGestureRecognizer;
@property (nonatomic) BOOL                                      shouldUploadImage;


@end

@implementation MAPParametersAccountLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Log in / Sign up", @"Log in / Sign up");

    self.shouldUploadImage = NO;

    self.firstNameTextField.placeholder = NSLocalizedString(@"First name", @"First name");
    self.lastNameTextField.placeholder = NSLocalizedString(@"Last name", @"Last name");
    self.emailTextField.placeholder = NSLocalizedString(@"Email", @"Email");
    self.passwordTextField.placeholder = NSLocalizedString(@"Password (6 letters min.)", @"Password (6 letters min.)");
    self.confirmPasswordTextField.placeholder = NSLocalizedString(@"Confirm password", @"Confirm password");
    
    self.view.userInteractionEnabled = YES;
    
    // We should confirm the hidden states of the elements
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Signup form animation
- (void)showSignupForm:(BOOL)show {
    CGFloat duration = 0.4f;
    
    CGFloat actualPositionAboveEmail = self.constraintAboveEmail.constant;
    CGFloat actualPositionBelowPassword = self.constraintBelowPassword.constant;
    
    CGFloat maxPositionAboveEmail = self.emailTextField.frame.origin.y;
    CGFloat maxPositionBelowPassword = self.view.frame.size.height - self.passwordTextField.frame.origin.y + self.passwordTextField.frame.size.height;

    if (show) {
        [self showFBLoginOption:show withDuration:duration];
    
        self.constraintAboveEmail.constant = maxPositionAboveEmail;
        self.constraintBelowPassword.constant = maxPositionBelowPassword;
        [self.view layoutIfNeeded];
        
        [self showEmailLoginOption:show];
        
        self.constraintAboveEmail.constant = actualPositionAboveEmail;
        self.constraintBelowPassword.constant = actualPositionBelowPassword;
        
        [UIView animateWithDuration:0.4f delay:duration usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:0 animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
        
        self.passwordTextField.returnKeyType = UIReturnKeyNext;
        
    } else {
        [self.view layoutIfNeeded];
        self.constraintAboveEmail.constant = maxPositionAboveEmail;
        self.constraintBelowPassword.constant = maxPositionBelowPassword;

        [UIView animateWithDuration:0.4f delay:duration usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:0 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self showEmailLoginOption:show];
            self.constraintAboveEmail.constant = actualPositionAboveEmail;
            self.constraintBelowPassword.constant = actualPositionBelowPassword;
            [self.view layoutIfNeeded];
            
            [self showFBLoginOption:show withDuration:duration];
        }];
        
        self.passwordTextField.returnKeyType = UIReturnKeyGo;
    }
    
}

- (void)showFBLoginOption:(BOOL)show withDuration:(CGFloat)duration {
    [UIView transitionWithView:self.facebookButton duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    [UIView transitionWithView:self.facebookWarningLabel duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    [UIView transitionWithView:self.FBorEmailLabel duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    [UIView transitionWithView:self.introductionTextLabel duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    [UIView transitionWithView:self.emailLoginButton duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];

    [self.facebookButton setHidden:show];
    [self.facebookWarningLabel setHidden:show];
    [self.introductionTextLabel setHidden:show];
    [self.FBorEmailLabel setHidden:show];
    [self.emailLoginButton setHidden:show];
}

- (void)showEmailLoginOption:(BOOL)show {
    [self.profilePictureContainerView setHidden:!show];
    [self.firstNameTextField setHidden:!show];
    [self.lastNameTextField setHidden:!show];
    [self.confirmPasswordTextField setHidden:!show];
    [self.emailSignupButton setHidden:!show];
}


#pragma mark - Facebook Login
- (IBAction)loginWithFacebookHandler:(id)sender {
    self.facebookButton.hidden = YES;
    [self.facebookActivityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    
    [MAPUsersManager loginOnFacebook:^(PFUser *user, NSError *error) {
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
            // We update the map (could we do it in background?)
            [[MAPMapManager sharedManager] setCurrentlyDisplayedMapWithUser:user withCompletion:nil];
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];

        }
        if (self) {
            [self.facebookActivityIndicator stopAnimating];
            self.facebookButton.hidden = NO;
            self.view.userInteractionEnabled = YES;
        }
    }];
}



#pragma mark - Email Login
- (IBAction)loginWithEmailHandler:(id)sender {
    [self.view endEditing:YES];

    if (![self isLoginFormValid]) return;
    
    self.emailLoginButton.hidden = YES;
    [self.loginActivityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    
    [MAPUsersManager loginWithEmail:self.emailTextField.text password:self.passwordTextField.text completion:^(PFUser *user, NSError *error) {
        if (self && error !=nil) {
            [MAPUsersManager isUserExistingWithEmail:self.emailTextField.text block:^(BOOL exist, NSError *error) {
                if (self && error == nil && exist) {
                    [self.passwordTextField shake];
                    self.passwordTextField.text = @"";
                    self.passwordTextField.customBorderColor = [UIColor redColor];
                    self.passwordTextField.placeholder = NSLocalizedString(@"Invalid password", @"Invalid password");
                    self.passwordTextField.customPlaceholderColor = [UIColor redColor];
                    self.emailLoginButton.hidden = NO;
                } else {
                    // We have to show the signup form
                    [self showSignupForm:YES];
                }
            }];
        } else if (self && user) {
            // User is successfully logged in
            // We update the map (could we do it in background?)
            [[MAPMapManager sharedManager] setCurrentlyDisplayedMapWithUser:user withCompletion:nil];
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [self.loginActivityIndicator stopAnimating];
        self.emailLoginButton.hidden = NO;
        self.view.userInteractionEnabled = YES;
    }];
}


- (IBAction)signupWithEmailHandler:(id)sender {
    [self.view endEditing:YES];
    
    if (![self isSignupFormValid]) return;
    
    self.emailSignupButton.hidden = YES;
    [self.signupActivityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    
    // We first test if user already exists with this email
    [MAPUsersManager isUserExistingWithEmail:self.emailTextField.text block:^(BOOL exist, NSError *error) {
        if (self && error == nil && exist) {
            // Email already exists
            [self.emailSignupButton setHidden:NO];
            [self.signupActivityIndicator stopAnimating];
            self.view.userInteractionEnabled = YES;
            
            [UIAlertView showWithTitle:NSLocalizedString(@"Existing email", @"Existing email")
                               message:NSLocalizedString(@"Email address already used, please provide another email or login", @"Alert message: Could not signup, email already taken")
                     cancelButtonTitle:NSLocalizedString(@"OK", @"Alert message: OK")
                     otherButtonTitles:@[NSLocalizedString(@"Login", @"Alert message: Login")]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex != alertView.cancelButtonIndex) {
                                      [self showSignupForm:NO];
                                  }
                              }];

        } else if (self) {
            [MAPUsersManager signupWithEmail:self.emailTextField.text
                                    password:self.passwordTextField.text
                                     profile:@{@"firstName": self.firstNameTextField.text, @"lastName": self.lastNameTextField.text}
                                  completion:^(PFUser *user, NSError *error) {
                                      if (self && error == nil && user != nil) {
                                          [[MAPMapManager sharedManager] removeAnonymousMaps]; // Not useful if we save only not anonymous?
                                          if (self.shouldUploadImage == YES) [self uploadImageToParseInBackground:self.accountPhoto.image forUser:user];

                                          // We update the map (could we do it in background?)
                                          [[MAPMapManager sharedManager] setCurrentlyDisplayedMapWithUser:user withCompletion:nil];
                                          [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                          
                                      } else if (self) {
                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                              message:NSLocalizedString(@"We were not able to connect to sign up. Please try again later...", @"Alert message: Could not signup")
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:NSLocalizedString(@"OK", @"Alert message: OK")
                                                                                    otherButtonTitles:nil];
                                          [alertView show];
                                      }
                                      
                                      self.view.userInteractionEnabled = YES;
                                      self.emailSignupButton.hidden = NO;
                                      [self.signupActivityIndicator stopAnimating];
                                  }];
        }
    }];
    
}



#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (![self.passwordTextField.placeholder isEqualToString:NSLocalizedString(@"Password (6 letters min.)", @"Password (6 letters min.)")]) {
        self.passwordTextField.placeholder = NSLocalizedString(@"Password (6 letters min.)", @"Password (6 letters min.)");
        self.passwordTextField.customPlaceholderColor = nil;
        self.passwordTextField.customBorderColor = nil;
    }
    textField.selected = YES;
    
    if (self.tapGestureRecognizer == nil) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        [self.view addGestureRecognizer:self.tapGestureRecognizer];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.selected = NO;
    
    if (self.tapGestureRecognizer) {
        [self.view removeGestureRecognizer:self.tapGestureRecognizer];
        self.tapGestureRecognizer = nil;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else if (textField == self.lastNameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        if (!self.confirmPasswordTextField.hidden) {
            [self.confirmPasswordTextField becomeFirstResponder];
        } else {
            [textField resignFirstResponder];
            [self loginWithEmailHandler:self];
        }
    } else {
        [textField resignFirstResponder];
        [self signupWithEmailHandler:self];
    }
    
    return YES;
}

- (void)tapHandler:(UIGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}


#pragma mark - Form validating
- (BOOL)isLoginFormValid {
    BOOL email      = [self isEmailTextFieldValidated];
    BOOL password   = [self isPasswordTextFieldValidated];
    
    return email && password;
}

- (BOOL)isSignupFormValid {
    BOOL firstname          = [self isFirstNameTextFieldValidated];
    BOOL lastname           = [self isLastNameTextFieldValidated];
    BOOL email              = [self isEmailTextFieldValidated];
    BOOL password           = [self isPasswordTextFieldValidated];
    BOOL confirmpassword    = [self isConfirmPasswordTextFieldValidated];
    
    return (firstname && lastname && email && password && confirmpassword);
}


- (BOOL)isFirstNameTextFieldValidated {
    return [self.firstNameTextField updateValidity:([self.firstNameTextField.text length] > 0)];
}

- (BOOL)isLastNameTextFieldValidated {
    return [self.lastNameTextField updateValidity:([self.lastNameTextField.text length] > 0)];
}

- (BOOL)isEmailTextFieldValidated {
    return [self.emailTextField updateValidity:(self.emailTextField.text.length > 0 && [self isEmailValidated:self.emailTextField.text])];
}

- (BOOL)isPasswordTextFieldValidated {
    return [self.passwordTextField updateValidity:(self.passwordTextField.text.length >= 6)];
}

- (BOOL)isConfirmPasswordTextFieldValidated {
    return [self.confirmPasswordTextField updateValidity:[self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]];
}

- (BOOL)isEmailValidated:(NSString *)email {
    NSString *emailRegEx =
    @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
    @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];

    return [emailTest evaluateWithObject:email];
}

//- (BOOL)textField:(MAPTextField *)textField updateValidity:(BOOL)isValid {
//    if (isValid) {
//        if (textField.state != UIControlStateSelected) {
//            textField.customBorderColor = kMAPApplicationColors_BrownColor;
//        }
//        textField.selected = textField.selected;
//    } else {
//        textField.customBorderColor = [UIColor redColor];
//        [textField shake];
//    }
//    return isValid;
//}



#pragma mark - profile image
- (IBAction)changeProfileImage:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Select an image from the Library", @"Select an image from the Library")];
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Take a photo", @"Take a photo")];
    }
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [self presentImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 2:
            [self presentImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        default:
            break;
    }
}

- (void)presentImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];

    //TODO: do an animation here
    self.accountPhoto.image = image;

    self.shouldUploadImage = YES;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Image uploading
- (void)uploadImageToParseInBackground:(UIImage *)image forUser:(PFUser *)user {
    
    // create the PFFile objects
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8f);
    if (imageData.length == 0) return;
    
    PFFile *imageFile = [PFFile fileWithData:imageData];
    
    __block UIBackgroundTaskIdentifier fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:fileUploadBackgroundTaskId];
    }];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[UIApplication sharedApplication] endBackgroundTask:fileUploadBackgroundTaskId];
        if (error || !succeeded) {
            MAPLog(@"error: %@", error);
        }
    }];
    
    user[@"profilePicture"] = imageFile;
    
    __block UIBackgroundTaskIdentifier imageUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:imageUploadBackgroundTaskId];
    }];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[UIApplication sharedApplication] endBackgroundTask:imageUploadBackgroundTaskId];
    }];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
