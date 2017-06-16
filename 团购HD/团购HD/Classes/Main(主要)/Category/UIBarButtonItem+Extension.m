

#import "UIBarButtonItem+Extension.h"

@implementation UIBarButtonItem (Extension)


+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image highlightedImage:(NSString *)highlightedImage
{
    UIButton *Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [Btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [Btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [Btn setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    [Btn sizeToFit];
    return [[UIBarButtonItem alloc] initWithCustomView:Btn];
}

@end
