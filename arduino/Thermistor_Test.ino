int ThermistorPin = 0; // analog pin 0
int Vo;
float R1 = 10000;
float logR2, R2, T, Tc, Tf;
float c1 = 1.009249522e-03, c2 = 2.378405444e-04, c3 = 2.019202697e-07;   //what are these constant values? 

void setup() {
Serial.begin(9600);
}

void loop() {

  Vo = analogRead(ThermistorPin);
  Serial.print("the voltage is: ");
  Serial.println(Vo);
  R2 = R1 * (1023.0 / (float)Vo - 1.0);
  logR2 = log(R2);
  T = (1.0 / (c1 + c2*logR2 + c3*logR2*logR2*logR2));
  Tc = T - 273.15;

  Serial.print("Temperature: ");
  Serial.print(Tc);
  Serial.println(" C");   

  delay(500);
}

// http://www.circuitbasics.com/arduino-thermistor-temperature-sensor-tutorial/
