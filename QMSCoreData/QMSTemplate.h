//
//  QMSTemplate.h
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//


#import "QMSResource.h"
#import "QMSUser.h"

@interface QMSTemplate : QMSResource

@property (nonatomic, retain) NSNumber * templateTypeId;
@property (nonatomic, retain) NSString * templateTypeName;
@property (nonatomic, retain) QMSUser * templateOwner;

-(void) setDataObjectDictionary:(NSDictionary*) dict;
-(NSArray*) getAllPdfTemplate;
@end


@interface QMSTemplate (QMSGroupedTableViewDatasourceDisplayObject) <QMSGroupedTableViewDatasourceDisplayObject>

@end