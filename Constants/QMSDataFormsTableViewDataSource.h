//
//  QMSDataFormsTableViewDataSource.h
//  QMS
//
//  Created by Mac Book Pro on 21/04/15.
//  Copyright (c) 2015 Techechelons. All rights reserved.
//

#import "QMSTableViewDataSource.h"

@protocol QMSDataFormsTableViewDataSourceDelegate <QMSTableViewDataSourceDelegate>

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
        didTouchedOnNewPDFForValue:(id) value;
-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
 didTouchedOnDeletePDFTemplate:(id) value;

-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
         didEditPDFForValue:(id) value;
-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
       didDeletePDFForValue:(id) value;
-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
        didEmailPDFForValue:(id) value;
-(void) tableViewDataSource:(SSTableViewDataSource*) dataSource
        didSelectPDFForValue:(id) value;
@end

@interface QMSDataFormsTableViewDataSource : QMSTableViewDataSource<QMSDataFormsTamplateCopyViewDelegate>{
    NSMutableArray *checkedPDFForms;
}
@property (nonatomic) IBOutlet id<QMSDataFormsTableViewDataSourceDelegate> delegateQMSTableViewDataSource;
@end


@interface QMSUploadDataFormsTableViewDataSource : QMSDataFormsTableViewDataSource<QMSDataFormsTamplateCopyViewDelegate>
-(NSArray*) checkedPDFForms;
@end