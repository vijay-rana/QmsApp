//
//  PDF.m
//  Receipts
//


#import "PDF.h"

@implementation PDF
@synthesize size, imageArray, header, imageRectArray, textArray, textRectArray,textSizeArray, data, headerRect;
-(void)initContent{
    imageArray = [[NSMutableArray alloc]init];
    imageRectArray = [[NSMutableArray alloc]init];
    
    textArray = [[NSMutableArray alloc]init];
    textRectArray = [[NSMutableArray alloc]init];
    textSizeArray=[[NSMutableArray alloc]init];

    data = [NSMutableData data];
    headerRect = CGRectMake(332, 30, 137, 30);
  //  data = [NSMutableData data];

}

- (void) drawHeader
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext,  0.0, 0.0, 0.0, 1.0);
    
    NSString *textToDraw = header;
    
   // UIFont *font = [UIFont boldSystemFontOfSize:18.0];
    
    UIFont *font=[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:18];
    
    
    /*
    CGSize stringSize = [textToDraw sizeWithFont:font constrainedToSize:CGSizeMake(size.width - 2*kBorderInset-2*kMarginInset, size.height - 2*kBorderInset - 2*kMarginInset) lineBreakMode:UILineBreakModeWordWrap];
    
    
    CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset, size.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
    */
    CGRect renderingRect = headerRect;
    //Added by KK
    /****************/
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    [textToDraw drawInRect:renderingRect withAttributes:attributes];
    /****************/

  //  [textToDraw drawInRect:renderingRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];//Old
}
-(void)drawImage{
    for (int i = 0; i < [imageArray count]; i++) {
        [imageArray[i] drawInRect:[imageRectArray[i]CGRectValue]];

    }
}
- (void) drawText
{
    for (int i = 0; i < [textArray count]; i++) {
        
    
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
    
    NSString *textToDraw = textArray[i];
    
     //   (@"%d",[textSizeArray count]);
        
        NSString *fontName=textSizeArray[i];
        UIFont *font;
        if ([fontName isEqualToString:@"string"]) {
     
            font=[UIFont fontWithName:@"TimesNewRomanPSMT" size:14];
        }else
        {
         font=[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:15];
        
        }
    
      //  //NSLog(@"Text to draw: %@", textToDraw);
        CGRect renderingRect = [textRectArray[i]CGRectValue];
      //  //NSLog(@"x of rect is %f",  renderingRect.origin.x);
   
        //Added by KK
        /****************/
        /// Make a copy of the default paragraph style
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        /// Set line break mode
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        /// Set text alignment
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary *attributes = @{ NSFontAttributeName: font,
                                      NSParagraphStyleAttributeName: paragraphStyle };
        
        [textToDraw drawInRect:renderingRect withAttributes:attributes];
        /****************/
    
//       [textToDraw drawInRect:renderingRect
//                  withFont:font
//             lineBreakMode:NSLineBreakByWordWrapping
//                 alignment:NSTextAlignmentLeft];//Old
    }
    
}
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}
-(void)addImageWithRect:(UIImage *)image :(CGRect)rect{
    UIImage *newImage = [PDF imageWithImage:image scaledToSize:CGSizeMake(rect.size.width, rect.size.height)];
        
    
    [imageArray addObject:newImage];
    [imageRectArray addObject:[NSValue valueWithCGRect:rect]];
    //imageForPdf = [UIImage imageNamed:@"button.png"];
    /*UIGraphicsBeginImageContext(size);

    [imageForPdf drawAtPoint:CGPointMake(0,0)];
    //Watch for errors on next line;; never tried before
   // [image drawAtPoint:CGPointMake(0,0)];
	[image drawInRect:rect];
    
    imageForPdf = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     */
}
-(void)addTextWithRect:(NSString*)text : (CGRect)rect : (NSString *)FontName{
    [textArray addObject:text];
    [textRectArray addObject:[NSValue valueWithCGRect:rect]];
   
    if (!FontName) {
        [textSizeArray addObject:@"string"];

    }else
    {
        [textSizeArray addObject:FontName];
    }
    

}
- (NSMutableData*) generatePdfWithFilePath: (NSString *)thefilePath
{
    
    UIGraphicsBeginPDFContextToFile(thefilePath, CGRectZero, nil);
   
   
    BOOL done = NO;
    do 
    {
        //Start a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, size.width, size.height), nil);
        
        //Draw Header
        [self drawHeader];
        //Draw Text
        [self drawText];
        //Draw an image
        [self drawImage];
        
        done = YES;
    } 
    while (!done);
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
    
    //For data    
    UIGraphicsBeginPDFContextToData(data, CGRectZero, nil);
    
    
    BOOL done1 = NO;
    do 
    {
        //Start a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, size.width, size.height), nil);
        
        //Draw Header
        [self drawHeader];
        //Draw Text
        [self drawText];
        //Draw an image
        [self drawImage];
        
        done1 = YES;
    } 
    while (!done1);
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    return data;
}

#pragma mark draw bold text
-(void)addBoldTextWithRect:(NSString*)text : (CGRect)rect
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext,  0.0, 0.0, 0.0, 1.0);
    
    NSString *textToDraw = header;
    
    // UIFont *font = [UIFont boldSystemFontOfSize:18.0];
    
    UIFont *font=[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:14];
    
    
    /*
     CGSize stringSize = [textToDraw sizeWithFont:font constrainedToSize:CGSizeMake(size.width - 2*kBorderInset-2*kMarginInset, size.height - 2*kBorderInset - 2*kMarginInset) lineBreakMode:UILineBreakModeWordWrap];
     
     
     CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset, size.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
     */
    CGRect renderingRect = rect;
    
    
    //Added by KK
    /****************/
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    [textToDraw drawInRect:renderingRect withAttributes:attributes];
    /****************/
    //[textToDraw drawInRect:renderingRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
}



@end
