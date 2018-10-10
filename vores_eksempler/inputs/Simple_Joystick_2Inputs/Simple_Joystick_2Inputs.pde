/**
 Basic demonstration of using a joystick.
 
 When this sketch runs it will try and find
 a game device that matches the configuration
 file 'joystick' if it can't match this device
 then it will present you with a list of devices
 you might try and use.
 
 The chosen device requires 2 sliders and 2 buttons.
 */

import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;

PFont f;

ControlIO control;
ControlDevice stick;
float px, py;
boolean trailOn;
boolean xOn;
boolean aOn;

ArrayList<PVector>  shadows = new ArrayList<PVector>();
ArrayList<PVector>  trail = new ArrayList<PVector>();


void setup() {
  f = createFont("Courier", 16);
  textFont(f);

  size(640, 480, P2D);
  noStroke();
  smooth();
  px = 200.0;
  py = 200.0;
  
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1",6448);
  
    // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  // Find a device that matches the configuration file
  stick = control.getMatchedDevice("joystick");
  if (stick == null) {
    println("No suitable device configured");
    System.exit(-1); // End the program NOW!
  }
  // Setup a function to trap events for this button
  stick.getButton("SHADOW").plug(this, "dropShadow", ControlIO.ON_RELEASE);
  
}

// Poll for user input called from the draw() method.
public void getUserInput() {
  px = map(stick.getSlider("X").getValue(), -1, 1, 0, width);
  py = map(stick.getSlider("Y").getValue(), -1, 1, 0, height);
  trailOn = stick.getButton("TRAIL").pressed();
  xOn = stick.getButton("SHADOW").pressed();  
}

// Event handler for the SHADOW button
public void dropShadow() {
  // Make sure we have the latest position
  getUserInput();
  shadows.add(new PVector(px, py, 40));
}


void draw() {
  //Hent controller values
  getUserInput(); // Polling
  background(0);
  fill(0, 255, 0, 255);
  noStroke();
  if(frameCount % 2 == 0) {
    sendOsc(int(px), int(py));
  }
  text("Continuously sends joystick x and y position (2 inputs) to Wekinator\nUsing message /wek/inputs, to port 6448", 10, 30);
  text("x=" + px + ", y=" + py, 10, 80);
  text("A On: " + trailOn, 10,100);
  text("B On: " + xOn, 10,120);
 
  // Show position
  noStroke();
  fill(0, 255, 0, 255);
  ellipse(px, py, 20, 20);
}

void sendOsc(int x, int y) {
  OscMessage msg = new OscMessage("/wek/inputs");
  msg.add((float)x); 
  msg.add((float)y);
  oscP5.send(msg, dest);
}
