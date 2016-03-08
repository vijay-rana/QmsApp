//
//  QMSTemplate.m
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSTemplate.h"


@implementation QMSTemplate

@dynamic templateTypeId;
@dynamic templateTypeName;
@dynamic templateOwner;

-(void) setDataObjectDictionary:(NSDictionary*) dict{
    if (dict != nil && [dict count] > 0) {
        [self setTemplateTypeId:[dict valueForKey:@"TemplateTypeId"]];
        [self setTemplateTypeName:[dict valueForKey:@"TemplateTypeName"]];
    }
}

+(instancetype) getPersistentObject:(QMSTemplate*) templateObject{
    QMSTemplate *persiObject = [QMSTemplate getPersistentObjectForKey:@"templateTypeId" havingValue:[templateObject valueForKey:@"templateTypeId"]];
    return persiObject;
}

-(NSArray*) getAllPdfTemplate{
    return [QMSPDFTemplate getPersistentObjectsForKey:@"templateTypeId" havingValue:[self valueForKey:@"templateTypeId"]];
}

@end

@implementation QMSTemplate (QMSGroupedTableViewDatasourceDisplayObject)

-(NSString*) detailLabelText{
    return [self valueForKey:@"templateTypeName"];
}

-(NSArray*) rowValueArray{
    return [self getAllPdfTemplate];
}

@end