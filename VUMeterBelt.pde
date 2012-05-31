#include "LPD8806.h"
#include "SPI.h"
#define NUMBER_OF_SAMPLES 15
/*
  Analog Input
 Demonstrates analog input by reading an analog sensor on analog pin 0 and
 turning on and off a light emitting diode(LED)  connected to digital pin 13. 
 The amount of time the LED will be on and off depends on
 the value obtained by analogRead(). 
 
 The circuit:
 * Potentiometer attached to analog input 0
 * center pin of the potentiometer to the analog pin
 * one side pin (either one) to ground
 * the other side pin to +5V
 * LED anode (long leg) attached to digital output 13
 * LED cathode (short leg) attached to ground
 
 * Note: because most Arduinos have a built-in LED attached 
 to pin 13 on the board, the LED is optional.
 
 
 Created by David Cuartielles
 Modified 4 Sep 2010
 By Tom Igoe
 
 This example code is in the public domain.
 
 http://arduino.cc/en/Tutorial/AnalogInput
 
 */
/*****************************************************************************/

//#if defined(USB_SERIAL) || defined(USB_SERIAL_ADAFRUIT)
// this is for teensyduino support
int dataPin = 2;
int clockPin = 1;
//#else 
// these are the pins we use for the LED belt kit using
// the Leonardo pinouts
//int dataPin = 16;
//int clockPin = 15;
//#endif

// Set the first variable to the NUMBER of pixels. 32 = 32 pixels in a row
// The LED strips are 32 LEDs per meter but you can extend/cut the strip
LPD8806 strip = LPD8806(32, dataPin, clockPin);



int sensorPin = A0;   // select the input pin for the potentiometer
int ledPin = 13;      // select the pin for the LED
int sensorValue = 0;  // variable to store the value coming from the sensor
uint32_t color;
int i,b,c;
int samples[NUMBER_OF_SAMPLES] = {0};
int sample = 0;
int sampleTotal=0;
byte sampleIndex=0;
int loopCounter=0;


void setup() {
  strip.begin();
  strip.show();
  // declare the ledPin as an OUTPUT:
  //pinMode(ledPin, OUTPUT);  
  //Serial.begin(9600);
  //Serial.println("begin test");
  
}

void testFunction(uint32_t c, uint8_t level);
void rainbowCycle(uint8_t level);
uint32_t Wheel(uint16_t WheelPos);

void loop() {
  // read the value from the sensor:
  sensorValue = analogRead(sensorPin);    
  //  Serial.println(sensorValue);  
  //digitalWrite(ledPin, HIGH);

//  if(sensorValue>80) { 
//  if(loopCounter < 1000 ) {
//    color = strip.Color(255,0,0);
//  }
//  else if (loopCounter >= 1000 && loopCounter < 2000) {
//    color = strip.Color(0,255,0);
//  }
//  else if (loopCounter >= 2000 && loopCounter < 3000) {
//    color = strip.Color(0,0,255);
//  }
//  }
//  }    
//  else {
//    color = strip.Color(0,0,0);
  //for(b=0;b<384*5;b++) {
   if(loopCounter % 10 == 0) {
      c++;
     if(c%32 == 0) {
       b++;
       c=0;
     }
     if(b==1920) {
       b=0;
       c=0;
     }

        color = Wheel(((c * 384 / 32) + b) % 384);
  }

  sampleTotal -= samples[sampleIndex];
  samples[sampleIndex] = sensorValue;
  sampleTotal += samples[sampleIndex++];
  if(sampleIndex >= NUMBER_OF_SAMPLES) { sampleIndex = 0; }
  sample = sampleTotal / NUMBER_OF_SAMPLES;
  testFunction(color,sample);
  //rainbowCycle(sample);
//  delay(20);
  for(i=0; i<32; i++){
    strip.setPixelColor(i,strip.Color(0,0,0));
  }

  loopCounter++;
}

void testFunction(uint32_t c, uint8_t level) {
  int temp=0;
  temp = (level-7);
  //if(level > 32) {
  //  level = 32;
  //}
  int j; 
  for(j=0; j<temp; j++){
    strip.setPixelColor(j,c);
  }
  strip.show();
  //delay(wait);
}

// Cycle through the color wheel, equally spaced around the belt
void rainbowCycle(uint8_t level) {
  int z=0;
  uint16_t y;
  int temp1=0;
  int wheelPos=0;
  uint16_t wheelVal = 0;
  
  temp1 = (level-7);


    for (z=0; z < temp1; z++) {
//      for (y=0; y < 384 * 5; y++) {     // 5 cycles of all 384 colors in the wheel
      // tricky math! we use each pixel as a fraction of the full 384-color
      // wheel (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 384 is to make the wheel cycle around
      wheelPos = random(0, 1920);
      //wheelVal = Wheel(384 / temp1);
      wheelVal = Wheel(((z * 384 / 32 ) + wheelPos )% 384);
      //((384 / temp1) + wheelPos) % 384)
      strip.setPixelColor(z, wheelVal);
    }
    strip.show();   // write all the pixels out
//    delay(wait);
//}
}

uint32_t Wheel(uint16_t WheelPos)
{
  byte r, g, b;
  switch(WheelPos / 128)
  {
    case 0:
      r = 127 - WheelPos % 128; // red down
      g = WheelPos % 128;       // green up
      b = 0;                    // blue off
      break;
    case 1:
      g = 127 - WheelPos % 128; // green down
      b = WheelPos % 128;       // blue up
      r = 0;                    // red off
      break;
    case 2:
      b = 127 - WheelPos % 128; // blue down
      r = WheelPos % 128;       // red up
      g = 0;                    // green off
      break;
  }
  return(strip.Color(r,g,b));
}
