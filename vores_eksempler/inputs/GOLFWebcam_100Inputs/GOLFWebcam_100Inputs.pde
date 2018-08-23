/**
 * REALLY simple processing sketch for using webcam input
 * This sends 100 input values to port 6448 using message /wek/inputs
 **/

import processing.video.*;
import oscP5.*;
import netP5.*;

PImage webImg;
String url = "http://87.59.28.70/record/current.jpg?rand=0.3371342047624182";
int numPixels;
boolean first = true;

int imageWidth = 640;
int imageHeight = 480;

int boxWidth = 64;
int boxHeight = 48;

int numHoriz;
int numVert;

PImage img;

color[] downPix;

OscP5 oscP5;
NetAddress dest;

void setup() {
  size(640, 480);

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("127.0.0.1", 6448);

  webImg = loadImage(url, "jpg");

  numHoriz = webImg.width/boxWidth;
  numVert = webImg.height/boxHeight;

  downPix = new color[numHoriz * numVert];
  img = loadImage("tgornik_floating.png");
}

void draw() {
  if (frameCount % 10 == 0) {
    webImg = loadImage(url, "jpg");
  }
  image(webImg, 0, 0);
  loadPixels();
  noStroke();
  image(img, mouseX, mouseY, 200,200);
  

  webImg.loadPixels(); // Make the pixels of webcam available
  int boxNum = 0;
  int tot = boxWidth*boxHeight;
  for (int x = 0; x < webImg.width; x += boxWidth) {
    for (int y = 0; y < webImg.height; y += boxHeight) {
      float red = 0, green = 0, blue = 0;

      for (int i = 0; i < boxWidth; i++) {
        for (int j = 0; j < boxHeight; j++) {
          int index = (x + i) + (y + j) * webImg.width;
          red += red(webImg.pixels[index]);
          green += green(webImg.pixels[index]);
          blue += blue(webImg.pixels[index]);
        }
      }
      downPix[boxNum] =  color(red/tot, green/tot, blue/tot);
      // downPix[boxNum] = color((float)red/tot, (float)green/tot, (float)blue/tot);
      fill(downPix[boxNum], 64);

      int index = x + webImg.width * y;
      red += red(webImg.pixels[index]);
      green += green(webImg.pixels[index]);
      blue += blue(webImg.pixels[index]);
      // fill (color(red, green, blue));
      rect(x, y, boxWidth, boxHeight);
      boxNum++;
    }
    sendOsc(downPix);
    first = false;
    fill(200);
    textSize(24);
    text("Sending 100 inputs to port 6448 using message", 20, height-20);
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