//
//  ViewController.h
//  WcfClient
//
//  Created by pramesh on 1/7/14.
//  Copyright (c) 2014 pramesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<NSURLConnectionDataDelegate, NSXMLParserDelegate>{
    NSMutableData *_responseData;
    NSXMLParser *xmlParser;
    NSString *curDescription;
    bool *finished;
}

@property (retain, nonatomic) NSURLConnection *connection;
@property (weak, nonatomic) IBOutlet UILabel *lblResult;
@property (weak, nonatomic) IBOutlet UILabel *humanText;
- (IBAction)btnGetJsonData:(id)sender;

- (IBAction)btnSendSoapMessage:(id)sender;
@end
