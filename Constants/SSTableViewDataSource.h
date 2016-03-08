//
//  SSTableViewDataSource.h
//  ServShare
//
//  Created by Mac Book Pro on 09/02/15.
//  Copyright (c) 2015 Dipak Vyawahare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTableViewCell.h"

typedef NS_ENUM(NSUInteger, SSTableViewDataSourceSelectionType) {
    kSSTableViewDataSourceSelectionTypeNone,
    kSSTableViewDataSourceSelectionTypeSingle,
    kSSTableViewDataSourceSelectionTypeMultiple
};

#pragma mark - ODTableViewDatasourceSelectionHelper
@interface SSTableViewDatasourceSelectionHelper : NSObject {
    SSTableViewDataSourceSelectionType selectionType;
}
@property (nonatomic, strong) NSMutableArray *selectedValues;
@property (nonatomic) SSTableViewDataSourceSelectionType selectionType;

- (instancetype) initWithSelectionType:(SSTableViewDataSourceSelectionType)type;

- (BOOL) isValueSelected:(id)value;
- (NSArray *) selectValue:(id)value;
- (void) clearAllSelections;

@end

@class SSTableViewDataSource;

@protocol SSTableViewDataSourceDelegate <NSObject>

@optional
-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
             didSelectValue:(id) value;
-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
             didDeSelectValue:(id) value;
@end

@interface SSTableViewDataSource :  NSObject<UITableViewDataSource,UITableViewDelegate>
+(NSString*) _textFromValue:(id) value;
+(UIImage*) _imageFromValue:(id) value;

@property (nonatomic) IBOutlet id<SSTableViewDataSourceDelegate> delegateTableViewDataSource;
@property (nonatomic, strong) SSTableViewDatasourceSelectionHelper *objTableViewSelectionHelper;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray * dataArray;
-(void) setDataArrayWithNoPreservSelection:(NSArray *)dataArray;

- (NSArray *) selectedValues;
- (NSInteger) selectValues:(NSArray *)selectValues;
- (void) setTableViewSelectionType:(SSTableViewDataSourceSelectionType)selectionType;
- (void) reloadTableAndWithPreserveSelection;

-(void) registerTableCell:(NSString*) nibName withIdenitifer:(NSString*) identifier;

- (SSTableViewCell *) newCellForValue:(id)value;
- (NSString *) cellTypeIdentifierForValue:(id)value;
- (void) configureCell:(SSTableViewCell *)cell
             withValue:(id)value isSelected:(BOOL)isValueSelected;

@end

#pragma mark - Abstract Interface
@interface SSTableViewDataSource(Abstract)

- (id) valueAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath*) indexPathOfValue:(id) value;
- (SSTableViewCell *) loadCellForValue:(id)value;
@end
