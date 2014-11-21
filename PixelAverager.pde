//Authored by Mathyoumore

//To do
/*
Convert current drawing page to PGraphic style thing
 - SPOC for output?
 - Median versions of scans
 - Maximum
 - Minimum
 - Range
 - Summation
 - Variance
 - Standard Deviation (sqrt(Variance))
 - verbosePixel data type: 
  -- Color
  -- Color Properties? (Test for speed) 
  -- True position
  -- Relative position?
 - GUI
 */

PImage mrk; 
PGraphics hMean, vMean, gMean;
int frame = 29633; //28633
float maxFrame = 36686; //73506 //Numerical value of highest frame
float infidelity = 1; //Skipped frames, change with great care

int fts = ceil(maxFrame/infidelity) - ceil(frame/infidelity); //Frames to scan
String loc = "";
String im = loc + "scene" + frame + ".png";
int fw;
int fh; 
int r, g, b =0;
float startFrame = frame;
int[] rS, gS, bS; //Holds the summed r,g,and b values for global mean
float t=0;

boolean doH = true; 
boolean doV = true; 
boolean doG = true;

int status = 0; 
void setup() {
  mrk = loadImage(im);
  int fw = mrk.width; //Frame Width
  int fh = mrk.height; //Frame height
  rS = new int[fw*fh];
  gS = new int[fw*fh];
  bS = new int[fw*fh]; 
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

    if (frame == startFrame)
    {
      t = millis();
    }

    if (frame % 30 == 0 && (frame-startFrame) > 0)
    {
      float mpf = millis()/(frame-startFrame);
      println(floor(frame-startFrame) + " of " + fts + " Frames processed. " + mpf + " millis per frame." +
        "\n" + floor(((maxFrame-frame) * mpf)/(1000*360)) + " hours " + 
        floor(((maxFrame-frame) * mpf)/(1000*60)) + " minutes " + 
        floor(((maxFrame-frame) * mpf)%(60)) + " seconds remaining.");
    }

    //Progress bar
    fill(0, 200, 0);
    rect(0, 0, ((frame-startFrame)/fts)*width, height);

    hMean.beginDraw();
    vMean.beginDraw();

    hMean.noStroke();
    vMean.noStroke();

    color c = 0;

    fill(0, 200, 00);
    rect(0, 0, (frame/maxFrame), height);
    if (frame != startFrame) 
    {
      im = loc + "scene" + frame + ".png";
      mrk = loadImage(im);
      if (mrk != null)
      {
        fw = mrk.width;
        fh = mrk.height;
      } else
      {
        fw = -1;
        fh = -1;
      }
    }
    if (fh != -1 && fw != -1) 
    {//Is the image a valid image
      mrk.loadPixels();
      //println(fw + " x " + fw);      
      if (doV)
      {
        for (int x = 1; x<fw; x++)
        {
          c = vertPixelsMean(x);
          vMean.fill(c);
          vMean.rect(x, (frame/infidelity)-(startFrame/infidelity), x+1, (frame/infidelity)-(startFrame/infidelity)+1);
        }
      }

      if (doH)
      {
        for (int y = 1; y<fh; y++)
        {
          c = horzPixelsMean(y);
          hMean.fill(c);
          hMean.rect(frame/infidelity-(startFrame/infidelity), y, frame/infidelity-(startFrame/infidelity)+1, y+1);
        }
      }

      if (doG)
      {
        for (int p = 0; p < fw*fh; p++)
        {
          globalMean(p);
        }
      }
    }

    frame+=infidelity;
  } else 
  {
    vMean.save("newv.png");
    hMean.save("newh.png");
    vMean.endDraw();
    hMean.endDraw();

    if (doG)
    {
      gMean.beginDraw();
      for (int p = 0; p < fw * fh; p++)
      {
        rS[p] = floor(rS[p]/fts);
        gS[p] = floor(gS[p]/fts);
        bS[p] = floor(bS[p]/fts);
        gMean.set(p % fw, p / fw, color(rS[p], gS[p], bS[p]));
      }

      gMean.save("newg.png");
      gMean.endDraw();
    }
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
  int gAvg = 0;
  int bAvg = 0;

  for (int row = offset; row < fw*fh; row+= fw)
  {
    r += red(mrk.pixels[row]);
    g += green(mrk.pixels[row]);
    b += blue(mrk.pixels[row]);
    // println("I see R: " + red(mrk.pixels[row]) + " G: " + green(mrk.pixels[row]) + " B: " + blue(mrk.pixels[row]));

    if (row + fw >= (fw*fh))
    {
      rAvg =  r/(row/fw);
      gAvg =  g/(row/fw);
      bAvg =  b/(row/fw);
    }
  }
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
  for (int col = 0; col < fw; col++)
  {
    r += red(mrk.pixels[col+displace]);
    g += green(mrk.pixels[col+displace]);
    b += blue(mrk.pixels[col+displace]);

    if (col + 1 >= fw)
    {
      rAvg =  r/(col);
      gAvg =  g/(col);
      bAvg =  b/(col);
    }
  }
  return color(rAvg, gAvg, bAvg);
}

