
int buttonPin = 21;
int switchPin = 22;
int joystickX = 35;
int joystickY = 34;
int buttonVal = 0;
int switchVal = 0;
int stickValX = 0;
int stickValY = 0;

void setup() {
  // put your setup code here, to run once:
  pinMode(buttonPin, INPUT_PULLUP);
  pinMode(switchPin, INPUT_PULLUP);

  pinMode(joystickX, INPUT);
  pinMode(joystickY, INPUT);
 //digitalWrite(switchPin, HIGH);
  Serial.begin(9600);

 // digitalWrite(joystickX, HIGH);
  
}

void loop() {
  // put your main code here, to run repeatedly:
  buttonVal = digitalRead(buttonPin);
 // switchVal = digitalRead(switchPin);
  //Serial.println(val);
  //Serial.println(buttonVal);

  stickValX = analogRead(joystickX);
  delay(100);
  stickValY = analogRead(joystickY);

  Serial.println(String(stickValX) + " " + String(stickValY));
}
