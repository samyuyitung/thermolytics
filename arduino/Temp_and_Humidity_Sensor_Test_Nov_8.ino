#include <dht.h> //need to download library from: http://www.circuitbasics.com/how-to-set-up-the-dht11-humidity-sensor-on-an-arduino/

dht DHT;

int DHT11_PIN = 7;

void setup(){
  Serial.begin(9600);
}

void loop(){
  int chk = DHT.read11(DHT11_PIN);
  Serial.print("Temp: ");
  Serial.print(DHT.temperature);
  Serial.println("C");
  Serial.print("Humidity: ");
  Serial.print(DHT.humidity);
  Serial.println("%");
  delay(1000);
}

