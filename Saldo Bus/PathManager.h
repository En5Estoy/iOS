//
//  PathManager.h
//  CantoYo
//
//  Created by Roman Sarria on 1/25/13.
//  Copyright (c) 2013 Beat Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathManager : NSObject {
    
}

+ (PathManager *) shared;

- (void) createPathIfNotExists;
- (NSString *) getFileName: (NSString *) _document andCard: (NSString *) _card;
- (NSString *) getDocumentDirectory: (NSString *) filename;

- (BOOL) fileExists: (NSString *) path;
- (NSArray *) listDirectory: (NSString *) path andExtension: (NSString *) extension;
- (NSMutableArray *) getData: (NSString *) path;
- (void) saveData: (NSMutableArray *) data inPath: (NSString *) path;
- (void) removeFile: (NSString *) path;

@end
