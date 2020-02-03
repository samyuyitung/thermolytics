const int HR_RX = 7; // digital pin 7
int ThermistorPin = A0; // analog pin 0

int id = 1;

bool sample, oldSample;
long startTime;
int ts = 5 * 1000.0;
int numBeats = 0;

int Vo;
float R1 = 10000;
float logR2, R2, T, Tc, Tf;
float c1 = 1.009249522e-03, c2 = 2.378405444e-04, c3 = 2.019202697e-07;   //what are these constant values? 


void setup() {
  Serial.begin(9600);
  pinMode (HR_RX, INPUT);  //Signal pin to input
  startTime = millis();
}

void loop() {
//  heart rate
  if (millis() - startTime > ts) {
    int bpm = numBeats * 12;
    startTime = millis();
    numBeats = 0;
    
//  skin temp
    Vo = analogRead(ThermistorPin);
    R2 = R1 * (1023.0 / (float)Vo - 1.0);
    logR2 = log(R2);
    T = (1.0 / (c1 + c2*logR2 + c3*logR2*logR2*logR2));
    Tc = T - 273.15;

// printing outputs: id,bpm,skin_temp,ambient_temp,humidity
    Serial.print(id);
    Serial.print(",");
    Serial.print(bpm);
    Serial.print(",");
    Serial.print(Tc);
    Serial.println();
  }
  
  sample = digitalRead(HR_RX); //Store signal output 
  if (oldSample == 0 && sample == 1) {
    numBeats ++;
  }
  oldSample = sample;

}

// http://www.circuitbasics.com/how-to-set-up-the-dht11-humidity-sensor-on-an-arduino/
// http://www.circuitbasics.com/arduino-thermistor-temperature-sensor-tutorial/
