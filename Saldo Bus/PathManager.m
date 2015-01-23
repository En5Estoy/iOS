//
//  PathManager.m
//  CantoYo
//
//  Created by Roman Sarria on 1/25/13.
//  Copyright (c) 2013 Beat Mobile. All rights reserved.
//

#import "PathManager.h"
#import "JSONKit.h"

@implementation PathManager

static PathManager* _sharedCommon = nil;

+ (PathManager *) shared {
    @synchronized([PathManager class])
    {
        if (!_sharedCommon)
            _sharedCommon = [[super allocWithZone:NULL] init];
        
        return _sharedCommon;
    }
    
    return nil;
}

-(id)init {
    if (_sharedCommon!=nil)return self;
    
    if (self=[super init]) {
    }
    
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized([PathManager class]) {
        return [self shared];
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void) createPathIfNotExists {
    NSString *path = [self getDocumentDirectory:@""];
    
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if([fileManager fileExistsAtPath:path] == NO) {
		
		NSError *error = nil;
		
		BOOL success =
		[fileManager createDirectoryAtPath:path
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&error];
        
		if (success == NO) {
			NSLog(@"FileManager.m (createDirectoryIfNotExistsWithName:):\nTrying to create %@\nError: %@",
				  path,
				  error.description);
            
		}
    } else {
        NSLog(@"Content: %@", [[fileManager contentsOfDirectoryAtPath:path error:nil] debugDescription]);
    }
}

- (NSString *) getFileName: (NSString *) _document andCard: (NSString *) _card {
    return [self getDocumentDirectory:[NSString stringWithFormat:@"%@-%@.json", _document, _card]];
}

- (NSString *) getDocumentDirectory: (NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
    
    return path;
}

- (BOOL) fileExists: (NSString *) path {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    return [fileManager fileExistsAtPath:path];
}

- (NSArray *) listDirectory: (NSString *) path andExtension: (NSString *) extension {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSError *err;
    
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&err];
    
    NSLog(@"Files found: %@", [files debugDescription]);
    
    if( err ) {
        NSLog(@"Error: %@", [err debugDescription]);
        
        return nil;
    } else {
        if (extension == nil) {
            return files;
        } else  {
            NSPredicate *fltr = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '.%@'", extension]];
            
            return [files filteredArrayUsingPredicate:fltr];
        }
    }
}

- (NSMutableArray *) getData: (NSString *) path {
    NSError *err;
    
    NSLog(@"Path: %@", path);
    
    NSString *jsonData = [NSString stringWithContentsOfFile:path encoding:NSUTF16StringEncoding error:&err];
    NSLog(@"Error: %@", [err debugDescription]);
    NSLog(@"Data: %@", jsonData);
    
    if( jsonData != nil ) {
        NSMutableArray *jdata = [[NSMutableArray alloc] initWithArray:[jsonData objectFromJSONString]];
        NSLog(@"Data: %@", [jdata debugDescription]);
        return jdata;
    } else {
        NSMutableArray *jdata = [[NSMutableArray alloc] init];
        return jdata;
    }
}

- (void) saveData: (NSMutableArray *) data inPath: (NSString *) path {
    NSError *err;
    
    NSString *sData = [data JSONString];
    BOOL ok = [sData writeToFile:path atomically:YES encoding:NSUnicodeStringEncoding error:&err];
    
    NSLog(@"Error: %@", [err debugDescription]);
    NSLog(@"OK: %i", ok);
}

- (void) removeFile: (NSString *) path {
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    NSError *err;
    BOOL ok = [fileManager removeItemAtPath:path error:&err];
    
    NSLog(@"Error: %@", [err debugDescription]);
    NSLog(@"OK: %i", ok);
}

@end
