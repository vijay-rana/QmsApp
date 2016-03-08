//
//  QMSDataFormsTableViewDataSource.m
//  QMS
//
//  Created by Mac Book Pro on 21/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSDataFormsTableViewDataSource.h"
#define	ESTIMATED_TABLE_VIEW_ROW_HEIGHT				43.0f

@interface QMSDataFormsTableViewDataSource ()<QMSDataFormsTreeTableViewCellDelegate>{
    NSMutableArray *expandedCells;
}

@end

@implementation QMSDataFormsTableViewDataSource

-(void) setDelegateQMSTableViewDataSource:(id<QMSDataFormsTableViewDataSourceDelegate>)delegateQMSTableViewDataSource{
    [super setDelegateQMSTableViewDataSource:delegateQMSTableViewDataSource];
}

-(void) setTableView:(UITableView *)tableView{
    [super setTableView:tableView];
    expandedCells = [NSMutableArray array];
}

-(NSArray*) getRowsFromValue:(QMSTemplate*) value{
    NSMutableArray *pdfTemplatesArray = [[QMSPDFTemplate getPersistentObjectsForKey:@"isDownLoaded" havingValue:@(1)] mutableCopy];
    NSPredicate *prediateForCurrentTempalte = [NSPredicate predicateWithBlock:^BOOL(QMSPDFTemplate* evaluatedObject, NSDictionary *bindings) {
        BOOL isEqual = NO;
        if ([[evaluatedObject valueForKey:@"templateTypeId"] isEqualToNumber:[value valueForKey:@"templateTypeId"]] == YES) {
            isEqual = YES;
        }
        return isEqual;
    }];
    return [pdfTemplatesArray filteredArrayUsingPredicate:prediateForCurrentTempalte];;
}

-(void) configureCell:(QMSDataFormsTreeTableViewCell *)cell
            withValue:(QMSPDFTemplate*)value
           isSelected:(BOOL)isValueSelected{
    [super configureCell:cell
               withValue:value
              isSelected:isValueSelected];
    if ([cell isKindOfClass:[QMSDataFormsTreeTableViewCell class]] == YES) {
        [cell setDelegateQMSDataFormsTreeTableViewCell:self];
        [cell setPdfTemplate:value];
        NSIndexPath *indexPath = [self indexPathOfValue:value];
        if ([expandedCells containsObject:indexPath] == YES) {
            [cell addpdfCopyViews];
        } else{
            [cell removepdfCopyViews];
        }
        
    }
    
}

-(NSString*) headerViewIdentifier{
    return @"QMSDataFormsTableViewHeader";
}

-(NSString*) cellTypeIdentifierForValue:(id)value{
    return @"QMSDataFormsTreeTableViewCell";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = ESTIMATED_TABLE_VIEW_ROW_HEIGHT;
    if ([expandedCells containsObject:indexPath] == YES) {
        id value = [self valueAtIndexPath:indexPath];
        BOOL isSelected = [[self objTableViewSelectionHelper] isValueSelected:value];
        height = [self heightForCellOfTableView:tableView
                             withValue:value
                            isSelected:isSelected];
    }
    return height;
}

