//
//  ViewController.m
//  The Button
//
//  Created by Michael Latman on 4/8/15.
//  Copyright (c) 2015 Michael Latman. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong) SRWebSocket* connection;
@property Boolean open;
@property NSString *url;
@end

@implementation ViewController
@synthesize timeLabel;
@synthesize timer;
@synthesize mills,participants_text;
@synthesize url;
@synthesize seconds,milliOne,milliTen,secondsOne,secondsTen;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    url = [self fetchWebSocketURL];  // Fetch fresh URL from reddit servers
    _connection = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url]]; // Create new websocket connection
    _connection.delegate = self; // We need to get messages every second
    [_connection open]; // Open connection

    // Attempt to reconnect every 5 seconds.
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reconnect) userInfo:nil repeats:YES];
    
    
    // Update out countdown, because reddit only gives us updates every second we must interpolate
    timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(updateCountdown:) userInfo:nil repeats:YES];
    
    // Update nav bar
    [self setNeedsStatusBarAppearanceUpdate];
}



- (NSString*) fetchWebSocketURL{
    // Reddit websocket tokens expire after a certain amont of time so we must fetch a new one every load.
    UNIHTTPStringResponse *response = [[UNIRest post:^(UNISimpleRequest *request) {
        [request setUrl:@"http://reddit.com/r/thebutton"];
        NSDictionary* headers = @{@"accept": @"text/html"};
        [request setHeaders:headers];
        // [request setParameters:parameters];
    }] asString];
    
    if(response != nil){
        NSLog(@"%@",url);
        
        NSError* regexError = nil;
        // Parse the HTML content of the reddit page to find the token for our connection
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"(wss://wss.redditmedia.com/thebutton\\?h=)(\\w+)&e=\\w+"
                                                                               options:0
                                      
                                                                                 error:&regexError];
        
        if (regexError)
        {
            NSLog(@"Regex creation failed with error: %@", [regexError description]);
            
        }
        
        
        NSArray* matches = [regex matchesInString:response.body
                                          options:0
                                            range:NSMakeRange(0, response.body.length)];
        NSString* token = [response.body substringWithRange:[[matches lastObject] range]];
        NSLog(@"%@",[response.body substringWithRange:[[matches lastObject] range]]);
        if([matches count] != 0){
            // Return the token.
            return token;
        }
        
   
    }
    return @"wss://wss.redditmedia.com/thebutton"; // Will fail.

}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    // Reddit has sent us an update.
    
    NSError *jsonParsingError = nil;
    NSData *objectData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonParsingError];
    //participants_text
     NSLog(@"Received \"%@\"", [[json objectForKey:@"payload"] objectForKey:@"seconds_left"]);
    [participants_text setText:[NSString stringWithFormat:@"%@ participants",  [[json objectForKey:@"payload"] objectForKey:@"participants_text"]
]];
    int secs = [[[json objectForKey:@"payload"] objectForKey:@"seconds_left"] integerValue];

    seconds = secs; // Set seconds
    seconds--; // Take one second away (seems to be help keep our clock in sync with reddits.
    mills = [NSDate date]; // Update the millseconds to now.

    //if([_connection readyState] == SR_OPEN)[_connection close];
    
}


- (void) webSocketDidOpen:(SRWebSocket *)webSocket{
    _open = YES;
}

- (void) webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"Fail");
    _open = NO;
    //[timer invalidate];


}
- (void) webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"Closed");
    _open = NO;
 }
- (void) reconnect{
  
    if([_connection readyState] == SR_CLOSING||[_connection readyState] == SR_CLOSED){
          NSLog(@"Attempt reconnect %ld",(long)[_connection readyState]);
     _connection = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url]];
        _connection.delegate = self;
        [_connection open];
    }
}
- (IBAction)openReddit:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.reddit.com/r/thebutton"]];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void) viewDidAppear:(BOOL)animated{
    //[_connection open];
}
- (void)updateCountdown:(NSTimer *)timer
{
    // Update the GUI for the new time. 
    if(_open){
        [_couldNotConnect setHidden: true];
        double diff = [mills timeIntervalSinceNow];
        diff*=-100;
        if(diff>=99){
            seconds --;
            mills = [NSDate date];
            diff = 0;
        }
        diff = floor(diff);
        int display = 99-diff;
        if(display<0) display = 0;
        

        
        //[timeLabel setText:[NSString stringWithFormat: @"%02d.%02d",seconds,display]];
        NSString *sTen = [NSString stringWithFormat:@"%d", seconds / 10];
        NSString *sOne = [NSString stringWithFormat:@"%d", seconds % 10];
        NSString *mTen = [NSString stringWithFormat:@"%d", display / 10];
        NSString *mOne = [NSString stringWithFormat:@"%d", display % 10];

        [secondsTen setText:sTen];
        [secondsOne setText:sOne];

        [milliTen setText:mTen];
        [milliOne setText:mOne];
    }
    else{
        [_couldNotConnect setHidden: false];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
