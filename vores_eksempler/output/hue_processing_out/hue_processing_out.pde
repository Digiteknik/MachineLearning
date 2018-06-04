import processing.net.*;
import controlP5.*;

String apiKey = "C2fr-2XtwFq3Z7G3Xk4XftfEq48pY0oxXaYMJcU4"; //developer name used when setting up bridge
String light = "1"; //the light # you want to control
String bridgeIp = "192.168.8.109";
String data;
Client c;
boolean on;

void setup() {
  size(700, 400);
  background(50);
  c = new Client(this, bridgeIp, 80); // Connect to server on port 80
  c.write("PUT /api/" + apiKey +"/lights/" + light + "/state HTTP/1.1\r\n"); 
  c.write("Content-Length: " + 180 + "\r\n\r\n");
  c.write("{\"on\":true}");
  c.write("\r\n");  
  c.stop();  
}

void draw() {  
  if (c.available() > 0) {
    data = c.readString(); // ...then grab it and print it
    println(data);
  }
}

void mouseReleased(){
  on = !on;
  c = new Client(this, bridgeIp, 80); // Connect to server on port 80
  c.write("PUT /api/" + apiKey +"/lights/" + light + "/state HTTP/1.1\r\n"); 
  c.write("Content-Length: " + 180 + "\r\n\r\n");
  //c.write("{\"bri\":" + 50 +"}\r\n");
  c.write("{\"bri\":" + floor(map(mouseX,0,width,0,255)) + "}");  
  //c.write("{\"on\":" + (on?"true":"false") + "}");
  c.write("\r\n");
  c.stop();
   
}