- (CGFloat) heightForCellOfTableView:(UITableView *)tableView
                           withValue:(id)value
                          isSelected:(BOOL)isSelected{
    float cellHeight = ESTIMATED_TABLE_VIEW_ROW_HEIGHT;
    static NSMutableDictionary *cellsLoadded = nil;
    if( cellsLoadded == nil ){
        cellsLoadded = [NSMutableDictionary dictionary];
    }
    
    //	id value = [self valueAtIndexPath:indexPath];
    NSString *identifier = [self cellTypeIdentifierForValue:value];
    QMSDataFormsTreeTableViewCell *heightCell = [cellsLoadded objectForKey:identifier];
    if (heightCell == nil) {
        heightCell = (QMSDataFormsTreeTableViewCell*)[self  newCellForValue:value];
        [cellsLoadded setObject:heightCell forKey:identifier];
    }
    //	BOOL isSelected = [[self objODTableViewSelectionHelper] isValueSelected:value];
    [self  configureCell:heightCell
               withValue:value
              isSelected:isSelected];
    
    [heightCell setNeedsUpdateConstraints];
    [heightCell updateConstraintsIfNeeded];
    
    [heightCell setBounds:CGRectMake(0.0f,
                                     0.0f,
                                     CGRectGetWidth(tableView.bounds),
                                     CGRectGetHeight(heightCell.bounds))];
    
    [heightCell setNeedsLayout];
    [heightCell layoutIfNeeded];
    
    cellHeight = [[heightCell contentView] systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    cellHeight = MAX(cellHeight, ESTIMATED_TABLE_VIEW_ROW_HEIGHT);
    
    return cellHeight;
}

-(void) dataFormsCellTouchedOnNewPDF:(QMSDataFormsTreeTableViewCell*) cell{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    id value = [self valueAtIndexPath:indexPath];
    if(self.delegateQMSTableViewDataSource != nil &&
       [self.delegateQMSTableViewDataSource respondsToSelector:@selector(tableViewDataSource:didTouchedOnNewPDFForValue:)] == YES ){
        [self.delegateQMSTableViewDataSource tableViewDataSource:self didTouchedOnNewPDFForValue:value];
    }
}

-(void) dataFormsCell:(QMSDataFormsTreeTableViewCell*) cell expansionStateChangeTo:(QMSTableViewCellExpansionState) currentState{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    if ([expandedCells containsObject:indexPath] == YES) {
        [expandedCells removeObject:indexPath];
    } else{
        [expandedCells addObject:indexPath];
    }
    [[self tableView] reloadData];
}

-(void) dataFormsCellTouchedOnDeletePDFTemplate:(QMSDataFormsTreeTableViewCell*) cell{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    id value = [self valueAtIndexPath:indexPath];
    if(self.delegateQMSTableViewDataSource != nil &&
       [self.delegateQMSTableViewDataSource respondsToSelector:@selector(tableViewDataSource:didTouchedOnDeletePDFTemplate:)] == YES ){
        [self.delegateQMSTableViewDataSource tableViewDataSource:self didTouchedOnDeletePDFTemplate:value];
    }
}

#pragma mark -- QMSDataFormsTamplateCopyView delegate
-(void) pdfTemplateCopyView:(QMSDataFormsTamplateCopyView*) view
       didTapOnDeleteButton:(UIButton*) button{
    id value = [view pdfTemplateCopy];
    if(self.delegateQMSTableViewDataSource != nil &&
       [self.delegateQMSTableViewDataSource respondsToSelector:@selector(tableViewDataSource:didDeletePDFForValue:)] == YES ){
        [self.delegateQMSTableViewDataSource tableViewDataSource:self
                                            didDeletePDFForValue:value];
    }
}

-(void) pdfTemplateCopyView:(QMSDataFormsTamplateCopyView*) view
         didTapOnEditButton:(UIButton*) button{
    id value = [view pdfTemplateCopy];
    if(self.delegateQMSTableViewDataSource != nil &&
       [self.delegateQMSTableViewDataSource respondsToSelector:@selector(tableViewDataSource:didEditPDFForValue:)] == YES ){
        [self.delegateQMSTableViewDataSource tableViewDataSource:self
                                            didEditPDFForValue:value];
    }
}

-(void) pdfTemplateCopyView:(QMSDataFormsTamplateCopyView*) view
        didTapOnEmailButton:(UIButton*) button{
    id value = [view pdfTemplateCopy];
    if(self.delegateQMSTableViewDataSource != nil &&
       [self.delegateQMSTableViewDataSource respondsToSelector:@selector(tableViewDataSource:didEmailPDFForValue:)] == YES ){
        [self.delegateQMSTableViewDataSource tableViewDataSource:self
                                            didEmailPDFForValue:value];
    }
}

-(void) pdfTemplateCopyViewdidSelectView:(QMSDataFormsTamplateCopyView*) view{
    id value = [view pdfTemplateCopy];
    if(self.delegateQMSTableViewDataSource != nil &&
       [self.delegateQMSTableViewDataSource respondsToSelector:@selector(tableViewDataSource:didSelectPDFForValue:)] == YES ){
        [self.delegateQMSTableViewDataSource tableViewDataSource:self
                                             didSelectPDFForValue:value];
    }
}

-(void) pdfTemplateCopyView:(QMSDataFormsTamplateCopyView*) view
        didTapOnCheckButton:(UIButton*) button{
    if (checkedPDFForms == nil) {
        checkedPDFForms = [NSMutableArray array];
    }
    id value = [view pdfTemplateCopy];
    if ([checkedPDFForms containsObject:value] == YES) {
        [checkedPDFForms removeObject:value];
        [button setImage:[UIImage imageNamed:@"UnCheckedBox.png"] forState:UIControlStateNormal];
    } else{
        [checkedPDFForms addObject:value];
        [button setImage:[UIImage imageNamed:@"checkedBox.png"] forState:UIControlStateNormal];
    }
}

@end

@implementation QMSUploadDataFormsTableViewDataSource

-(NSArray*) getRowsFromValue:(QMSTemplate*) value{
    NSMutableArray *pdfTemplatesArray = [[QMSPDFTemplate getPersistentObjectsForKey:@"isDownLoaded" havingValue:@(1)] mutableCopy];
    NSPredicate *prediateForCurrentTempalte = [NSPredicate predicateWithBlock:^BOOL(QMSPDFTemplate* evaluatedObject, NSDictionary *bindings) {
        BOOL isEqual = NO;
        if ([[evaluatedObject valueForKey:@"templateTypeId"] isEqualToNumber:[value valueForKey:@"templateTypeId"]] == YES) {
            if ([[evaluatedObject getAllPdfTemplateCopy] count] > 0) {
                isEqual = YES;
            }
        }
        return isEqual;
    }];
    return [pdfTemplatesArray filteredArrayUsingPredicate:prediateForCurrentTempalte];;
}

-(NSString*) cellTypeIdentifierForValue:(id)value{
    return @"QMSUploadDataFormsTreeTableViewCell";
}

-(NSArray*) checkedPDFForms{
    return checkedPDFForms;
}
@end
