//
//  AppDelegate.m
//  QMS
//
//  Created by shweta kadu on 2/25/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "DownloadFormTemplateVC.h"
#import "DataFormVC.h"
#import "QMSNetworkManager.h"
#import "MainMenuViewController.h"

@implementation AppDelegate

@synthesize viewController = _viewController;

+ (AppDelegate *)sharedAppDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    UIViewController *vc = [self nextVC];
   
    navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [[self window] setRootViewController:navigationController];
//    [self.window addSubview:navigationController.view];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

     [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,shadow, NSShadowAttributeName,[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0], NSFontAttributeName, nil]];

    
  return YES;

}

-(UIViewController*) nextVC{
    UIViewController *vc = nil;
    if ([self isFormsAvailable] == YES) {
        vc = [[DataFormVC alloc]initWithNibName:@"DataFormVC" bundle:nil];
    }
    else{
        BOOL isLoggedIn = [[QMSCoreDataReusableMethod retrieveFromUserDefaults:@"isLoggedIn"] boolValue];
        if (isLoggedIn == YES) {
            vc = [[MainMenuViewController alloc]initWithNibName:@"MainMenuViewController" bundle:nil];
        }
        else{
            vc = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        }
    }
    
    return vc;
}

-(BOOL) isFormsAvailable{
    NSFetchRequest *fetchRequest = [QMSPDFTemplate fetchRequestForKey:@"isDownLoaded" havingValue:@(1)];
    NSInteger count = [QMSCoreDataReusableMethod countForFetchRequest:fetchRequest];
    return count > 0;
}

-(void) backgroundLoginCheck{
    QMSNetworkManager *nwmgr = [QMSNetworkManager sharedManager];
    QMSUser *currentUser = [QMSUser currentUser];
    [nwmgr getUserLoginFromService:[currentUser valueForKey:@"userName"] :[currentUser valueForKey:@"password"]];
    
}

-(BOOL) validateUser{
    BOOL isLoggedIn = [[QMSCoreDataReusableMethod retrieveFromUserDefaults:@"isLoggedIn"] boolValue];
    if (isLoggedIn == NO) {
        UIViewController *vc = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        [[[navigationController viewControllers] lastObject] presentViewController:vc animated:YES completion:^{
            UIAlertView *alertViewForDeleteForms = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please Relogin to continue" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertViewForDeleteForms show];
        }];
//        navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
       
//        [[self window] setRootViewController:navigationController];
    }
    return isLoggedIn;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    BOOL isLoggedIn = [[QMSCoreDataReusableMethod retrieveFromUserDefaults:@"isLoggedIn"] boolValue];
    if (isLoggedIn == YES) {
        [self backgroundLoginCheck];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.dipakvyawahare.ServShare" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"QMSDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"QMS.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
