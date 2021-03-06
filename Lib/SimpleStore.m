//
//  SimpleStore.m
//  SimpleData
//
//  Created by Brian Collins on 09-10-03.
//  Copyright 2009 Brian Collins. All rights reserved.
//

#import "SimpleStore.h"
#import "NSString.h"
#import "UIApplication.h"

@implementation SimpleStore
@synthesize path;


+ (id)currentStore {
	return [[[NSThread currentThread] threadDictionary] objectForKey:SIMPLE_STORE_KEY];
}

+ (NSString *)storePath:(NSString *)p {
	if (![p hasSubstring:@"/"])
		return [[UIApplication documentsDirectory] stringByAppendingPathComponent:p];
	else 
		return p;
}

+ (id)storeWithPath:(NSString *)p {
	id current = [[SimpleStore alloc] initWithPath:[self storePath:p]];
	[[[NSThread currentThread] threadDictionary] setObject:current forKey:SIMPLE_STORE_KEY];
	return current;
}

+ (void)deleteStoreAtPath:(NSString *)p {	
	[[NSFileManager defaultManager] removeItemAtPath:[self storePath:p] error:nil];
}

- (id)initWithPath:(NSString *)p {
	if (self = [super init]) {
		self.path = p;
	}
	return self;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: self.path];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}

- (BOOL)save {
	return managedObjectContext && [managedObjectContext hasChanges] && [managedObjectContext save:nil];
}

- (BOOL)saveAndClose {
	return [self save] && [self close];
}

- (BOOL)close {
	[[[NSThread currentThread] threadDictionary] removeObjectForKey:SIMPLE_STORE_KEY];
	[self release];
	return YES;
}

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];

	[super dealloc];
}



@end
