#include <Arduino.h>
#include <SPI.h>
#include "ble.h"

int EN1 = 6;  
int EN2 = 5; 
int IN1 = 7;
int IN2 = 4;

#define SYNC_BYTE 0xa5

#define REVERSE_BYTE 0x01

byte g_M1Val = 0;
byte g_M2Val = 0;

boolean M1Reverse = false;
boolean M2Reverse = false;

void setup() {

  for(int i=4;i<=7;i++){
    pinMode(i, OUTPUT);
  }
  // initialize the digital pin as an output.
  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.begin();
  
  ble_begin();
  
}

void Motor1(int pwm, boolean reverse){
  analogWrite(EN1,pwm); //set pwm control, 0 for stop, and 255 for maximum speed
  if(reverse){ 
    digitalWrite(IN1,HIGH);    
  }else{
    digitalWrite(IN1,LOW);
  }
}

void Motor2(int pwm, boolean reverse){
  analogWrite(EN2,pwm);
  if(reverse){
    digitalWrite(IN2,HIGH);
  }else{
    digitalWrite(IN2,LOW);
  }
}  

byte pktbuf[6];
byte bytecnt = 0;

void loop(){
  while (ble_available()){
    for (byte i=0;i < 5;i++) {
      pktbuf[i] = pktbuf[i+1];
    }
    pktbuf[5] = ble_read();
    bytecnt++;
    if ((pktbuf[0] == SYNC_BYTE) && (bytecnt == 6)) {
      byte cksum = pktbuf[1] ^ pktbuf[2] ^ pktbuf[3] ^ pktbuf[4];
      if (cksum == pktbuf[5]) {
        g_M1Val =  pktbuf[1];
        g_M2Val =  pktbuf[2];
        if(pktbuf[3] == REVERSE_BYTE){
          M1Reverse = true;
        }else{
          M1Reverse = false;
        }
        if(pktbuf[4] == REVERSE_BYTE){
          M2Reverse = true;
        }else{
          M2Reverse = false;
        }
        Motor1(g_M1Val,M1Reverse);
        Motor2(g_M2Val,M2Reverse);
        bytecnt = 0;
      }
    }
  }
  
  ble_do_events();
}
