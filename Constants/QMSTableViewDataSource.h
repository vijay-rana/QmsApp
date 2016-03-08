//
//  QMSTableViewDataSource.h
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSGroupedTableViewDatasource.h"
#import "QMSTreeTableViewCell.h"

@protocol QMSTableViewDataSourceDelegate <SSTableViewDataSourceDelegate>

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
             didSelectHeaderValue:(id) value;
@end

@interface QMSTableViewDataSource : SSGroupedTableViewDatasource
@property (nonatomic) IBOutlet id<QMSTableViewDataSourceDelegate> delegateQMSTableViewDataSource;
@end

@interface SSFindServiceSliderTableViewHeader : UITableViewHeaderFooterView

@property(nonatomic,weak) IBOutlet UILabel *titleLabel;
@property(nonatomic,weak) IBOutlet UILabel *rowsCountLabel;
@property(nonatomic,weak) IBOutlet UIButton *selectionButton;
@property(nonatomic,weak) IBOutlet UIImageView *expandImageView;
@property (nonatomic,setter=setSelected:) BOOL selected;
@property (nonatomic,setter=setExpanded:) BOOL expanded;
-(void) setRowsCount:(NSInteger) count;
@end