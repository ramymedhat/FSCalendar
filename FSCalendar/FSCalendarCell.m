//
//  FSCalendarCell.m
//  Pods
//
//  Created by Wenchao Ding on 12/3/15.
//
//

#import "FSCalendarCell.h"
#import "FSCalendar.h"
#import "UIView+FSExtension.h"
#import "NSDate+FSExtension.h"
#import "FSCalendarDynamicHeader.h"

#define kAnimationDuration 0.15

@implementation FSCalendarCell {
    CALayer *_separatorLayer;
    CAShapeLayer *_ringLayer;
}

#pragma mark - Init and life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.font = [UIFont systemFontOfSize:10];
        subtitleLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:subtitleLabel];
        self.subtitleLabel = subtitleLabel;
        
        CAShapeLayer *ringLayer = [CAShapeLayer layer];
        ringLayer.backgroundColor = [UIColor clearColor].CGColor;
        ringLayer.hidden = NO;
        [self.contentView.layer insertSublayer:ringLayer atIndex:0];
        _ringLayer = ringLayer;
        
        CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
        backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
        backgroundLayer.hidden = YES;
        [self.contentView.layer insertSublayer:backgroundLayer atIndex:0];
        self.backgroundLayer = backgroundLayer;
        
        CAShapeLayer *eventLayer = [CAShapeLayer layer];
        eventLayer.backgroundColor = [UIColor clearColor].CGColor;
        eventLayer.fillColor = [UIColor cyanColor].CGColor;
        eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:eventLayer.bounds].CGPath;
        eventLayer.hidden = YES;
        [self.contentView.layer addSublayer:eventLayer];
        self.eventLayer = eventLayer;
        
        CALayer *imageLayer = [CALayer layer];
        imageLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self.contentView.layer addSublayer:imageLayer];
        self.imageLayer = imageLayer;
        
        CALayer *separatorLayer = [CALayer layer];
        separatorLayer.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4].CGColor;
        [self.contentView.layer addSublayer:separatorLayer];
        _separatorLayer = separatorLayer;
        
        self.clipsToBounds = NO;
        self.contentView.clipsToBounds = NO;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CGFloat titleHeight = self.bounds.size.height*4.0/6.0;
    
    if (self.isSelected || (self.dateIsSelected && !_deselecting)) {
        CGFloat diameter = MIN(self.bounds.size.height*3.0/6.0,self.bounds.size.width);
        _backgroundLayer.frame = CGRectMake((self.bounds.size.width-diameter)/2,
                                            (titleHeight-diameter)/2,
                                            diameter,
                                            diameter);
    }
    else {
        CGFloat diameter = MIN(self.bounds.size.height*3.0/6.0,self.bounds.size.width);
        _backgroundLayer.frame = CGRectMake((self.bounds.size.width-diameter)/2,
                                            (titleHeight-diameter)/2,
                                            diameter,
                                            diameter);
    }
    
    CGFloat diameter = self.bounds.size.height*3.5/6.0;
    _ringLayer.frame = CGRectMake((self.bounds.size.width-diameter)/2,
                                        (titleHeight-diameter)/2,
                                        diameter,
                                        diameter);
    
    CGFloat eventSize = _backgroundLayer.frame.size.height/6.0;
    _eventLayer.frame = CGRectMake((_backgroundLayer.frame.size.width-eventSize)/2+_backgroundLayer.frame.origin.x, CGRectGetMaxY(_backgroundLayer.frame)+eventSize*0.85, eventSize*1.1, eventSize*1.1);
    _eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:_eventLayer.bounds].CGPath;
    
    _separatorLayer.frame = CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.3);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self configureCell];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [CATransaction setDisableActions:YES];
}

#pragma mark - Public

