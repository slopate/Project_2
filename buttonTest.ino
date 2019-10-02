//#include <SimpleMessageSystem.h>


int buttonPinR = 27;
int buttonPinL = 14;
int buttonValR = 0;
int buttonValL = 0;


int joystickXR = 34;
int joystickYR = 35;
int joystickXL = 32;
int joystickYL = 33;
int stickValXR = 0;
int stickValYR = 0;
int stickValXL = 0;
int stickValYL = 0;


int switchPinR = 25;
int switchPinL = 13;
int switchValR = 0;
int switchValL = 0;


void setup() {
  // put your setup code here, to run once:
  pinMode(buttonPinR, INPUT_PULLUP);
  pinMode(buttonPinL, INPUT_PULLUP);
  pinMode(switchPinR, INPUT_PULLUP);
  pinMode(switchPinL, INPUT_PULLUP);

  pinMode(joystickXR, INPUT);
  pinMode(joystickXL, INPUT);
  pinMode(joystickYR, INPUT);
  pinMode(joystickYL, INPUT);
  
  Serial.begin(9600);
  //delay(1000);
  
}

void loop() {
  // put your main code here, to run repeatedly:
  buttonValR = digitalRead(buttonPinR);
  buttonValL = digitalRead(buttonPinL);
  
  switchValR = digitalRead(switchPinR);
  switchValL = digitalRead(switchPinL);
  //Serial.println(val);
  //Serial.println(buttonVal);

  if(digitalRead(buttonPinR) == LOW){
    delay(10);
    if(digitalRead(buttonPinR) == LOW){
      buttonValR = 1;
    }
    else{
      buttonValR = 0;
    }
  }
  else{
    buttonValR = 0;
  }

  if(digitalRead(buttonPinL) == LOW){
    delay(10);
    if(digitalRead(buttonPinL) == LOW){
      buttonValL = 1;
    }
    else{
      buttonValL = 0;
    }
  }
  else{
    buttonValL = 0;
  }
  
  stickValXR = analogRead(joystickXR);
  stickValXL = analogRead(joystickXL);
  stickValYR = analogRead(joystickYR);
  stickValYL = analogRead(joystickYL);

  Serial.println(String(stickValXR) + " " + String(stickValYR) + " " + String(buttonValR) + " " + String(switchValR) + " " + String(stickValXL) + " " + String(stickValYL) + " " + String(buttonValL) + " " + String(switchValL));
}
