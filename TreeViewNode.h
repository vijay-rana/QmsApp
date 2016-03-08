//
//  TreeViewNode.h
//  The Projects
//
//  Created by Ahmed Karim on 1/12/13.
//  Copyright (c) 2013 Ahmed Karim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeViewNode : NSObject

@property (nonatomic) NSInteger nodeLevel;
@property (nonatomic) BOOL isExpanded;
@property (nonatomic, strong) id nodeObject;
@property (nonatomic, strong) NSMutableArray *nodeChildren;


@property (nonatomic) NSString * nodeTag;

@property (nonatomic) NSString * nodeTempTypeID;
@property (nonatomic, strong) NSNumber* pdfId;

+(TreeViewNode*) treeNodeWithNodeTemplate:(NSString *) nodeTempTypeID
                            fromNodeArray:(NSArray*) array;
@property (nonatomic) BOOL isNodeSelected;
+(BOOL) isPDFExistInArray:(NSNumber *) pdfId
                            fromChildNodeArray:(NSArray*) array;
@end
