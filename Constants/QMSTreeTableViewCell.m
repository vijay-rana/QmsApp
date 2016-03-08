//
//  QMSTreeTableViewCell.m
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSTreeTableViewCell.h"
#import "SSGroupedTableViewDatasource.h"

@implementation QMSTreeTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@interface QMSDataFormsTreeTableViewCell (){
    QMSTableViewCellExpansionState expansionState;
}

@end

@implementation QMSDataFormsTreeTableViewCell

-(void) setPdfTemplate:(QMSPDFTemplate *)pdfTemplate{
    _pdfTemplate = pdfTemplate;
    NSArray *array = [SSGroupedTableViewDatasource _rowArrayFromValue:pdfTemplate];
    [[self buttonDeletePDFTemplate] setHidden:([array count] > 0)];
}

-(IBAction) newPDFButtonTapped:(UIButton*) sender{
    [[self delegateQMSDataFormsTreeTableViewCell] dataFormsCellTouchedOnNewPDF:self];
}

-(IBAction) deletePDFTemplateButtonTapped:(UIButton*) sender{
    [[self delegateQMSDataFormsTreeTableViewCell] dataFormsCellTouchedOnDeletePDFTemplate:self];
}

-(IBAction) expandButtonTapped:(UIButton*) sender{
    expansionState = !expansionState;
    [[self delegateQMSDataFormsTreeTableViewCell] dataFormsCell:self expansionStateChangeTo:expansionState];
}

-(void) setExpandImageForButton:(UIButton*) sender
                      withState:(QMSTableViewCellExpansionState) state{
    if (state == kQMSTableViewCellExpansionStateYes) {
        [sender setImage:[UIImage imageNamed:@"Open"] forState:UIControlStateNormal];
    } else{
        [sender setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
    }
}

-(QMSDataFormsTamplateCopyView*) viewDetails{
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"QMSDataFormsTamplateCopyView" owner:self options:nil];
    return nibArray[0];
}

-(void) addpdfCopyViews{
    [self removepdfCopyViews];
    [self setupDetailsViewWithData:_pdfTemplate];
    [self setExpandImageForButton:_expandButton
                        withState:kQMSTableViewCellExpansionStateYes];
}

-(void) removepdfCopyViews{
    [self setExpandImageForButton:_expandButton
                        withState:kQMSTableViewCellExpansionStateNo];
    [[_pdfCopyViewContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

-(void) setupDetailsViewWithData:(id) value{
    __block QMSDataFormsTamplateCopyView *previousDetailView = nil;
    NSArray *array = [SSGroupedTableViewDatasource _rowArrayFromValue:value];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        QMSDataFormsTamplateCopyView* detailView = [self viewDetails];
        [detailView setPdfTemplateCopy:obj];
        [detailView setDelegateQMSDataFormsTamplateCopyView:_delegateQMSDataFormsTreeTableViewCell];
        
        [detailView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_pdfCopyViewContainerView addSubview:detailView];
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(detailView);
        NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[detailView]-1-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewDictionary];
        [_pdfCopyViewContainerView addConstraints:constraint_H];
        
        if( idx == 0 ){
            NSArray *constaintTop_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[detailView]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:viewDictionary];
            [_pdfCopyViewContainerView addConstraints:constaintTop_V];
        }
        else {
            NSDictionary *dictionary = NSDictionaryOfVariableBindings(detailView,previousDetailView);
            NSArray *constaintTop_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousDetailView]-1-[detailView]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:dictionary];
            [_pdfCopyViewContainerView addConstraints:constaintTop_V];
        }
        
        if( idx == ([array count] - 1)) {
            NSArray *constaintBottom_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[detailView]-1-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewDictionary];
            [_pdfCopyViewContainerView addConstraints:constaintBottom_V];
        }
        previousDetailView = detailView;
    }];
    [_pdfCopyViewContainerView setNeedsUpdateConstraints];
}


@end

@interface QMSDataFormsTamplateCopyView ()

@end

@implementation QMSDataFormsTamplateCopyView
-(void) setPdfTemplateCopy:(QMSPDFTemplateCopy *)pdfTemplateCopy{
    _pdfTemplateCopy = pdfTemplateCopy;
    [[self pdfCopyLabel] setText:[SSTableViewDataSource _textFromValue:pdfTemplateCopy]];
}

-(IBAction) deleteButtonTapped:(UIButton*) sender{
    [[self delegateQMSDataFormsTamplateCopyView] pdfTemplateCopyView:self
                                                didTapOnDeleteButton:sender];
}

-(IBAction) editButtonTapped:(UIButton*) sender{
    [[self delegateQMSDataFormsTamplateCopyView] pdfTemplateCopyView:self
                                                didTapOnEditButton:sender];
}

-(IBAction) emailButtonTapped:(UIButton*) sender{
    [[self delegateQMSDataFormsTamplateCopyView] pdfTemplateCopyView:self
                                                didTapOnEmailButton:sender];
}

-(IBAction) pdfViewTapped:(UITapGestureRecognizer*) sender{
    [[self delegateQMSDataFormsTamplateCopyView] pdfTemplateCopyViewdidSelectView:self];
}

-(IBAction) checkButtonTapped:(UIButton*) sender{
    [[self delegateQMSDataFormsTamplateCopyView] pdfTemplateCopyView:self
                                                 didTapOnCheckButton:sender];
}
@end

@implementation QMSUploadDataFormsTreeTableViewCell

-(QMSDataFormsTamplateCopyView*) viewDetails{
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"QMSUploadDataFormsTamplateCopyView" owner:self options:nil];
    return nibArray[0];
}

@end