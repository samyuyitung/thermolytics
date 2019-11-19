//Definitions
const int HR_RX = 7; // digital pin 7
bool sample, oldSample;

long startTime;

int ts = 10 * 1000;
int numBeats = 0;
void setup() {
  Serial.begin(9600);
  pinMode (HR_RX, INPUT);  //Signal pin to input
  startTime = millis();
}

void loop() {
  if (millis() - startTime > ts) {
    int bpm = numBeats * 6;
    Serial.println();
    Serial.print("num beats: ");
    Serial.println(bpm);
    startTime = millis();
    numBeats = 0;
  }
  
  sample = digitalRead(HR_RX); //Store signal output 
  if (oldSample == 0 && sample == 1) {
    Serial.print("beat ");
    numBeats ++;
  }
  oldSample = sample;
}