- (void)performSelecting
{
    _backgroundLayer.hidden = NO;
    _backgroundLayer.path = [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath;
    _backgroundLayer.strokeColor = [self colorForCurrentStateInDictionary:_appearance.backgroundColors].CGColor;
    _backgroundLayer.fillColor = [UIColor clearColor].CGColor;
    
    _ringLayer.hidden = NO;
    _ringLayer.path = [UIBezierPath bezierPathWithOvalInRect:_ringLayer.bounds].CGPath;
    _ringLayer.strokeColor = [self colorForCurrentStateInDictionary:_appearance.backgroundColors].CGColor;
    _ringLayer.fillColor = [UIColor clearColor].CGColor;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    CABasicAnimation *zoomOut = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomOut.fromValue = @0.3;
    zoomOut.toValue = @1.2;
    zoomOut.duration = kAnimationDuration/4*3;
    CABasicAnimation *zoomIn = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomIn.fromValue = @1.2;
    zoomIn.toValue = @1.0;
    zoomIn.beginTime = kAnimationDuration/4*3;
    zoomIn.duration = kAnimationDuration/4;
    group.duration = kAnimationDuration;
    group.animations = @[zoomOut, zoomIn];
    [_backgroundLayer addAnimation:group forKey:@"bounce"];
    [self configureCell];
}

- (void)performDeselecting
{
    _deselecting = YES;
    [self configureCell];
    _deselecting = NO;
}

#pragma mark - Private

- (void)configureCell
{
    _titleLabel.font = (self.dateIsToday) ? [UIFont boldSystemFontOfSize:_appearance.titleTextSize] : [UIFont systemFontOfSize:_appearance.titleTextSize];
    _titleLabel.text = [NSString stringWithFormat:@"%@",@(_date.fs_day)];
    _subtitleLabel.font = [UIFont systemFontOfSize:_appearance.subtitleTextSize];
    _subtitleLabel.text = _subtitle;
    _titleLabel.textColor = [self colorForCurrentStateInDictionary:_appearance.titleColors];
    _subtitleLabel.textColor = [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
    
    if (self.isSelected || (self.dateIsSelected && !_deselecting)) {
        _backgroundLayer.fillColor = (self.dateBackgroundColor.CGColor) ? : [self colorForCurrentStateInDictionary:_appearance.backgroundColors].CGColor;
        _backgroundLayer.strokeColor = (self.dateBackgroundColor.CGColor) ? : [self colorForCurrentStateInDictionary:_appearance.backgroundStrokeColors].CGColor;
        _ringLayer.strokeColor = (self.dateBackgroundColor.CGColor) ? : [self colorForCurrentStateInDictionary:_appearance.backgroundStrokeColors].CGColor;
        _ringLayer.hidden = NO;
    }
    else {
        _backgroundLayer.fillColor = ([self.dateBackgroundColor colorWithAlphaComponent:0.75].CGColor) ? : [self colorForCurrentStateInDictionary:_appearance.backgroundColors].CGColor;
        _backgroundLayer.strokeColor = ([self.dateBackgroundColor colorWithAlphaComponent:0.75].CGColor) ? : [self colorForCurrentStateInDictionary:_appearance.backgroundStrokeColors].CGColor;
        _ringLayer.strokeColor = ([self.dateBackgroundColor colorWithAlphaComponent:0.75].CGColor) ? : [self colorForCurrentStateInDictionary:_appearance.backgroundStrokeColors].CGColor;
        _ringLayer.hidden = YES;
    }
    
    CGFloat titleHeight = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].height;
    if (_subtitleLabel.text) {
        _subtitleLabel.hidden = NO;
        CGFloat subtitleHeight = [_subtitleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.subtitleLabel.font}].height;
        CGFloat height = titleHeight + subtitleHeight;
        _titleLabel.frame = CGRectMake(0,
                                       (self.contentView.fs_height*4.0/6.0-height)*0.5,
                                       self.fs_width,
                                       titleHeight);
        
        _subtitleLabel.frame = CGRectMake(0,
                                          _titleLabel.fs_bottom - (_titleLabel.fs_height-_titleLabel.font.pointSize),
                                          self.fs_width,
                                          subtitleHeight);
    } else {
        _titleLabel.frame = CGRectMake(0, 0, self.fs_width, floor(self.contentView.fs_height*4.0/6.0));
        _subtitleLabel.hidden = YES;
    }
    _backgroundLayer.hidden = !self.selected && !self.dateIsToday && !self.dateIsSelected  && !self.dateBackgroundColor;
    _backgroundLayer.path = _appearance.cellStyle == FSCalendarCellStyleCircle ?
    [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath :
    [UIBezierPath bezierPathWithRect:_backgroundLayer.bounds].CGPath;
    
//    _ringLayer.path = _appearance.cellStyle == FSCalendarCellStyleCircle ?
//    [UIBezierPath bezierPathWithOvalInRect:_ringLayer.bounds].CGPath :
//    [UIBezierPath bezierPathWithRect:_ringLayer.bounds].CGPath;
    
    _eventLayer.hidden = !_hasEvent;
    _eventLayer.fillColor = _appearance.eventColor.CGColor;
    
    if (_image) {
        _imageLayer.hidden = NO;
        _imageLayer.frame = CGRectMake((self.fs_width-_image.size.width)*0.5, self.fs_height-_image.size.height-2.5, _image.size.width, _image.size.height);
        _imageLayer.contents = (id)_image.CGImage;
    } else {
        _imageLayer.hidden = YES;
        _imageLayer.contents = nil;
    }
}

- (BOOL)isWeekend
{
    return self.date.fs_weekday == 1 || self.date.fs_weekday == 7;
}

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary
{
    if (self.isSelected || (self.dateIsSelected && !_deselecting)) {
        if (self.dateIsToday) {
            return dictionary[@(FSCalendarCellStateSelected|FSCalendarCellStateToday)] ?: dictionary[@(FSCalendarCellStateSelected)];
        }
        return dictionary[@(FSCalendarCellStateSelected)];
    }
    if (self.dateIsToday) {
        return dictionary[@(FSCalendarCellStateToday)];
    }
    if (self.dateIsPlaceholder) {
        return dictionary[@(FSCalendarCellStatePlaceholder)];
    }
    if (self.isWeekend && [[dictionary allKeys] containsObject:@(FSCalendarCellStateWeekend)]) {
        return dictionary[@(FSCalendarCellStateWeekend)];
    }
    return dictionary[@(FSCalendarCellStateNormal)];
}

@end



