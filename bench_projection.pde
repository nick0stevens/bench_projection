import processing.video.*;




//Capture cam;
int cols, rows;


// below are varibale you can tweak
// select input mode below. images and movies need to be palced in the data folder
int INPUT_MODE = 3; // 0= text, 1 = jpeg image, 2= mpeg movie, 3= webcam (640x360). You may need to rename the webcam in setup to run properly
boolean mirror = false;// if iput needs to be mirrored (uesful for webcam) set mirror to true.
int threshold = 125; // used to in creating black and white version of input
int ERASE_FACTOR = 1; // reduce this to prolong fade time ( min=1 - max= 10);
boolean underlayOn = true; // set to true to see faint underlay of input image;

int maxParticles = 3000; // the maximum number of active particles
ArrayList <Particle> particles = new ArrayList <Particle> (); // the list of particles
int drawMode = 3; // cycle through the drawing modes by clicking the mouse
color BACKGROUND_COLOR = color(255);
color PGRAPHICS_COLOR = color(0);
float fc001;
PGraphics pg;

Capture cam;
Movie mov;
PImage  projection, underlay, input, img;

void setup() {
  frameRate(24);

  size(640, 360, P2D);

  if (INPUT_MODE==1) {
    img = loadImage("Image.jpeg");
  } else if (INPUT_MODE==2) {
    mov = new Movie(this, "Movie.mp4");
    mov.loop();
  } else if (INPUT_MODE==3) {
    println( Capture.list());
    cam = new Capture(this, 640, 360, "FaceTime HD Camera");
    cam.start();
  }

  input = createImage(width, height, RGB);
  projection = createImage(width, height, RGB);
  underlay = createImage(width, height, ARGB);

  // create the offscreen PGraphics 
  pg = createGraphics(width, height, JAVA2D);
  pg.beginDraw();
  pg.textSize(250);
  pg.textAlign(CENTER, CENTER);
  pg.fill(PGRAPHICS_COLOR);
  if (INPUT_MODE==0) {
    pg.text("Trial", pg.width/2, pg.height/2);
  } else if (INPUT_MODE==1) {
    pg.image(img, 0, 0, width, height);
  } 
  pg.endDraw();
  background(BACKGROUND_COLOR);
}

void draw() {
  if (underlayOn) {
    image(underlay, 0, 0);
    tint(255, 10);
  }

  //the following fades out the trails
  fill(255, ERASE_FACTOR); 
  rect(0, 0, width, height);
  fadescreen();


  updateInput();
  underlayImage();



  fc001 = frameCount * 0.01;
  addRemoveParticles();
  // update and display each particle in the list
  for (Particle p : particles) {
    p.update();
    p.display();
  }
}

void mousePressed() {
  drawMode = ++drawMode%4; // cycle through 4 drawing modes (0, 1, 2, 3)
  background(BACKGROUND_COLOR); // clear the screen
  if (drawMode == 2) image(pg, 0, 0); // draw text to the screen for drawMode 2
  particles.clear(); // remove all particles
}

void addRemoveParticles() {
  // remove particles with no life left
  for (int i=particles.size ()-1; i>=0; i--) {
    Particle p = particles.get(i);
    if (p.life <= 0) {
      particles.remove(i);
    }
  }
  // add particles until the maximum
  while (particles.size () < maxParticles) {
    particles.add(new Particle());
  }
}


void updateInput() {
  projection.loadPixels();
  input.loadPixels(); 
  
  
  if (INPUT_MODE==0) {
    return;
  }
  
    else if (INPUT_MODE==1) {
      img.loadPixels();
       for (int i = 0; i < img.pixels.length; i++) {
        input.pixels[i] = img.pixels[i];
      }
  }
  else if (INPUT_MODE==2) {
    if (mov.available()) {
      mov.read();
      mov.loadPixels();

      for (int i = 0; i < mov.pixels.length; i++) {
        input.pixels[i] = mov.pixels[i];
      }
    }
  }


 else if (INPUT_MODE==3) {
    if (cam.available()) {
      cam.read();
      cam.loadPixels();
      for (int i = 0; i < cam.pixels.length; i++) {
        input.pixels[i] = cam.pixels[i];
      }
    }
  }



  // Begin loop for columns
  for (int x = 0; x < width; x++) {
    // Begin loop for rows
    for (int y = 0; y < height; y++) {
      int loc = y*width + x;
      int mirrorLoc = (width - x - 1) + y*width;
      if (mirror) {
        projection.pixels[loc] = input.pixels[mirrorLoc];
      } else {
        projection.pixels[loc] = input.pixels[loc];
      }
      if (brightness(projection.pixels[loc])>threshold) {
        projection.pixels[loc] = color(255);
      } else {
        projection.pixels[loc] = color(0);
      }
    }
  }

  if (INPUT_MODE==2) { 
    mov.updatePixels();
  } else if (INPUT_MODE==3) { 
    cam.updatePixels();
  }

  projection.updatePixels();
  input.updatePixels();
  pg.beginDraw(); 
  pg.image(projection, 0, 0);    
  pg.endDraw();
}

void fadescreen() { 
  loadPixels();
  for (int i = 0; i < pixels.length; i++) {
    int currR = (pixels[i] >> 16) & 0xFF; // Like red(), but faster
    int currG = (pixels[i] >> 8) & 0xFF;
    int currB = pixels[i] & 0xFF;
    pixels[i] = color(currR + 5, currG + 5, currB + 5);
  } 
  updatePixels();
}


void underlayImage() {

  underlay.loadPixels();
  if (INPUT_MODE==0) {
    for (int i = 0; i < underlay.pixels.length; i++) {
      underlay.pixels[i] = pg.pixels[i];
    }
  }
   if (INPUT_MODE==1) {
    for (int i = 0; i < underlay.pixels.length; i++) {
      underlay.pixels[i] = img.pixels[i];
    }
  } 
  else if (INPUT_MODE==2 ||INPUT_MODE==3) {
    

    for (int x = 0; x < width; x++) {
      // Begin loop for rows
      for (int y = 0; y < height; y++) {
        int loc = y*width + x;
        int mirrorLoc = (width - x - 1) + y*width;
        if (mirror) {
          underlay.pixels[loc] = input.pixels[mirrorLoc];
        } else {
          underlay.pixels[loc] = input.pixels[loc];
        }

        underlay.updatePixels();
      }
    }
  }
}

