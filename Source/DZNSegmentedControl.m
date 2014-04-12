//
//  DZNSegmentedControl.m
//  DZNSegmentedControl
//  https://github.com/dzenbot/DZNSegmentedControl
//
//  Created by Ignacio Romero Zurbuchen on 3/4/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNSegmentedControl.h"

#define kDZNDefaultHeight 56.0f

@interface DZNSegmentedControl () {
    UIView *_selectionIndicator;
    UIView *_hairline;
    NSMutableDictionary *_colors;
    BOOL _transitioning;
    
    UIColor *_tintColor;
    
    NSMutableArray *_buttons;
}

@end

@implementation DZNSegmentedControl

@synthesize items = _items;
@synthesize selectedSegmentIndex = _selectedSegmentIndex;
@synthesize barPosition = _barPosition;

@dynamic tintColor;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.tintColor = [UIColor lightGrayColor];
        
        _selectedSegmentIndex = -1;
        _font = [UIFont systemFontOfSize:15.0f];
        _selectionIndicatorHeight = 2.0f;
        _animationDuration = 0.2;
        _showsCount = YES;
        _autoAdjustSelectionIndicatorWidth = YES;
        
        _selectionIndicator = [[UIView alloc] init];
        _selectionIndicator.backgroundColor = self.tintColor;
        [self addSubview:_selectionIndicator];
        
        _hairline = [[UIView alloc] init];
        _hairline.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_hairline];
        
        _colors = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (instancetype)initWithItems:(NSArray *)items {
    self = [self init];
    
    if (self) {
        self.items = items;
    }
    
    return self;
}


#pragma mark - UIView Methods

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = 0.0f;
    
    for (UIButton *button in _buttons) {
        CGFloat newWidth = [button sizeThatFits:size].width;
        
        if (newWidth > width) {
            width = newWidth;
        }
    }
    
    width *= self.numberOfSegments;
    
    return CGSizeMake(MIN(width, size.width), MIN(kDZNDefaultHeight, size.height));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_buttons.count == 0) {
        _selectedSegmentIndex = -1;
    }
    else if (_selectedSegmentIndex < 0) {
        _selectedSegmentIndex = 0;
    }
    
    CGFloat singleWidth = (self.bounds.size.width/self.numberOfSegments);
    
    for (int i = 0; i < _buttons.count; i++) {
        UIButton *button = [_buttons objectAtIndex:i];
        
        [button setFrame:CGRectMake(singleWidth*i, 0.0f, singleWidth, self.bounds.size.height)];
        
        if (i == _selectedSegmentIndex) {
            button.selected = YES;
        }
    }

    _selectionIndicator.frame = [self selectionIndicatorRect];
    _hairline.frame = [self hairlineRect];
    
    [self bringSubviewToFront:_selectionIndicator];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (!self.backgroundColor) {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    [self configureAllSegments];
}


#pragma mark - Getter Methods

- (NSUInteger)numberOfSegments {
    return _items.count;
}

- (UIButton *)buttonAtIndex:(NSUInteger)segment {
    if (_items.count > 0 && segment < _buttons.count) {
        return (UIButton *)[_buttons objectAtIndex:segment];
    }
    
    return nil;
}

- (UIButton *)selectedButton {
    if (_selectedSegmentIndex >= 0) {
        return [self buttonAtIndex:_selectedSegmentIndex];
    }
    return nil;
}

- (NSString *)stringForSegmentAtIndex:(NSUInteger)segment {
    UIButton *button = [self buttonAtIndex:segment];
    return [[button attributedTitleForState:UIControlStateNormal] string];
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment {
    if (_showsCount) {
        NSString *title = [self stringForSegmentAtIndex:segment];
        NSArray *components = [title componentsSeparatedByString:@"\n"];
        
        if (components.count == 2) {
            return [components objectAtIndex:1];
        }
        else return nil;
    }
    return [_items objectAtIndex:segment];
}

- (NSNumber *)countForSegmentAtIndex:(NSUInteger)segment {
    NSString *title = [self stringForSegmentAtIndex:segment];
    NSArray *components = [title componentsSeparatedByString:@"\n"];
    
    if (components.count == 2) {
        return @([[components firstObject] intValue]);
    }
    else {
        return @(0);
    }
}

- (UIColor *)titleColorForState:(UIControlState)state {
    UIColor *color = [_colors objectForKey:@(state)];
    
    if (!color) {
        switch (state) {
            case UIControlStateNormal:              return [UIColor darkGrayColor];
            case UIControlStateHighlighted:         return self.tintColor;
            case UIControlStateDisabled:            return [UIColor lightGrayColor];
            case UIControlStateSelected:            return self.tintColor;
            default:                                return self.tintColor;
        }
    }

    return color;
}

- (CGRect)selectionIndicatorRect {
    CGRect frame = CGRectZero;
    UIButton *button = [self selectedButton];
    
    frame.origin.y = (_barPosition > UIBarPositionBottom) ? 0.0f : (button.frame.size.height-_selectionIndicatorHeight);
    
    if (_autoAdjustSelectionIndicatorWidth) {
        frame.size = CGSizeMake([button sizeThatFits:self.bounds.size].width, _selectionIndicatorHeight);
        frame.origin.x = (button.frame.size.width*(_selectedSegmentIndex))+(button.frame.size.width-frame.size.width)/2;
    }
    else {
        frame.size = CGSizeMake(button.frame.size.width, _selectionIndicatorHeight);
        frame.origin.x = (button.frame.size.width*(_selectedSegmentIndex));
    }
    
    return frame;
}

- (UIColor *)hairlineColor {
    return _hairline.backgroundColor;
}

- (CGRect)hairlineRect {
    CGRect frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, 0.5f);
    frame.origin.y = (_barPosition > UIBarPositionBottom) ? 0.0f : self.bounds.size.height;
    
    return frame;
}

