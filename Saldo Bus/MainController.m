//
//  MainController.m
//  Saldo Bus
//
//  Created by Roman Sarria on 2/16/13.
//  Copyright (c) 2013 Speryans. All rights reserved.
//

#import "MainController.h"

#import <QuartzCore/QuartzCore.h>
#import "AFJSONRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"
#import "DictionaryHelper.h"
#import "AFHTTPClient.h"
#import "PathManager.h"
#import "HistoryController.h"

@interface MainController ()
@property (nonatomic, strong) EZForm *myForm;
@end

@implementation MainController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeForm];
    
    [[PathManager shared] createPathIfNotExists];
    
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"Saldo Bus"];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    self->aclTextView.layer.masksToBounds = NO;
    self->aclTextView.layer.cornerRadius = 0;
    self->aclTextView.layer.shadowOffset = CGSizeMake(-5, 0);
    self->aclTextView.layer.shadowRadius = 5;
    self->aclTextView.layer.shadowOpacity = 0.5;
    
    self->controlImg.layer.masksToBounds = YES;
    self->controlImg.layer.cornerRadius = 5;
    
    [self calculateContentSize];
    
    [[self.myForm formFieldForKey:@"document"] useTextField:self->documentTxt];
    [[self.myForm formFieldForKey:@"card"] useTextField:self->cardTxt];
    [[self.myForm formFieldForKey:@"control"] useTextField:self->controlTxt];
    
    [self.myForm autoScrollViewForKeyboardInput:container];
    
    // Last data
    if( [defaults valueForKey:@"lastDNI"] != nil ) {
        documentTxt.text = [defaults stringForKey:@"lastDNI"];
    }
    
    if( [defaults valueForKey:@"lastCARD"] != nil ) {
        cardTxt.text = [defaults stringForKey:@"lastCARD"];
    }
    
    if( [cardTxt.text isEqualToString:@""] && [documentTxt.text isEqualToString:@""] ) {
        [self updateViewsForFormValidity];
    }
    
    [self reloadCaptcha];
}

- (void) reloadCaptcha {
    [SVProgressHUD showWithStatus:@"Cargando control..."];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://54.243.218.97:3000/wrapget"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Stream: %@", JSON);
        
        NSDictionary *jsonData = [JSON copy];
        sessionToken = [jsonData stringForKey:@"cookie"];
        
        [self->controlImg setImageWithURL:[NSURL URLWithString:[@"http://54.243.218.97:3000/wrapimg/" stringByAppendingString:sessionToken]]];
        
        [SVProgressHUD dismiss];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [SVProgressHUD showErrorWithStatus:[error description]];
        NSLog(@"Error: %@", [error debugDescription]);
    }];
    
    [operation start];
}

- (void) calculateContentSize {
    CGFloat y = 0;
    for (UIView *subview in container.subviews) {
        CGRect tempFrame = subview.frame;
        
        CGFloat tempy = tempFrame.origin.y;
        
        if( tempy > y ) {
            y = (tempFrame.size.height + tempFrame.origin.y);
        }
    }
    
    NSLog(@"Height: %f", y);
    [container setContentSize:CGSizeMake(container.frame.size.width, y)];
}

- (void) viewDidUnload {
    [super viewDidUnload];
    
    [self.myForm unwireUserViews];
}

- (void)initializeForm
{
    /*
     * Create EZForm instance to manage the form.
     */
    _myForm = [[EZForm alloc] init];
    _myForm.inputAccessoryType = EZFormInputAccessoryTypeStandard;
    _myForm.delegate = self;
    
    EZFormTextField *documentField = [[EZFormTextField alloc] initWithKey:@"document"];
    [_myForm addFormField:documentField];
    
    EZFormTextField *cardField = [[EZFormTextField alloc] initWithKey:@"card"];
    [_myForm addFormField:cardField];
    
    EZFormTextField *controlField = [[EZFormTextField alloc] initWithKey:@"control"];
    controlField.validationMinCharacters = 0;
    controlField.inputMaxCharacters = 50;
    [_myForm addFormField:controlField];

}

