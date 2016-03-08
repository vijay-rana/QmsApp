//
//  TreeViewNode.m
//  The Projects
//
//  Created by Ahmed Karim on 1/12/13.
//  Copyright (c) 2013 Ahmed Karim. All rights reserved.
//

#import "TreeViewNode.h"

@implementation TreeViewNode
@synthesize nodeLevel;

-(BOOL) isEqual:(id)object{
    BOOL isEqual = NO;
    if ( [object isKindOfClass:[self class]] == YES) {
        if ([self.nodeTag isEqual:[object nodeTag]] == YES) {
            if (_nodeTempTypeID == [object nodeTempTypeID] == YES) {
                 isEqual = YES;
            }
        }
    }
    return isEqual;
}

+(TreeViewNode*) treeNodeWithNodeTemplate:(NSString *) nodeTempTypeID
                            fromNodeArray:(NSArray*) array{
   NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TreeViewNode* evaluatedObject, NSDictionary *bindings) {
       BOOL isEqual = NO;
       if (nodeTempTypeID == [evaluatedObject nodeTempTypeID] == YES) {
           isEqual = YES;
       }
       return isEqual;
   }];
    TreeViewNode *node = [[array filteredArrayUsingPredicate:predicate] lastObject];
    return node;
}

+(BOOL) isPDFExistInArray:(NSNumber *) pdfId
       fromChildNodeArray:(NSArray*) array{
    __block BOOL isExist = NO;
    [array enumerateObjectsUsingBlock:^(TreeViewNode* obj, NSUInteger idx, BOOL *stop) {
        if ([[obj pdfId] isEqualToNumber:pdfId] == YES) {
            isExist = YES;
        }
    }];
    return isExist;
}

@end
