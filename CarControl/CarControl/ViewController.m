//
//  ViewController.m
//  CarControl
//
//  Created by Khaos Tian on 9/19/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import "ViewController.h"
#import "ControllerBG.h"
#import "ControllerPin.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    isConnected = NO;
    [super viewDidLoad];
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    ControllerBG *BG = [[ControllerBG alloc]initWithFrame:CGRectMake(25, 100, 270, 270)];
    BG.backgroundColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0];
    
    [self.view addSubview:BG];
    
    pin = [[ControllerPin alloc]initWithFrame:CGRectMake(110, 190, 100, 100)];
    pin.backgroundColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0];
    [self.view addSubview:pin];
    // Do any additional setup after loading the view, typically from a nib.
}

#define SYNC_BYTE 0xa5
#define REVERSE_BYTE 0x01

- (void)sendWithPower1:(int)power1 Power2:(int)power2 Reverse1:(BOOL)reverse1 Reverse2:(BOOL)reverse2{
    UInt8 pktbuf[6];
    pktbuf[0] = SYNC_BYTE;
    pktbuf[1] = power1;
    pktbuf[2] = power2;
    if (reverse1) {
        pktbuf[3] = REVERSE_BYTE;
    }else{
        pktbuf[3] = 0x05;
    }
    if (reverse2) {
        pktbuf[4] = REVERSE_BYTE;
    }else{
        pktbuf[4] = 0x05;
    }
    pktbuf[5] = pktbuf[1] ^ pktbuf[2] ^ pktbuf[3] ^ pktbuf[4];
    NSData *data = [[NSData alloc] initWithBytes:pktbuf length:6];
    [peripheral writeValue:data forCharacteristic:write type:CBCharacteristicWriteWithoutResponse];
}

CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2)
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
};

CGPoint PositionIfOverRADIUS(CGPoint point1,CGPoint point2){
    CGPoint v = CGPointMake(point1.x-point2.x, point1.y-point2.y);
    CGPoint v1 = CGPointMake(-1*v.x*(1.0f/sqrtf(v.x*v.x+v.y*v.y)),-1*v.y*(1.0f/sqrtf(v.x*v.x+v.y*v.y)));
    return v1;
}

CGPoint originalLocation;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!isConnected) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection Required" message:@"To function well, you will need to connect to BLE Shield." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
        [self touchesMoved:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (isConnected) {
        UITouch *touch = [touches anyObject];
        CGPoint currentLocation = [touch locationInView:self.view];
        CGRect frame = pin.frame;
        CGFloat distance = DistanceBetweenTwoPoints(CGPointMake(160.0f, 235.0f),currentLocation);
        CGPoint rate = PositionIfOverRADIUS(CGPointMake(160.0f, 235.0f),currentLocation);
        if (distance>125) {
            frame.origin = CGPointMake(rate.x*125.0f+110.0f, rate.y*125.0f+190.0f);
        }else{
            frame.origin.x = currentLocation.x-50;
            frame.origin.y = currentLocation.y-50;
        }
        pin.frame = frame;
        if (rate.y < 0) {
            if (rate.x > 0) {
                if (rate.x>0.5) {
                    [self sendWithPower1:62.5 Power2:125 Reverse1:NO Reverse2:NO];
                }else{
                    float mainspeed=255*(1-rate.x);
                    if(mainspeed>255){
                        mainspeed = 255;
                    }
                    [self sendWithPower1:mainspeed*(1-rate.x) Power2:mainspeed Reverse1:NO Reverse2:NO];
                }
            }else{
                if (rate.x<-0.5) {
                    [self sendWithPower1:125 Power2:62.5 Reverse1:NO Reverse2:NO];
                }else{
                    float mainspeed=255*(1+rate.x);
                    if(mainspeed>255){
                        mainspeed = 255;
                    }
                    [self sendWithPower1:mainspeed Power2:mainspeed*(1+rate.x) Reverse1:NO Reverse2:NO];
                }
            }
        }else{
            if (rate.x > 0) {
                if (rate.x>0.5) {
                    [self sendWithPower1:62.5 Power2:125 Reverse1:YES Reverse2:YES];
                }else{
                    float mainspeed=255*(1-rate.x);
                    if(mainspeed>255){
                        mainspeed = 255;
                    }
                    [self sendWithPower1:mainspeed*(1-rate.x) Power2:mainspeed Reverse1:YES Reverse2:YES];
                }
            }else{
                if (rate.x<-0.5) {
                    [self sendWithPower1:125 Power2:62.5 Reverse1:YES Reverse2:YES];
                }else{
                    float mainspeed=255*(1+rate.x);
                    if(mainspeed>255){
                        mainspeed = 255;
                    }
                    [self sendWithPower1:mainspeed Power2:mainspeed*(1+rate.x) Reverse1:YES Reverse2:YES];
                }
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (isConnected) {
        [self sendWithPower1:0 Power2:0 Reverse1:NO Reverse2:NO];
        [UIView beginAnimations:@"MoveView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.2f];
        pin.frame = CGRectMake(110, 190, 100, 100);
        [UIView commitAnimations];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (manager.state == CBCentralManagerStatePoweredOn) {
        _Disconnectbutton.enabled = YES;
    }
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"%@",[advertisementData description]);
    [central stopScan];
    peripheral = aPeripheral;
    [central connectPeripheral:peripheral options:nil];
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Failed:%@",error);
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"Connected:%@",aPeripheral.UUID);
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    _statusimg.image = [UIImage imageNamed:@"status_offline.png"];
    isConnected = NO;
    _Disconnectbutton.enabled = YES;
    [_Disconnectbutton setTitle:@"Connect" forState:UIControlStateNormal];
    _Disconnectbutton.hidden = NO;
    _Disconnectbutton.tag = 1;
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services){
        //if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"0A12"]]) {
        [aPeripheral discoverCharacteristics:nil forService:aService];
        //}
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics){
        
        //Write
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"713D0003-503E-4C75-BA94-3148F18D941E"]]) {
            write = aChar;
            isConnected = YES;
            [_Indicator stopAnimating];
            _Disconnectbutton.tag = 0;
            _Disconnectbutton.enabled = YES;
            [_Disconnectbutton setTitle:@"Disconnect" forState:UIControlStateNormal];
            _Disconnectbutton.hidden = NO;
            _statusimg.image = [UIImage imageNamed:@"status_online.png"];
        }
        
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"713D0004-503E-4C75-BA94-3148F18D941E"]]) {
            wb = aChar;
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"713D0002-503E-4C75-BA94-3148F18D941E"]]) {
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)disconnect:(UIButton *)sender {
    if (sender.tag == 1) {
        [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"713D0000-503E-4C75-BA94-3148F18D941E"]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES] }];
        [_Indicator startAnimating];
        _Disconnectbutton.enabled = NO;
        _Disconnectbutton.hidden = YES;
    }else{
        [manager cancelPeripheralConnection:peripheral];
        _Disconnectbutton.enabled = NO;
        _Disconnectbutton.hidden = YES;
    }
}

//Workaround for disconnect doesn't happens immediately
- (IBAction)get:(id)sender {
    [manager retrieveConnectedPeripherals];
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    for (CBPeripheral *peripheralA in peripherals) {
        peripheral = peripheralA;
        [manager connectPeripheral:peripheralA options:nil];
    }
}
@end
