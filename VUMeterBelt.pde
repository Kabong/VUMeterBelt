#include "LPD8806.h"
#include "SPI.h"
#define NUMBER_OF_SAMPLES 15

/*
BONNAROO BELT v1.0

This program reads the analog signal from a Inex Robotics ZX-SOUND microphone
module, cleans it up a bit and then turns the signal into an output for a
programmable LED belt kit from Adafruit. Essentially, it turns a volume level
reading into a VU meter style output for the LED belt. Awesome, right?

ZX-Sound sensor:
ttp://www.inexglobal.com/products.php?type=addon&cat=sensors&model=zxsound

Programmable LED belt kit:
http://www.adafruit.com/products/332
*/ 

// These are the pins used to communicate with the LED belt. On a deumilanove
// you use dataPin = 11 and clockPin = 13, but as you can see below they're 
// reversed because I'm a donkey and soldered them backwards.
int dataPin = 13;
int clockPin = 11;

// Set the first variable to the NUMBER of pixels. 32 = 32 pixels in a row
// The LED strips are 32 LEDs per meter but you can extend/cut the strip
LPD8806 strip = LPD8806(32, dataPin, clockPin);

// Initialize our variables!
int sensorPin = A0;   // select the input pin for the potentiometer
int ledPin = 13;      // select the pin for the LED
int sensorValue = 0;  // variable to store the value coming from the sensor
uint32_t color;
int i,b,c,j;
int samples[NUMBER_OF_SAMPLES] = {0};
int sample = 0;
int sampleTotal=0;
byte sampleIndex=0;
int loopCounter=0;

void setup() {
  // Initialize the LED belt
  strip.begin();
  strip.show();
}

void awesomeBeltLights(uint32_t c, uint8_t level);
uint32_t Wheel(uint16_t WheelPos);

void loop() {
  // read the value from the sensor:
  sensorValue = analogRead(sensorPin);    

  // This modulus check controls how fast the color of the LEDs
  // is changed. Increase to slow the color change down, decrease
  // to speed it up.
  if(loopCounter % 100 == 0) {
     c++;
     if(c%32 == 0) {
       b++;
       c=0;
     }
     if(b==1920) {
       b=0;
       c=0;
     }
     // Set the color of the LEDs using the Adafruit Wheel function
     color = Wheel(((c * 384 / 32) + b) % 384);
  }

  // This bit of code smooths the analog input out so it's not too erratic
  sampleTotal -= samples[sampleIndex];
  samples[sampleIndex] = sensorValue;
  sampleTotal += samples[sampleIndex++];
  if(sampleIndex >= NUMBER_OF_SAMPLES) { sampleIndex = 0; }
  sample = sampleTotal / NUMBER_OF_SAMPLES;
  
  // We've got a normalized input value at this point, let's turn lights on!
  awesomeBeltLights(color,sample);

  // Turn the LEDs off when we're done, otherwise the VU meter will always
  // stay at the highest level
  for(i=0; i<32; i++){
    strip.setPixelColor(i,strip.Color(0,0,0));
  }

  // Increment our loop counter
  loopCounter++;
}

/* 
This custom function handles the logic to turn the LEDs on.
*/ 
void awesomeBeltLights(uint32_t c, uint8_t level) {
  // We need a temporary variable to store the adjusted volume level
  int adjustedLevel=0;

  // The raw reading from the microphone sensor is very sensitive
  // so we need to reduce the sensitivity down by some factor (5 below) and then
  // ignore ambient noise (the -5 at the end)
  adjustedLevel = (level/5)-5;

  // The VU meter is split into equal sections and if your belt is 32 LEDs long, then
  // each half gets 16 LEDS (0-15 or 16-32). If the reading is over 15, the volume is
  // at max level, so just truncate it so the loop doesn't run forever
  if(adjustedLevel > 15) {     
    adjustedLevel = 15;
  }
  
  // Now that we have a usable volume level, loop through the LEDs and set them on or off 
  for(j=0; j<adjustedLevel; j++){
    strip.setPixelColor( (j+16) ,c);
    strip.setPixelColor( (15-j) ,c);
  }
  // Now that we've set the LED colors to be displayed, turn them on
  strip.show();
}

/* 
This function was provided by Adafruit in the LED belt example code and is
unmodified.
*/
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