#pragma mark - Setter Methods

- (UIColor *)tintColor {
    return _tintColor;
}

- (void)setTintColor:(UIColor *)color {
    _tintColor = color;
    
    _selectionIndicator.backgroundColor = color;
    
    [self setTitleColor:color forState:UIControlStateHighlighted];
    [self setTitleColor:color forState:UIControlStateSelected];
}

- (void)setItems:(NSArray *)items {
    if (_items) {
        [self removeAllSegments];
    }
    
    if (items) {
        _items = [NSArray arrayWithArray:items];
        [self insertAllSegments];
    }
}

- (void)setDelegate:(id <DZNSegmentedControlDelegate>)delegate {
    if (delegate == _delegate) {
        return;
    }
    
    _delegate = delegate;
    
    if ([self.delegate respondsToSelector:@selector(positionForBar:)]) {
        _barPosition = [self.delegate positionForBar:self];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)segment {
    if (segment > self.numberOfSegments-1) {
        segment = 0;
    }
    
    [self setSelected:YES forSegmentAtIndex:segment];
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment {
    if (!title) {
        return;
    }
    
    NSAssert(segment < self.numberOfSegments, @"Cannot assign a title to non-existing segment.");
    NSAssert(segment >= 0, @"Cannot assign a title to a negative segment.");
    
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.items];
    
    if (segment >= self.numberOfSegments) {
        [items insertObject:title atIndex:self.numberOfSegments];
        _items = items;
        
        [self addButtonForSegment:segment];
    }
    else {
        [items replaceObjectAtIndex:segment withObject:title];
        _items = items;
        
        [self setCount:[self countForSegmentAtIndex:segment] forSegmentAtIndex:segment];
    }
}

- (void)setCount:(NSNumber *)count forSegmentAtIndex:(NSUInteger)segment {
    if (!count || !_items) {
        return;
    }
    
    NSAssert(segment < self.numberOfSegments, @"Cannot assign a count to non-existing segment.");
    NSAssert(segment >= 0, @"Cannot assign a title to a negative segment.");
    
    NSMutableString *title = [NSMutableString stringWithFormat:@"%@",[_items objectAtIndex:segment]];
    if (_showsCount) {
        [title insertString:[NSString stringWithFormat:@"%@\n", count] atIndex:0];
    }

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    [self setAttributedTitle:attributedString forSegmentAtIndex:segment];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedString forSegmentAtIndex:(NSUInteger)segment {
    UIButton *button = [self buttonAtIndex:segment];
    button.titleLabel.numberOfLines = (_showsCount ? 2 : 1);
    
    [button setAttributedTitle:attributedString forState:UIControlStateNormal];
    [button setAttributedTitle:attributedString forState:UIControlStateHighlighted];
    [button setAttributedTitle:attributedString forState:UIControlStateSelected];
    [button setAttributedTitle:attributedString forState:UIControlStateDisabled];
    
    [self setTitleColor:[self titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self setTitleColor:[self titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [self setTitleColor:[self titleColorForState:UIControlStateDisabled] forState:UIControlStateDisabled];
    [self setTitleColor:[self titleColorForState:UIControlStateSelected] forState:UIControlStateSelected];

    _selectionIndicator.frame = [self selectionIndicatorRect];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    NSAssert([color isKindOfClass:[UIColor class]], @"Cannot assign a title color with an invalid color object.");
        
    for (UIButton *button in _buttons) {
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[button attributedTitleForState:state]];
        NSString *string = attributedString.string;

        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        style.lineBreakMode = (_showsCount ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail);
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.minimumLineHeight = 16.0f;
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, string.length)];
        
        if (_showsCount) {
            
            NSArray *components = [attributedString.string componentsSeparatedByString:@"\n"];
            
            if (components.count < 2) {
                return;
            }
            
            NSString *count = [components objectAtIndex:0];
            NSString *title = [components objectAtIndex:1];
            
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:_font.fontName size:19.0] range:[string rangeOfString:count]];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:_font.fontName size:12.0] range:[string rangeOfString:title]];
            
            if (state == UIControlStateNormal) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, count.length)];
                [attributedString addAttribute:NSForegroundColorAttributeName value:[color colorWithAlphaComponent:0.5] range:NSMakeRange(count.length, title.length+1)];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, string.length)];
                
                if (state == UIControlStateSelected) {
                    _selectionIndicator.backgroundColor = color;
                }
            }
        }
        else {
            [attributedString addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, attributedString.string.length)];
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.string.length)];
        }
        
        [button setAttributedTitle:attributedString forState:state];
    }
    
    _colors[@(state)] = color;
}

