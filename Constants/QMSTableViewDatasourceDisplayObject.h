//
//  QMSTableViewDatasourceDisplayObject.h
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMSTableViewDatasourceDisplayObject <NSObject>

-(NSString*) detailLabelText;

@end

@protocol SSTableViewDatasourceDisplayObjectImage <NSObject>

-(UIImage*) correspondingImage;

@end

@protocol QMSGroupedTableViewDatasourceDisplayObject <QMSTableViewDatasourceDisplayObject>

-(NSArray*) rowValueArray;

@end
