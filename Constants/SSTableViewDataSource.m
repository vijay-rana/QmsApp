//
//  SSTableViewDataSource.m
//  ServShare
//
//  Created by Mac Book Pro on 09/02/15.
//  Copyright (c) 2015 Dipak Vyawahare. All rights reserved.
//

#import "SSTableViewDataSource.h"
#import "SSTableViewCell.h"

@interface SSTableViewDataSource(){
    NSString *identifier;
}
@end
@implementation SSTableViewDataSource

+(NSString*) _textFromValue:(id) value{
    NSString *text = @"";
    if ([value isKindOfClass:[NSString class]] == YES) {
        text = value;
    } else if([value conformsToProtocol:@protocol(QMSTableViewDatasourceDisplayObject)] == YES  ){
        text = [value detailLabelText];
    }
    return text;
}

+(UIImage*) _imageFromValue:(id) value{
    UIImage *image = nil;
    if([value conformsToProtocol:@protocol(SSTableViewDatasourceDisplayObjectImage)] == YES  ){
        image = [value correspondingImage];
    }
    return image;
}

- (SSTableViewDatasourceSelectionHelper *)objODTableViewSelectionHelper{
    if( _objTableViewSelectionHelper == nil ){
        _objTableViewSelectionHelper = [[SSTableViewDatasourceSelectionHelper alloc] initWithSelectionType:kSSTableViewDataSourceSelectionTypeSingle];
    }
    return _objTableViewSelectionHelper;
}

- (void) clearAllSelections {
    [[self objODTableViewSelectionHelper] clearAllSelections];
    [[self tableView] reloadData];
}

- (SSTableViewDataSourceSelectionType) tableViewSelectionType {
    return [[self objODTableViewSelectionHelper] selectionType];
}

- (void) setTableViewSelectionType:(SSTableViewDataSourceSelectionType)selectionType {
    [[self objODTableViewSelectionHelper] setSelectionType:selectionType];
}

- (void) reloadTableAndWithPreserveSelection{
//    NSIndexPath *indexPath = [self indexPathOfValue:value];
    NSArray *previousSelectedValue = [self selectedValues];
    [self selectValues:previousSelectedValue];
}

-(void) registerTableCell:(NSString *)nibName withIdenitifer:(NSString *)_identifier{
    if (nibName != nil) {
        UINib *nib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
        [[self tableView] registerNib:nib forCellReuseIdentifier:_identifier];
    }
    identifier = _identifier;
}

-(void) setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [[self tableView] reloadData];
//    [self clearAllSelections];
}

-(void) setDataArrayWithNoPreservSelection:(NSArray *)dataArray{
    _dataArray = dataArray;
    [[self tableView] reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id value = [self valueAtIndexPath:indexPath];
    SSTableViewCell *cell = (SSTableViewCell *)[self loadCellForValue:value];
    BOOL isSelected = [[self objODTableViewSelectionHelper] isValueSelected:value];
    [self configureCell:cell
                                          withValue:value
                                         isSelected:isSelected];
    return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[tableView backgroundColor]];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self selectObjectAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (NSString *) cellTypeIdentifierForValue:(id)value{
    if (identifier == nil) {
        return @"SSTableViewCell";
    }
    return identifier;
}

- (SSTableViewCell *) newCellForValue:(id)value {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[self cellTypeIdentifierForValue:nil]
                                                   owner:self
                                                 options:nil];
    SSTableViewCell *cell = views[0];
    [[cell lblTitle] setNumberOfLines:0];
    
    return cell;
}

- (void) configureCell:(SSTableViewCell *)cell
             withValue:(id)value
            isSelected:(BOOL)isValueSelected{
    if( isValueSelected == NO) {
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    else {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    
    if( [cell isKindOfClass:[SSTableViewCell class]] ){
        NSString *text = [SSTableViewDataSource _textFromValue:value];
        [[(SSTableViewCell *)cell lblTitle] setText:text];
    }
    if( [cell isKindOfClass:[SSTableViewCellWithImage class]] ){
        UIImage *image = [SSTableViewDataSource _imageFromValue:value];
        [[(SSTableViewCellWithImage *)cell corrospondingImageView] setImage:image];
    }
}

-(void) selectObjectAtIndexPath:(NSIndexPath *)indexPath {
    id selectedValue = [self valueAtIndexPath:indexPath];
    NSArray *deselectedValues = [[self objODTableViewSelectionHelper] selectValue:selectedValue];
    NSArray *selectedValues = [[self objODTableViewSelectionHelper] selectedValues];
    if(self.tableViewSelectionType == kSSTableViewDataSourceSelectionTypeNone &&
       self.delegateTableViewDataSource != nil ){
        selectedValues = @[selectedValue];
    }
    [[self tableView] reloadData];
    
    [selectedValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(self.delegateTableViewDataSource != nil &&
           [self.delegateTableViewDataSource respondsToSelector:@selector(tableViewDataSource:didSelectValue:)] == YES ){
            [self.delegateTableViewDataSource tableViewDataSource:self
                                didSelectValue:obj];
        }
    }];
    
    [deselectedValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if( self.delegateTableViewDataSource != nil &&
           [self.delegateTableViewDataSource respondsToSelector:@selector(tableViewDataSource:didDeSelectValue:)] == YES ){
            [self.delegateTableViewDataSource tableViewDataSource:self didDeSelectValue:obj];
        }
    }];
}