- (void)setSelected:(BOOL)selected forSegmentAtIndex:(NSUInteger)segment {
    if (_selectedSegmentIndex == segment || _transitioning) {
        return;
    }
    
    for (UIButton *_button in _buttons) {
        _button.highlighted = NO;
        _button.selected = NO;
        _button.userInteractionEnabled = YES;
    }
    
    NSTimeInterval duration = (_selectedSegmentIndex < 0 ? 0.0 : _animationDuration);
    
    _selectedSegmentIndex = segment;
    _transitioning = YES;
    
    UIButton *button = [self buttonAtIndex:segment];
    
    [UIView animateWithDuration:duration delay:0.0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut) animations:^{
        _selectionIndicator.frame = [self selectionIndicatorRect];
    } completion:^(BOOL finished) {
        button.userInteractionEnabled = NO;
        _transitioning = NO;
    }];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setDisplayCount:(BOOL)count {
    if (_showsCount == count) {
        return;
    }
    
    _showsCount = count;
    
    for (int i = 0; i < _buttons.count; i++) {
        [self configureButtonForSegment:i];
    }
    
    _selectionIndicator.frame = [self selectionIndicatorRect];
}

- (void)setFont:(UIFont *)font {
    if ([_font isEqual:font]) {
        return;
    }
    
    _font = font;
    
    for (int i = 0; i < _buttons.count; i++) {
        [self configureButtonForSegment:i];
    }
    
    _selectionIndicator.frame = [self selectionIndicatorRect];
}

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment {
    UIButton *button = [self buttonAtIndex:segment];
    button.enabled = enabled;
}

- (void)setHairlineColor:(UIColor *)color {
    _hairline.backgroundColor = color;
}


#pragma mark - DZNSegmentedControl Methods

- (void)insertAllSegments {
    for (int i = 0; i < self.numberOfSegments; i++) {
        [self addButtonForSegment:i];
    }
}

- (void)addButtonForSegment:(NSUInteger)segment {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button addTarget:self action:@selector(didSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    button.backgroundColor = nil;
    button.opaque = YES;
    button.clipsToBounds = YES;
    button.adjustsImageWhenHighlighted = NO;
    button.adjustsImageWhenDisabled = NO;
    button.tag = segment;
        
    [self addSubview:button];
    
    [_buttons addObject:button];
}

- (void)configureAllSegments {
    for (UIButton *button in _buttons) {
        
        NSAttributedString *attributedString = [button attributedTitleForState:UIControlStateNormal];
        
        if (attributedString.string.length > 0) {
            continue;
        }
        
        [self configureButtonForSegment:button.tag];
    }
    
    _selectionIndicator.frame = [self selectionIndicatorRect];
}

- (void)configureButtonForSegment:(NSUInteger)segment {
    if (_showsCount) {
        [self setCount:[self countForSegmentAtIndex:segment] forSegmentAtIndex:segment];
    }
    else {
        [self setTitle:[_items objectAtIndex:segment] forSegmentAtIndex:segment];
    }
}

- (void)didSelectedButton:(UIButton *)button {
    if (!_transitioning) {
        self.selectedSegmentIndex = button.tag;
    }
}

- (void)removeAllSegments {
    if (_transitioning) {
        return;
    }
    
    for (UIButton *_button in _buttons) {
        [_button removeFromSuperview];
    }
    
    _items = nil;
    
    _buttons = nil;
}

@end
