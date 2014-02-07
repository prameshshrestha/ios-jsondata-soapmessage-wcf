//
//  ViewController.m
//  WcfClient
//
//  Created by pramesh on 1/7/14.
//  Copyright (c) 2014 pramesh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSString *errorMessage;
    NSDictionary *trackInfo;
    NSMutableArray *name;
    NSMutableDictionary *dict;
    NSArray *temp;
    NSString *keey;
    NSString *knownString;
}
@end

//#define WcfServiceURL [NSURL URLWithString:@"http://192.168.2.25/Service1.svc/json/trackingpoints"];

@implementation ViewController
@synthesize connection, lblResult, humanText;
// wcf url

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)valueChanged:(UISegmentedControl *)segment
{
    if (segment.selectedSegmentIndex == 0)
    {
        knownString = [name objectAtIndex:0];
        temp = [dict allKeysForObject:knownString];
        keey = [temp lastObject];
        lblResult.text = [NSString stringWithFormat:@" %@ ", keey];
        
    }
    else if (segment.selectedSegmentIndex == 1)
    {
        knownString = [name objectAtIndex:1];
        temp = [dict allKeysForObject:knownString];
        keey = [temp lastObject];
        lblResult.text = [NSString stringWithFormat:@" %@ ", keey];
    }
    else if (segment.selectedSegmentIndex == 2)
    {
        knownString = [name objectAtIndex:2];
        temp = [dict allKeysForObject:knownString];
        keey = [temp lastObject];
        lblResult.text = [NSString stringWithFormat:@" %@ ", keey];
    }
    else if (segment.selectedSegmentIndex == 3)
    {
        knownString = [name objectAtIndex:3];
        temp = [dict allKeysForObject:knownString];
        keey = [temp lastObject];
        lblResult.text = [NSString stringWithFormat:@" %@ ", keey];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_responseData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
    NSString *strData = [[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", strData);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   NSLog(@"%@", error);
     errorMessage = [error localizedDescription];
    lblResult.text = errorMessage;
    //inform the user
    UIAlertView *didFailWithErrorMessage = [[UIAlertView alloc]initWithTitle:@"NSURLConnection" message:@"didFailWithError" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [didFailWithErrorMessage show];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"DONE. Received Bytes: %d", [_responseData length]);
    NSString *theXML = [[NSString alloc] initWithBytes: [_responseData mutableBytes] length:[_responseData length] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",theXML);
    
    NSData *myData = [theXML dataUsingEncoding:NSUTF8StringEncoding];
    xmlParser = [[NSXMLParser alloc]initWithData:myData];
    xmlParser.delegate = self;
    bool parsingResult = [xmlParser parse];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName
   attributes:(NSDictionary *)attributeDict
{
    NSString *currentDescription = [NSString alloc];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    curDescription = string;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName
{
    if([elementName isEqual:@"InsertTicketDetailsResult"])
        lblResult.text = curDescription;
}

- (IBAction)btnGetJsonData:(id)sender {
    
    NSURL *restUrl = [NSURL URLWithString:@"http://192.168.2.25:81/RoomService.svc/json/trackingpoints"];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:restUrl options:NSDataReadingUncached error:&error];
    if(!error)
    {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSMutableArray *array = [json objectForKey:@"GetAllTrackingPointsResult"];
        
        dict = [[NSMutableDictionary alloc]init];
        for (int i = 0; i < array.count; i++)
        {
            trackInfo = [array objectAtIndex:i];
            NSString *ttype = [trackInfo objectForKey:@"TType"];
            NSString *tname = [trackInfo objectForKey:@"TName"];
            [dict setValue:tname forKey:ttype];
        }
        name = [[NSMutableArray alloc]init];
        for (id key in dict)
        {
            id value = [dict objectForKey:key];
            [name addObject:value];
        }
        
        UISegmentedControl *control = [[UISegmentedControl alloc]initWithItems:name];
        control.frame = CGRectMake(0, 100, 320, 40);
        [control addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:control];
    }
    else
    {
        humanText.text = @"Cannot connect to server";
    }
}

- (IBAction)btnSendSoapMessage:(id)sender {
    // soap request
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<InsertTicketDetails xmlns=\"http://tempuri.org/\">\n"
                             "<scanpt>11</scanpt><barcode>907014118496</barcode>"
                             "</InsertTicketDetails>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n"
                             ];
    NSURL *url = [NSURL URLWithString:@"http://192.168.2.25:81/RoomService.svc"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:@"http://tempuri.org/IRoomService/InsertTicketDetails" forHTTPHeaderField:@"soapaction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc]initWithRequest:theRequest delegate:self];
    if (theConnection)
    {
        _responseData = [NSMutableData alloc];
    }
    else
    {
        NSLog(@"Cannot connect to the service");
    }
    //while(!finished)
    //{
    //  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    //}
    [NSThread isMainThread];
    //dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_get_main_queue() == dispatch_get_current_queue();
}
@end
