//
//  QMSTableViewDataSource.m
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSTableViewDataSource.h"

@interface QMSTableViewDataSource (){
    NSMutableArray *expandedSections;
    NSMutableArray *selectedSections;
}

@end

@implementation QMSTableViewDataSource
-(void) setDelegateQMSTableViewDataSource:(id<QMSTableViewDataSourceDelegate>)delegateQMSTableViewDataSource{
    _delegateQMSTableViewDataSource = delegateQMSTableViewDataSource;
    [super setDelegateTableViewDataSource:delegateQMSTableViewDataSource];
}

-(void) setTableView:(UITableView *)tableView{
    [super setTableView:tableView];
    UINib *nib = [UINib nibWithNibName:[self headerViewIdentifier] bundle:nil];
    [tableView registerNib:nib forHeaderFooterViewReuseIdentifier:[self headerViewIdentifier]];
    selectedSections = [NSMutableArray array];
    expandedSections = [NSMutableArray array];
}

-(NSString*) headerViewIdentifier{
    return @"SSFindServiceSliderTableViewHeader";
}

-(NSString*) cellTypeIdentifierForValue:(id)value{
    return @"QMSTreeTableViewCell";
}

-(void) setDataObjectsDictionery:(NSDictionary *)dataObjectsDictionery{
    [super setDataObjectsDictionery:dataObjectsDictionery];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    if ([expandedSections containsObject:@(section) ] == YES) {
        count = [self actualNumberOfRowsInSection:section];
    }
    return count;
}

-(NSInteger) actualNumberOfRowsInSection:(NSInteger)section{
    NSString *key=[headerArray objectAtIndex:section];
    return [[[self dataObjectsDictionery] objectForKey:key] count];
}

-(void) configureCell:(QMSTreeTableViewCell *)cell
            withValue:(id)value
           isSelected:(BOOL)isValueSelected{
    [super configureCell:cell
               withValue:value
              isSelected:isValueSelected];
    if ([cell isKindOfClass:[QMSTreeTableViewCell class]] == YES) {
        cell.accessoryType=UITableViewCellAccessoryNone;
        if (isValueSelected == YES) {
            //User interaction for this BUTTON is DISABLED
            [[cell selectionButton] setImage:[UIImage imageNamed:@"checkedBox.png"] forState:UIControlStateNormal];

        } else{
            [[cell selectionButton] setImage:[UIImage imageNamed:@"UnCheckedBox.png"] forState:UIControlStateNormal];            
        }
        [[cell downloadedButton] setHidden:([[value valueForKey:@"isDownLoaded"] isEqualToNumber:@(1)] == NO)];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SSFindServiceSliderTableViewHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[self headerViewIdentifier]];
    [[headerView titleLabel] setText:[self tableView:tableView titleForHeaderInSection:section]];
    
//    [headerView setSelected:NO];
    
    NSArray *gestureArray = [headerView gestureRecognizers];
    if ([gestureArray count] == 0) {
        UITapGestureRecognizer * gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTapped:)];
        [headerView addGestureRecognizer:gr];
        
        [[headerView selectionButton] addTarget:self action:@selector(headerSelectionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [headerView setExpanded:[expandedSections containsObject:@(section) ] == YES];
    [headerView setSelected:[selectedSections containsObject:@(section) ] == YES];
    [headerView setRowsCount:[self actualNumberOfRowsInSection:section]];
    
    [headerView setTag:section];
    [[headerView selectionButton] setTag:section];
    return headerView;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    id selectedValue = [self valueAtIndexPath:indexPath];
    if ([[self selectedValues] containsObject:selectedValue] == NO) {
        //So deleselect header also
        if ([selectedSections containsObject:@(indexPath.section) ] == YES)
            [selectedSections removeObject:@(indexPath.section)];
    }
}

-(IBAction)headerViewTapped:(UITapGestureRecognizer*) sender{
    SSFindServiceSliderTableViewHeader *headerView = (SSFindServiceSliderTableViewHeader*)sender.view;
    NSInteger section = [headerView tag];
    if ([expandedSections containsObject:@(section) ] == YES) {
        [expandedSections removeObject:@(section)];
    } else{
        [expandedSections addObject:@(section)];
        id headerValue = [self getValueForSection:section];
        [self callHeaderWithValue:headerValue];
    }
    [[self tableView] reloadData];
}

-(IBAction)headerSelectionButtonTapped:(UIButton*) sender{
    NSInteger section = [sender tag];
    [self selectHeaderWithSection:section];
}

-(void) selectHeaderWithSection:(NSInteger) section{
    id headerValue = [self getValueForSection:section];
    
    NSMutableArray *selectionArray = [[self objTableViewSelectionHelper] selectedValues];
    NSArray *newValueToSelect = [SSGroupedTableViewDatasource _rowArrayFromValue:headerValue];
    [selectionArray removeObjectsInArray:newValueToSelect];
    if ([selectedSections containsObject:@(section) ] == YES) {
        [selectedSections removeObject:@(section)];
    } else{
        [selectedSections addObject:@(section)];
        [selectionArray addObjectsFromArray:newValueToSelect];
    }
    
    [[self tableView] reloadData];
    
}

-(id) getValueForSection:(NSInteger) section{
    NSString *header = [self tableView:[self tableView] titleForHeaderInSection:section];
    __block id headerValue = nil;
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = [SSTableViewDataSource _textFromValue:obj];
        NSArray *rows = [SSGroupedTableViewDatasource _rowArrayFromValue:obj];
        if (key != nil && rows != nil && [key isEqualToString:header] == YES) {
            NSInteger sectionForObject = [self sectionForArray:rows];
            if (section == sectionForObject) {
                headerValue = obj;
                *stop = true;
            } else{
                 headerValue = obj;
            }
        }
    }];

    return headerValue;
}

