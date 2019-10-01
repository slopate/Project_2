void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(34,INPUT);
  pinMode(35,INPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  float x = analogRead(35);
  float y = analogRead(34);

  
  Serial.print("x: " + String(x) + " y: " + String(y) + "\n");
}
