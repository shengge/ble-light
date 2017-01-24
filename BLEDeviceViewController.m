//
//  BLEDeviceViewController.m
//  HelloBTSmart
//
//  Created by BTSmartShield on 7/13/12.
//  Copyright (c) 2012 BTSmartShield.com. All rights reserved.
//

#import "BLEDeviceViewController.h"
#import "LBDefine.h"
#import "LBDevice.h"

@interface BLEDeviceViewController ()

@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, assign) CGPoint currentPoint;

@end

@implementation BLEDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _powerOn = NO;

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_device setupWithShield:_sensor];
    });
    
    _nameLabel.text = _device.peripheral.name;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didWriteValue)
                                                 name:kNotiPeripheralWrited
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(turnOn)
                                                 name:kNotiPeripheralAround
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(turnOff)
                                                 name:kNotiPeripheralLost
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(turnOn)
                                                 name:kNotiAlarming
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(turnOff)
                                                 name:kNotiCoverUp
                                               object:nil];
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureRecognizer:)];
    recognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:recognizer];
    _lastBrightValue = 128;
}

- (void)viewDidUnload {
    [self setNameLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_sensor disconnect:_device.peripheral];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (![textField.text length]) {
        return;
    }
    
    _nameLabel.text = textField.text;
    _device.name = textField.text;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - custom method

- (void)writeValue
{
    if (!_lastWriteTime || [_lastWriteTime timeIntervalSinceNow] < -0.1) {
        _lastWriteTime = [NSDate date];
        [_device changeBrightness:_brightValue completion:^(id response, NSError *error) {
            if (_lastBrightValue != _brightValue) {
                _lastBrightValue = _brightValue;
                [_device changeBrightness:_brightValue completion:nil];
            }
        }];
    }
}

- (void)didWriteValue
{
    
}

- (void)turnOn {
    if (_powerOn) {
        return;
    }
    
    NSLog(@"turn on");
    _powerOn = YES;
    [_device turnOn];
    
}

- (void)turnOff {
    if (!_powerOn) {
        return;
    }
    
    NSLog(@"turn off");
    _powerOn = NO;
    [_device turnOff];
}

#pragma mark - actionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    _device.style = [NSNumber numberWithInteger:buttonIndex];
}

#pragma mark - IBAction

- (IBAction)renameClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.placeholder = @"给小灯取个名吧";
    textField.delegate = self;
    [alert show];
}

- (IBAction)styleClicked:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"灯泡类型"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"过道灯", @"床头灯", @"台灯", nil];
    [action showInView:self.view];
}

#pragma mark - UIPangestureRecognizer
- (void)handleGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.currentPoint = [recognizer locationInView:self.view];
    } else if (recognizer.state == UIGestureRecognizerStateChanged){
        CGPoint point = [recognizer locationInView:self.view];
        CGFloat adjustHeight = point.y - self.currentPoint.y;
        CGFloat height = CGRectGetHeight(self.gestureView.frame) + adjustHeight;
        if (height < 0) {
            height = 0;
        } else if (height > CGRectGetHeight(self.view.frame)) {
            height = CGRectGetHeight(self.view.frame);
        }
        self.gestureView.frame = CGRectMake(CGRectGetMinX(self.gestureView.frame), CGRectGetMinY(self.gestureView.frame), CGRectGetWidth(self.gestureView.frame), height);
        
        CGFloat totalHeight = CGRectGetHeight(self.view.frame);
        _brightValue = (totalHeight - height) * 255/totalHeight;

        NSLog(@"destinate value:%d", _brightValue);
        if (_brightValue < 0) {
            _brightValue = 0;
        } else if (_brightValue > 255) {
            _brightValue = 255;
        }
        self.currentPoint = point;
        [self writeValue];
        
    } else {
        _currentPoint = CGPointZero;
    }
}

@end