-(NSInteger) sectionForArray:(NSArray*) array{
    __block NSInteger section = NSNotFound;
    if( [self dataObjectsDictionery] != nil && [[self dataObjectsDictionery] count] > 0 )	{
        [headerArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            NSArray *dataArray = [[self dataObjectsDictionery] objectForKey:key];
            if([dataArray count] > 0 && [dataArray isEqualToArray:array] == YES ) {
                section = idx;
                *stop = YES;
            }
        }];
    }
    return section;
}

-(void) callHeaderWithValue:(id) value{
    if(self.delegateQMSTableViewDataSource != nil &&
       [self.delegateQMSTableViewDataSource respondsToSelector:@selector(tableViewDataSource:didSelectHeaderValue:)] == YES ){
        [self.delegateQMSTableViewDataSource tableViewDataSource:self didSelectHeaderValue:value];
    }
}

@end

@interface SSFindServiceSliderTableViewHeader (){
}

@end

@implementation SSFindServiceSliderTableViewHeader

-(void) setSelected:(BOOL) selected_local{
    if (selected_local == YES) {
        [[self selectionButton] setImage:[UIImage imageNamed:@"checkedBox.png"] forState:UIControlStateNormal];
    } else{
        [[self selectionButton] setImage:[UIImage imageNamed:@"UnCheckedBox.png"] forState:UIControlStateNormal];
    }

    _selected = selected_local;
}

-(void) setExpanded:(BOOL)expanded_local{
    if (expanded_local == YES) {
        [_expandImageView setImage:[UIImage imageNamed:@"Open"]];
    } else{
        [_expandImageView setImage:[UIImage imageNamed:@"Close"]];
    }
    _expanded = expanded_local;
}

-(void) setRowsCount:(NSInteger) count{
    NSString *countString = @"";
    if (count != 0) {
        countString = [NSString stringWithFormat:@"%lu",count];
    }
    [[self rowsCountLabel] setText:countString];
}
@end