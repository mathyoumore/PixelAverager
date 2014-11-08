// Authored by Mathyoumore

PImage mrk; 
PGraphics hMean, vMean, gMean;
int frame = 1;
float maxFrame = 1456; //Numerical value of highest frame
float infidelity = 3; //Skipped frames, change with great care

int fts = ceil(maxFrame/infidelity); //Frames to scan
int fw = 1280; //Frame Width
int fh = 720; //Frame height
int r, g, b =0;
int[] rS = new int[fw*fh], gS = new int[fw*fh], bS = new int[fw*fh]; //Holds the summed r,g,and b values for global mean

float t=0;
void setup() {
  hMean = createGraphics(fts, fh);
  vMean = createGraphics(fw, fts);
  gMean = createGraphics(fw, fh);
  size(400, 80);
  rectMode(CORNERS);
  noStroke();
}

void draw() {
  if (frame < maxFrame)
  {
    if (frame == 1)
    {
      t = millis();
    }
    
    if ((frame/3.0)%30 <= 3)
    {
     println(frame/3 + " frames processed. " + (millis()/(frame/3.0)) + " millis per frame."+
    "\n" + (((maxFrame/3.0)-(frame/3.0)) * (millis()/(frame/3.0)))/1000 + " seconds remaining. Maybe." );
    }
    //Progress bar

    fill(0, 200, 0);
    rect(0, 0, (frame/maxFrame)*width, height);

    hMean.beginDraw();
    vMean.beginDraw();

    hMean.noStroke();
    vMean.noStroke();

    color c = 0;

    float chunk = 1;      //Size of the bars, should be <= infidelity
    float chunkidelity = (chunk/infidelity);

    fill(0, 200, 00);
    rect(0, 0, (frame/maxFrame), height);
    String im = "scene";
    if (frame < 10000)
    {
      im += "0";
      if (frame < 1000)
      {
        im += "0";
      }
      if (frame < 100)
      {
        im += "0";
      }
      if (frame < 10)
      {
        im += "0";
      }
    }
    im += frame + ".png";
    mrk = loadImage(im);
    if (mrk.height != -1 && mrk.width != -1) 
    {//Is the image a valid image
      mrk.loadPixels();
      //println(mrk.width + " x " + mrk.height);
      for (int x = 1; x<fw; x++)
      {
        c = vertPixelsMean(x);
        vMean.fill(c);
        vMean.rect(x, frame/infidelity, x+1, (frame/infidelity)+1);
      }

      for (int y = 1; y<fh; y++)
      {
        c = horzPixelsMean(y);
        hMean.fill(c);
        hMean.rect(frame/infidelity, y, frame/infidelity+1, y+1);
      }

      for (int p = 0; p < mrk.width*mrk.height; p++)
      {
        globalMean(p);
      }
    }

    frame+=infidelity;
  } else 
  {
    vMean.save("v.png");
    hMean.save("h.png");
    vMean.endDraw();
    hMean.endDraw();

    gMean.beginDraw();
    for (int p = 0; p < mrk.width * mrk.height; p++)
    {
      rS[p] = floor(rS[p]/fts);
      gS[p] = floor(gS[p]/fts);
      bS[p] = floor(bS[p]/fts);
//      if (p == 0)
//      {
//        println("rS[p]: " + rS[p] + " gS[p]: " + gS[p] + " bS[p]: " + bS[p]);
//      }
      gMean.set(p % fw, p / fw, color(rS[p], gS[p], bS[p]));
    }

    gMean.save("g.png");
    gMean.endDraw();
    println((millis()-t)/1000.0 + " seconds");
    noLoop();
  }
}

void globalMean(int p)
{
  rS[p] += red(mrk.pixels[p]);
  gS[p] += green(mrk.pixels[p]);
  bS[p] += blue(mrk.pixels[p]);
}

color vertPixelsMean(int offset)
{
  //Vertical scan, averages columns
  r=0;
  g=0;
  b=0;
  int rAvg = 0;
  int gAvg =0;
  int bAvg = 0;

  for (int row = offset; row < mrk.width*mrk.height; row+= mrk.width)
  {
    r += red(mrk.pixels[row]);
    g += green(mrk.pixels[row]);
    b += blue(mrk.pixels[row]);
    // println("I see R: " + red(mrk.pixels[row]) + " G: " + green(mrk.pixels[row]) + " B: " + blue(mrk.pixels[row]));

    if (row + mrk.width > (mrk.width*mrk.height))
    {
      rAvg =  r/(row/mrk.width);
      gAvg =  g/(row/mrk.width);
      bAvg =  b/(row/mrk.width);
    }
  }
  // println("R: " + rAvg + " G: " + gAvg + " B: " + bAvg);
  return color(rAvg, gAvg, bAvg);
}

color horzPixelsMean(int offset)
{
  //Vertical scan, averages columns
  r=0;
  g=0;
  b=0;
  int rAvg = 0;
  int gAvg =0;
  int bAvg = 0;
  int displace = offset*fw;
  for (int col = 0; col < mrk.width; col++)
  {
    r += red(mrk.pixels[col+displace]);
    g += green(mrk.pixels[col+displace]);
    b += blue(mrk.pixels[col+displace]);
    // println("I see R: " + red(mrk.pixels[col]) + " G: " + green(mrk.pixels[col]) + " B: " + blue(mrk.pixels[col]));

    if (col + 1 >= mrk.width)
    {
      rAvg =  r/(col);
      gAvg =  g/(col);
      bAvg =  b/(col);
    }
  }
  // println("R: " + rAvg + " G: " + gAvg + " B: " + bAvg);
  return color(rAvg, gAvg, bAvg);
}