#pragma mark - Public
- (NSArray *) selectedValues {
    return [[self objODTableViewSelectionHelper] selectedValues];
}

- (NSInteger) selectValues:(NSArray *)valuesToSelect {
    __block NSInteger objectsSelected = 0;
    
    NSMutableArray *previousSelectedValues = [[self objODTableViewSelectionHelper] selectedValues];
    [self clearAllSelections];
    NSMutableSet *allValuesToSelect = [NSMutableSet set];
    [allValuesToSelect addObjectsFromArray:previousSelectedValues];
    [allValuesToSelect addObjectsFromArray:valuesToSelect];
    
    NSMutableArray *indexPathsToReload = [NSMutableArray array];
    [allValuesToSelect enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        NSIndexPath *indexPath = [self indexPathOfValue:obj];
        if( indexPath != nil ){
            objectsSelected += 1;
            [[self objODTableViewSelectionHelper] selectValue:obj];
            [indexPathsToReload addObject:indexPath];
        }
    }];
    
    if( [indexPathsToReload count] > 0 ){
        [[self tableView] reloadRowsAtIndexPaths:indexPathsToReload
                                  withRowAnimation:UITableViewRowAnimationNone];
    }
    
    return objectsSelected;
}

#pragma mark - Abstract Interface
- (id) valueAtIndexPath:(NSIndexPath *)indexPath {
    id value = [[self dataArray] objectAtIndex:[indexPath row]];
    return value;
}

-(NSIndexPath*) indexPathOfValue:(id) value{
    NSIndexPath *indexPath = nil;
    if( [self dataArray] != nil && [[self dataArray] count] > 0 ){
        NSInteger sectionIndex = 0;
        NSInteger rowIndex = [[self dataArray] indexOfObject:value];
        if (sectionIndex != -1 && rowIndex != -1) {
            indexPath = [NSIndexPath indexPathForRow:rowIndex
                                           inSection:sectionIndex];
        }
    }
    return indexPath;
}

- (SSTableViewCell *) loadCellForValue:(id)value {
    NSString *cellIdentifier = [self cellTypeIdentifierForValue:value];
    SSTableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (SSTableViewCell *)[self newCellForValue:value];
    }
    return cell;
}

@end




#pragma mark - ODTableViewDatasourceSelectionHelper
@implementation SSTableViewDatasourceSelectionHelper

@synthesize selectionType;

- (instancetype) initWithSelectionType:(SSTableViewDataSourceSelectionType)type {
    self = [super init];
    if( self != nil ){
        selectionType = type;
    }
    return self;
}


- (void) setSelectionType:(SSTableViewDataSourceSelectionType)inSelectionType {
    selectionType = inSelectionType;
    [self clearAllSelections];
}


- (NSMutableArray *) selectedValues {
    if( _selectedValues == nil ){
        _selectedValues = [[NSMutableArray alloc] init];
    }
    return _selectedValues;
}

- (BOOL) isValueSelected:(id)value {
    return [[self selectedValues] containsObject:value];
}

- (NSArray *) selectValue:(id)value {
    NSMutableArray *deselectedValues = [NSMutableArray array];
    if( self.selectionType != kSSTableViewDataSourceSelectionTypeNone ){
        if( [[self selectedValues] containsObject:value] == YES ){
            [deselectedValues addObject:value];
            [[self selectedValues] removeObject:value];
        }
        else {
            if( self.selectionType == kSSTableViewDataSourceSelectionTypeMultiple ){
                [[self selectedValues] addObject:value];
            }
            else if ( self.selectionType == kSSTableViewDataSourceSelectionTypeSingle ){
                [deselectedValues addObjectsFromArray:[self selectedValues]];
                [[self selectedValues] removeAllObjects];
                [[self selectedValues] addObject:value];
            }
        }
    }
    return deselectedValues;
}

- (void) clearAllSelections {
    [[self selectedValues] removeAllObjects];
}

@end
