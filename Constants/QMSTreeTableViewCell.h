//
//  QMSTreeTableViewCell.h
//  QMS
//
//  Created by Mac Book Pro on 19/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "SSTableViewCell.h"

typedef NS_ENUM(NSUInteger, QMSTableViewCellExpansionState){
    kQMSTableViewCellExpansionStateNo = 0,
    kQMSTableViewCellExpansionStateYes = 1
};

@interface QMSTreeTableViewCell : SSTableViewCell
@property(nonatomic,weak) IBOutlet UIButton *selectionButton;
@property(nonatomic,weak) IBOutlet UIButton *downloadedButton;
@end


@class QMSDataFormsTreeTableViewCell;
@protocol QMSDataFormsTreeTableViewCellDelegate <NSObject>

-(void) dataFormsCellTouchedOnNewPDF:(QMSDataFormsTreeTableViewCell*) cell;
-(void) dataFormsCellTouchedOnDeletePDFTemplate:(QMSDataFormsTreeTableViewCell*) cell;
-(void) dataFormsCell:(QMSDataFormsTreeTableViewCell*) cell expansionStateChangeTo:(QMSTableViewCellExpansionState) currentState;
@end

@interface QMSDataFormsTreeTableViewCell : QMSTreeTableViewCell
@property(nonatomic,weak) IBOutlet UIButton * buttonNewPDF;
@property(nonatomic,weak) IBOutlet UIButton * buttonDeletePDFTemplate;
@property(nonatomic,strong) IBOutlet UIView * pdfCopyViewContainerView;
@property(nonatomic,weak) IBOutlet UIButton * expandButton;

@property (nonatomic) IBOutlet id<QMSDataFormsTreeTableViewCellDelegate> delegateQMSDataFormsTreeTableViewCell;
@property(nonatomic,strong) QMSPDFTemplate * pdfTemplate;
-(void) addpdfCopyViews;
-(void) removepdfCopyViews;
@end

@class QMSDataFormsTamplateCopyView;
@protocol QMSDataFormsTamplateCopyViewDelegate <NSObject>

-(void) pdfTemplateCopyView:(QMSDataFormsTamplateCopyView*) view
       didTapOnDeleteButton:(UIButton*) button;
-(void) pdfTemplateCopyView:(QMSDataFormsTamplateCopyView*) view
       didTapOnEditButton:(UIButton*) button;
-(void) pdfTemplateCopyView:(QMSDataFormsTamplateCopyView*) view
       didTapOnEmailButton:(UIButton*) button;
-(void) pdfTemplateCopyViewdidSelectView:(QMSDataFormsTamplateCopyView*) view;
-(void) pdfTemplateCopyView:(QMSDataFormsTamplateCopyView*) view
        didTapOnCheckButton:(UIButton*) button;

@end

@interface QMSDataFormsTamplateCopyView : UIView
@property(nonatomic,weak) IBOutlet UILabel * pdfCopyLabel;
@property(nonatomic,strong) QMSPDFTemplateCopy * pdfTemplateCopy;
@property (nonatomic) IBOutlet id<QMSDataFormsTamplateCopyViewDelegate> delegateQMSDataFormsTamplateCopyView;
@end

@interface QMSUploadDataFormsTreeTableViewCell : QMSDataFormsTreeTableViewCell

@end