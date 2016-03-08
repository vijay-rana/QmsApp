//
//  SSGroupedTableViewDatasource.h
//  ServShare
//
//  Created by Mac Book Pro on 09/02/15.
//  Copyright (c) 2015 Dipak Vyawahare. All rights reserved.
//

#import "SSTableViewDatasource.h"

@protocol ODGroupedTableViewDatasourceDelegate <NSObject>

#warning Do not use this method tableViewDataSource:didSelectRowAtIndexPath: use tableViewDataSource:didSelectValue: instead
- (void) tableViewDataSource:(SSTableViewDataSource *)tableViewDataSource
	 didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SSGroupedTableViewDatasource : SSTableViewDataSource{
	NSArray *headerArray;
}
+(NSArray*) _rowArrayFromValue:(id) value;
-(void) setupHeaderArray;

@property (nonatomic,strong) NSDictionary * dataObjectsDictionery;


@end
