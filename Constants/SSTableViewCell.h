//
//  SSTableViewCell.h
//  ServShare
//
//  Created by Mac Book Pro on 09/02/15.
//  Copyright (c) 2015 Dipak Vyawahare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@end

@interface SSTableViewCellWithImage : SSTableViewCell
@property (nonatomic,weak) IBOutlet UIImageView *corrospondingImageView;
@end