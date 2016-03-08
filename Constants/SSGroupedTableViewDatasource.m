//
//  ODGroupedTableViewDatasource.m
//  ServShare
//
//  Created by Mac Book Pro on 09/02/15.
//  Copyright (c) 2015 Dipak Vyawahare. All rights reserved.
//

#import "SSGroupedTableViewDatasource.h"

@interface SSGroupedTableViewDatasource ()
@end

@implementation SSGroupedTableViewDatasource

+(NSArray*) _rowArrayFromValue:(id) value{
    NSArray *rows = nil;
    if([value conformsToProtocol:@protocol(QMSGroupedTableViewDatasourceDisplayObject)] == YES  ){
        rows = [value rowValueArray];
    }
    return rows;
}

-(void) setDataArray:(NSArray *)dataArray{
    [super setDataArray:dataArray];
    __block NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = [SSTableViewDataSource _textFromValue:obj];
        NSArray *rows = [self getRowsFromValue:obj];
        if (key != nil && rows != nil) {
            [dictionary setObject:rows forKey:key];
        }
    }];
    [self setDataObjectsDictionery:dictionary];
}

-(NSArray*) getRowsFromValue:(id) value{
    return [SSGroupedTableViewDatasource _rowArrayFromValue:value];
}

-(void) setDataObjectsDictionery:(NSDictionary *)dataObjectsDictionery{
	_dataObjectsDictionery=dataObjectsDictionery;
	[self setupHeaderArray];
	[[self tableView] reloadData];
}

-(void) setupHeaderArray{
	headerArray=[_dataObjectsDictionery allKeys];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	NSString *key=[headerArray objectAtIndex:section];
	NSInteger count = [[[self dataObjectsDictionery] objectForKey:key] count];
	return count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
	return [[self dataObjectsDictionery] count];
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [headerArray objectAtIndex:section];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([self delegateTableViewDataSource] != nil &&
	   [[self delegateTableViewDataSource] respondsToSelector:@selector(tableViewDataSource:didSelectRowAtIndexPath:)] == YES ){
		[(id<ODGroupedTableViewDatasourceDelegate>)[self delegateTableViewDataSource] tableViewDataSource:self
															   didSelectRowAtIndexPath:indexPath];
	}
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

-(id) getObjectAtIndexPath:(NSIndexPath*) indexPath{
	NSString *key=[headerArray objectAtIndex:[indexPath section]];
	id section = [[self dataObjectsDictionery] objectForKey:key];
	return [section objectAtIndex:[indexPath row]];
}

- (id) valueAtIndexPath:(NSIndexPath *)indexPath {
	return [self getObjectAtIndexPath:indexPath];
}

-(NSIndexPath*) indexPathOfValue:(id) value{
	NSIndexPath *indexPath = nil;
	if( [self dataObjectsDictionery] != nil && [[self dataObjectsDictionery] count] > 0 )	{
		__block NSInteger sectionIndex = -1;
		__block NSInteger rowIndex = -1;
		[headerArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
			NSArray *dataArray = [[self dataObjectsDictionery] objectForKey:key];
			NSInteger itemIndex = [dataArray indexOfObject:value];
			if( itemIndex != NSNotFound ) {
				rowIndex = itemIndex;
				sectionIndex = idx;
				*stop = YES;
			}
		}];
		
		if (sectionIndex != -1 && rowIndex != -1) {
			indexPath = [NSIndexPath indexPathForRow:rowIndex
										   inSection:sectionIndex];
		}
	}
	return indexPath;
}

@end
