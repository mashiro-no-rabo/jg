//
//  JGEditPageContentView.m
//  JikanGachou
//
//  Created by Xhacker Liu on 1/9/14.
//  Copyright (c) 2014 TeaWhen. All rights reserved.
//

#import "JGEditPageMainView.h"

@interface JGEditPageMainView () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *yearLabel1;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel1;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel1;

@property (weak, nonatomic) IBOutlet UILabel *yearLabel2;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel2;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel2;

@end

@implementation JGEditPageMainView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleTextField.delegate = self;
    self.authorTextField.delegate = self;
    self.descriptionTextView.delegate = self;

    self.imageView1.userInteractionEnabled = YES;
    self.imageView2.userInteractionEnabled = YES;
}

- (void)fillNth:(NSUInteger)n withPhoto:(ALAsset *)p
{
    UIImageView *imageView = [self valueForKey:[NSString stringWithFormat:@"imageView%lu", (unsigned long)n]];
    UILabel *yearLabel = [self valueForKey:[NSString stringWithFormat:@"yearLabel%lu", (unsigned long)n]];
    UILabel *monthLabel = [self valueForKey:[NSString stringWithFormat:@"monthLabel%lu", (unsigned long)n]];
    UILabel *dayLabel = [self valueForKey:[NSString stringWithFormat:@"dayLabel%lu", (unsigned long)n]];
    
    if (p) {
        UIImage *image = [UIImage imageWithCGImage:p.defaultRepresentation.fullScreenImage];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        NSDate *date = [p valueForProperty:ALAssetPropertyDate];
        static NSDateFormatter *yearFormatter, *monthFormatter, *dayFormatter;
        if (!yearFormatter) {
            yearFormatter = [NSDateFormatter new];
            yearFormatter.dateFormat = @"YYYY";
            monthFormatter = [NSDateFormatter new];
            monthFormatter.dateFormat = @"MMM";
            dayFormatter = [NSDateFormatter new];
            dayFormatter.dateFormat = @"dd";
        }
        yearLabel.text = [yearFormatter stringFromDate:date];
        monthLabel.text = [monthFormatter stringFromDate:date];
        dayLabel.text = [dayFormatter stringFromDate:date];
        
        yearLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
        monthLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
        dayLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
        
        [dayLabel sizeToFit];
    }
    else {
        imageView.image = [UIImage imageNamed:@"Placeholder"];
        imageView.contentMode = UIViewContentModeScaleToFill;
    }
}

- (void)setDescriptionText:(NSString *)descriptionText
{
    self.descriptionTextView.text = descriptionText;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"点击添加描述…"]) {
        textView.text = @"";
        textView.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"点击添加描述…";
        textView.textColor = [UIColor lightGrayColor];
    }
    [self.delegate saveDescriptionText:textView.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.titleTextField) {
        [self.authorTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.titleTextField]) {
        [self.delegate saveTitle:textField.text];
    }
    else if ([textField isEqual:self.authorTextField]) {
        [self.delegate saveAuthor:textField.text];
    }
}

@end
