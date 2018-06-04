/**
 * REALLY simple processing sketch for using webcam input
 * This sends 100 input values to port 6448 using message /wek/inputs
 **/

import processing.video.*;
import oscP5.*;
import netP5.*;

PImage webImg;
String url = "http://87.59.28.70/record/current.jpg?rand=0.3371342047624182";


int numPixelsOrig;
int numPixels;
boolean first = true;

int boxWidth = 64;
int boxHeight = 48;

int numHoriz = 640/boxWidth;
int numVert = 480/boxHeight;

color[] downPix = new color[numHoriz * numVert];


Capture video;

OscP5 oscP5;
NetAddress dest;

void setup() {
  // colorMode(HSB);
  size(640, 480, P2D);
  //frameRate(10);





  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("192.168.8.102", 6448);
  webImg = loadImage(url, "png");
}

void draw() {
  if(frameCount % 10 == 0){
    webImg = loadImage(url, "png");
  }
    image(webImg, 0, 0);
    numPixelsOrig = webImg.width * webImg.height;
    loadPixels();
    noStroke();

  webImg.loadPixels(); // Make the pixels of video available
  /*for (int i = 0; i < numPixels; i++) {
   int x = i % video.width;
   int y = i / video.width;
   float xscl = (float) width / (float) video.width;
   float yscl = (float) height / (float) video.height;
   
   float gradient = diff(i, -1) + diff(i, +1) + diff(i, -video.width) + diff(i, video.width);
   fill(color(gradient, gradient, gradient));
   rect(x * xscl, y * yscl, xscl, yscl);
   } */
  int boxNum = 0;
  int tot = boxWidth*boxHeight;
  for (int x = 0; x < 640; x += boxWidth) {
    for (int y = 0; y < 480; y += boxHeight) {
      float red = 0, green = 0, blue = 0;

      for (int i = 0; i < boxWidth; i++) {
        for (int j = 0; j < boxHeight; j++) {
          int index = (x + i) + (y + j) * 640;
          red += red(webImg.pixels[index]);
          green += green(webImg.pixels[index]);
          blue += blue(webImg.pixels[index]);
        }
      }
      downPix[boxNum] =  color(red/tot, green/tot, blue/tot);
      // downPix[boxNum] = color((float)red/tot, (float)green/tot, (float)blue/tot);
      fill(downPix[boxNum]);

      int index = x + 640*y;
      red += red(webImg.pixels[index]);
      green += green(webImg.pixels[index]);
      blue += blue(webImg.pixels[index]);
      // fill (color(red, green, blue));
      rect(x, y, boxWidth, boxHeight);
      boxNum++;
      /* if (first) {
       println(boxNum);
       } */
    }
    sendOsc(downPix);
    first = false;
    fill(0);
    text("Sending 100 inputs to port 6448 using message /wek/inputs", 10, 10);
  }
}

  float diff(int p, int off) {
    if (p + off < 0 || p + off >= numPixels)
      return 0;
      return red(webImg.pixels[p+off]) - red(webImg.pixels[p]) +
      green(webImg.pixels[p+off]) - green(webImg.pixels[p]) +
      blue(webImg.pixels[p+off]) - blue(webImg.pixels[p]);
  }

  void sendOsc(int[] px) {
    OscMessage msg = new OscMessage("/wek/inputs");
    // msg.add(px);
    for (int i = 0; i < px.length; i++) {
      msg.add(float(px[i]));
    }
    oscP5.send(msg, dest);
  }