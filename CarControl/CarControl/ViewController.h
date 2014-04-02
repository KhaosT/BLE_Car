//
//  ViewController.h
//  CarControl
//
//  Created by Khaos Tian on 9/19/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class ControllerPin;

@interface ViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>{
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    CBCharacteristic *write;
    CBCharacteristic *wb;
    ControllerPin *pin;
    BOOL isConnected;
}

- (IBAction)disconnect:(id)sender;
- (IBAction)get:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *statusimg;
@property (weak, nonatomic) IBOutlet UIButton *Disconnectbutton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *Indicator;

@end
