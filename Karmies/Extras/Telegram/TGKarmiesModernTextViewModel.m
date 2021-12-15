#import "TGKarmiesModernTextViewModel.h"

#import <Karmies/Karmies-Swift.h>


#define DATE_TEXT_WIDTH 75


@interface TGKarmiesModernTextViewModel ()
{
    BOOL _krm_outgoing;
}

@property (readonly) UIFont *fontAsUI;

@end


@implementation TGKarmiesModernTextViewModel

- (instancetype)initWithText:(NSString *)text outgoing:(BOOL)outgoing font:(CTFontRef)font
{
    if (self = [super initWithText:text font:font ]) {
        _krm_outgoing = outgoing;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    [[KarmiesContext sharedInstance] drawSerializedMessage:self.text outgoing:_krm_outgoing insideFrame:self.bounds withFont:self.fontAsUI];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    CGSize size = [[KarmiesContext sharedInstance] measureSerializedMessage:self.text outgoing:_krm_outgoing font:[self fontAsUI] maxWidth:(float)containerSize.width - DATE_TEXT_WIDTH];
    size.width = size.width + DATE_TEXT_WIDTH;
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData
{
    NSString *link = [[KarmiesContext sharedInstance] linkAtPoint:point insideFrame:self.frame withSerializedMessage:self.text outgoing:_krm_outgoing font:[self fontAsUI]];
    if (link != nil) {
        if (regionData != NULL) {
            *regionData = @[[NSValue valueWithCGRect:CGRectZero]];
        }
        return link;
    }
    
    return nil;
}

- (UIFont *)fontAsUI
{
    return [KarmiesUtils UIFontFromCTFont:self.font];
}

@end
