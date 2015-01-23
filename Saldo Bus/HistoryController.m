//
//  HistoryController.m
//  Saldo Bus
//
//  Created by Roman Sarria on 2/17/13.
//  Copyright (c) 2013 Speryans. All rights reserved.
//

#import "HistoryController.h"
#import "DictionaryHelper.h"
#import "PathManager.h"

@interface HistoryController ()

@end

@implementation HistoryController

- (id) initWithDocument: (NSString *)doc andCard: (NSString *) crd {
    self = [super initWithNibName:@"HistoryController" bundle:nil];
    if (self) {
        self->document = doc;
        self->card = crd;
    }
    return self;
}

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
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"Saldo Bus"];
    
    self->aclTextView.layer.masksToBounds = NO;
    self->aclTextView.layer.cornerRadius = 0;
    self->aclTextView.layer.shadowOffset = CGSizeMake(-5, 0);
    self->aclTextView.layer.shadowRadius = 5;
    self->aclTextView.layer.shadowOpacity = 0.5;
    
    data = [[PathManager shared] getData:[[PathManager shared] getFileName:document andCard:card]];
    
    [table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    NSDictionary *value = [data objectAtIndex:indexPath.item];
    
    [cell.textLabel setText:[@"Línea " stringByAppendingString:[value stringForKey:@"line"]]];
    [cell.detailTextLabel setText:[[[@"Saldo actual: $" stringByAppendingString:[value stringForKey:@"balance"]] stringByAppendingString:@"\n"] stringByAppendingString:[value stringForKey:@"date"]]];
    [cell.detailTextLabel setNumberOfLines:2];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.0f;
}

@end