#pragma mark - Login button status

- (void)updateViewsForFormValidity
{
    if ([self.myForm isFormValid]) {
        self->consultBtn.enabled = YES;
        self->consultBtn.alpha = 1.0f;
        
        self->historyBtn.enabled = YES;
        self->historyBtn.alpha = 1.0f;
    }
    else {
        self->consultBtn.enabled = NO;
        self->consultBtn.alpha = 0.4f;
        
        self->historyBtn.enabled = NO;
        self->historyBtn.alpha = 0.4f;
    }
}


#pragma mark - EZFormDelegate methods

- (void)form:(EZForm *)form didUpdateValueForField:(EZFormField *)formField modelIsValid:(BOOL)isValid
{
#pragma unused(form, formField, isValid)
    
    [self updateViewsForFormValidity];
}

- (void)formInputFinishedOnLastField:(EZForm *)form
{
    if ([self.myForm isFormValid]) {
        [self consultAction:nil];
    }
}

- (IBAction)consultAction:(id)sender {
    if ([self.myForm isFormValid]) {
        [SVProgressHUD showWithStatus:@"Obteniendo..."];
        
        // Save last
        [defaults setValue:documentTxt.text forKey:@"lastDNI"];
        [defaults setValue:cardTxt.text forKey:@"lastCARD"];
        [defaults synchronize];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://54.243.218.97:3000/wrappost"]];
    
        NSMutableURLRequest *req = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:[NSDictionary dictionaryWithObjectsAndKeys:documentTxt.text, @"dni", cardTxt.text, @"card", controlTxt.text, @"captcha", sessionToken, @"cookie", nil] constructingBodyWithBlock:nil];
    
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse * response, id JSON) {
            NSLog(@"Stream: %@", JSON);
        
            NSDictionary *jsonData = [JSON copy];
            [SVProgressHUD dismiss];
            
            if( [jsonData boolForKey:@"result"] ) {
                NSDictionary *data = [jsonData objectForKey:@"data"];
                
                if ( ![[data stringForKey:@"balance"] isEqualToString:@""] ) {
                    NSMutableArray *dataArray = [[PathManager shared] getData:[[PathManager shared] getFileName:documentTxt.text andCard:cardTxt.text]];
                    
                    [dataArray addObject:data];
                    
                    [[PathManager shared] saveData:dataArray inPath:[[PathManager shared] getFileName:documentTxt.text andCard:cardTxt.text]];
                    
                    HistoryController *controller = [[HistoryController alloc] initWithDocument:documentTxt.text andCard:cardTxt.text];
                    [self.navigationController pushViewController:controller animated:YES];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saldo Bus" message:@"No hemos conseguido obtener su saldo, esto puede suceder por las siguientes causas: no ha ingresado correctamente los datos, su tarjeta no esta registrada o bien en este momento Red-Bus no esta funcionando correctamente." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil, nil];
                    [alert show];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saldo Bus" message:@"No hemos conseguido obtener su saldo, esto puede suceder por las siguientes causas: no ha ingresado correctamente los datos, su tarjeta no esta registrada o bien en este momento Red-Bus no esta funcionando correctamente." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil, nil];
                [alert show];
            }

            [self reloadCaptcha];
        } failure: ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            [SVProgressHUD showErrorWithStatus:@"Se produjo un error en la consulta. Intente de nuevo más tarde."];
            NSLog(@"Error: %@", [error debugDescription]);
        }];
    
        [operation start];
    }
}

- (IBAction)historyAction:(id)sender {
    if( ![documentTxt.text isEqualToString:@""] && ![cardTxt.text isEqualToString:@""] ) {
        HistoryController *controller = [[HistoryController alloc] initWithDocument:documentTxt.text andCard:cardTxt.text];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saldo Bus" message:@"Debe completar su documento y número de tarjeta para ver el historial de consultas." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
