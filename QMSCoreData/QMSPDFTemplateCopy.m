//
//  QMSPDFTemplateCopy.m
//  QMS
//
//  Created by Mac Book Pro on 07/05/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSPDFTemplateCopy.h"


@implementation QMSPDFTemplateCopy

@dynamic pdfTemplateDescription;
@dynamic creationDateTime;
@dynamic pdfTemplateId;
@dynamic pdfFileEditingDone;

-(NSString*) pdfTemplateCompleteDesc{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSString *dateTimeString = [dateFormatter stringFromDate:[self valueForKey:@"creationDateTime"]];
    return [NSString stringWithFormat:@"%@ %@", dateTimeString ,[self valueForKey:@"pdfTemplateDescription"]];
}

-(NSString*) fileName{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd_HHmm"];
    NSString *dateTimeString = [dateFormatter stringFromDate:[self valueForKey:@"creationDateTime"]];
    return [NSString stringWithFormat:@"%@ %@.pdf", dateTimeString ,[self valueForKey:@"pdfTemplateDescription"]];
}

@end

@implementation QMSPDFTemplateCopy (QMSTableViewDatasourceDisplayObject)

-(NSString*) detailLabelText{
    return [self pdfTemplateCompleteDesc];
}

@end