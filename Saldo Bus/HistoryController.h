//
//  HistoryController.h
//  Saldo Bus
//
//  Created by Roman Sarria on 2/17/13.
//  Copyright (c) 2013 Speryans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface HistoryController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UIView *aclTextView;
    
    IBOutlet UITableView *table;
    
    NSMutableArray *data;
    
    NSString *document;
    NSString *card;
}

- (id) initWithDocument: (NSString *)doc andCard: (NSString *) crd;

@end
