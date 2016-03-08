//
//  PDF.h
//


#import <Foundation/Foundation.h>




@interface PDF : NSObject{
}
@property(nonatomic, readwrite) CGSize size;
@property(nonatomic, readwrite) CGRect headerRect;

@property(nonatomic, strong) NSString *header;

@property(nonatomic, strong) NSMutableArray *imageArray;
@property(nonatomic, strong) NSMutableArray *imageRectArray;

@property(nonatomic, strong) NSMutableArray *textArray;
@property(nonatomic, strong) NSMutableArray *textRectArray;
@property(nonatomic,strong)NSMutableArray *textSizeArray;

@property(nonatomic, strong)  NSMutableData *data;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

-(void)initContent;
-(void)addImageWithRect:(UIImage*)image : (CGRect)rect;
-(void)addTextWithRect:(NSString*)text : (CGRect)rect : (NSString *)FontName;
-(void)addBoldTextWithRect:(NSString*)text : (CGRect)rect;
- (void) drawHeader;
- (void) drawImage;
- (NSMutableData*) generatePdfWithFilePath: (NSString *)thefilePath;
@end
