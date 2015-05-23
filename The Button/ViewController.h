//
//  ViewController.h
//  The Button
//
//  Created by Michael Latman on 4/8/15.
//  Copyright (c) 2015 Michael Latman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"
#import "AFNetworking/AFNetworking.h"
#import "Unirest/UNIRest.h"
@interface ViewController : UIViewController  <SRWebSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *secondsTen;
@property (weak, nonatomic) IBOutlet UILabel *participants_text;
@property (weak, nonatomic) IBOutlet UITextField *milliOne;
@property (weak, nonatomic) IBOutlet UITextField *secondsOne;
@property (weak, nonatomic) IBOutlet UITextField *milliTen;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) NSTimer *timer;
@property (nonatomic) NSDate *mills;
@property (weak, nonatomic) IBOutlet UILabel *couldNotConnect;
@property (nonatomic) NSInteger seconds;
@end

