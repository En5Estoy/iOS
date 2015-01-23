//
//  MainController.h
//  Saldo Bus
//
//  Created by Roman Sarria on 2/16/13.
//  Copyright (c) 2013 Speryans. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EZForm/EZForm.h>

@interface MainController : UIViewController <EZFormDelegate> {
    IBOutlet UIScrollView *container;
    
    IBOutlet UIView *aclTextView;
    
    IBOutlet UITextField *documentTxt;
    IBOutlet UITextField *cardTxt;
    IBOutlet UITextField *controlTxt;
    
    IBOutlet UIImageView *controlImg;
    
    IBOutlet UIButton *consultBtn;
    IBOutlet UIButton *historyBtn;
    
    NSString *sessionToken;
    
    NSUserDefaults *defaults;
}

- (IBAction)consultAction:(id)sender;
- (IBAction)historyAction:(id)sender;

@end
