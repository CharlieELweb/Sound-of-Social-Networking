import processing.sound.*;

int gap = 10;
int beat = 0;
int size = 32;

int gridSize = 50;

int count = 0;

SinOsc[] sine = new SinOsc[size];

SawOsc saw;
SqrOsc square;
TriOsc triangle;


float sineAmp = 0;
float lastAmp = 0;

float[] amp = new float[size];
int[] freqX = new int[size];
int[] freqY = new int[size];
float[] currentAmp = new float[size];


// Particles
int currentParticle = 0;
float[] posX = new float[1000];
float[] posY = new float[1000];
float[] alpha = new float[1000];
color[] col = new color[1000];

void setup() {
  
  size(600,600);
  background(255);
  
  //saw.play();
  //square.play();
  
  for(int i = 0;i < size;i++) {
    amp[i] = 0;
    freqX[i] = 6;
    freqY[i] = 6;
    sine[i] = new SinOsc(this);
  }
  amp[0] = 0.1;
  triangle = new TriOsc(this);
  triangle.play();
}      
int rotateNum(int val, int n, int min, int max) {
  int result = val + n;
  if(result < min) {
    result += max - min;
  }
  if(result > max) {
    result -= max - min;
  }
  return result;
}
void draw() {
  beat = ((frameCount) / gap) % size;
  background(255);
  rectMode(CORNER);
  fill(200);
  noStroke();
  rect(0, (1 - sineAmp) * height, width, height);
  fill(230, 230 - max(460 * (lastAmp - 0.5), 0), 230 - max(460 * (lastAmp - 0.5), 0), 150);
  rect(0, (1 - lastAmp) * height, width, height);
  textSize(128);
  textAlign(CENTER, CENTER);
  fill(0, 408, 612, 816);
  text(beat, width / 2, height / 2);
  
  
  for(int i = 0;i < size;i++) {
    currentAmp[i] -= 0.01;
    currentAmp[i] = max(0, currentAmp[i]);
    
  }
  
  sineAmp -= 0.01;
  sineAmp = max(0, sineAmp);
  //sine.amp((mouseX / 640.0) * (mouseY / 360.0));
  
  //saw.amp((mouseX / 640.0) * (1 - mouseY / 360.0));
  //saw.freq(400);
  //square.amp((1 - mouseX / 640.0) * (mouseY / 360.0));
  //square.freq(800);
  triangle.amp(max((lastAmp - 0.5), 0));
  triangle.freq((lastAmp - 0.5) * 1500);
  if(frameCount % gap == 0 && amp[beat] > 0) {
    currentAmp[beat] = amp[beat];
    playSound(amp[beat], NotetoFreq(-5 + freqX[beat] + freqY[beat]));
    
    currentAmp[rotateNum(beat, -1, 0, size - 1)] = amp[rotateNum(beat, -1, 0, size - 1)];
    //currentAmp[rotateNum(beat, -2, 0, size - 1)] = amp[rotateNum(beat, -2, 0, size - 1)];
    //currentAmp[rotateNum(beat, -3, 0, size - 1)] = amp[rotateNum(beat, -3, 0, size - 1)];
    addParticle();
  }
  lastAmp = lerp(lastAmp, sineAmp, 0.05);
  sineAmp = min(sineAmp, 1);
  for(int i = 0; i < size;i++) {
    drawSound(freqX[i], freqY[i], currentAmp[i]);
    
    sine[i].amp(currentAmp[i]);
  }
  drawParticles();

}
void drawParticles() {
  for(int i = 0; i < 1000; i++) {
    if(posX[i] == 0)
      continue;
    posX[i] += (noise(i, frameCount * 0.02) - 0.5) * 10;
    posY[i] += (noise(2000 * i, frameCount * 0.02) - 0.5) * 10;
    if(posX[i] < 0)
      posX[i] += width;
    if(posX[i] > width)
      posX[i] -= width;
     
    if(posY[i] > height)
      posY[i] -= height;
    if(posY[i] < 0)
      posY[i] += height;
    fill(col[i], alpha[i]);
    float sz = max(0, (lastAmp + .1) * 200 - dist(posX[i], posY[i], mouseX, mouseY) / 10);
    ellipse(posX[i], posY[i], sz, sz);
    alpha[i] -= 0.5;
    if(alpha[i] < 0) {
      alpha[i] = 0;
    }
  }
}

void playSound(float val, float freq) {
  
  
  if(val == 0) {
    return;
  }
  sineAmp += val * 0.5;
  sine[beat].amp(val);
  sine[beat].freq(freq);
  
  sine[beat].play();
}

void mousePressed() {
  amp[beat] = 1;
  freqX[beat] = mouseX / gridSize;
  freqY[beat] = mouseY / gridSize;
  playSound(amp[beat], NotetoFreq(-5 + freqX[beat] + freqY[beat]));
  drawSound(freqX[beat], freqY[beat], currentAmp[beat]);
  currentAmp[beat] = amp[beat];
  count++;
  addParticle();
  
}

void addParticle() {
  posX[currentParticle] = gridSize / 2 + gridSize * freqX[beat];
  posY[currentParticle] = gridSize / 2 + gridSize * freqY[beat];
  
  alpha[currentParticle] = 255;
  col[currentParticle] = color(random(255) / pow(1.1, count), random(255) / pow(1.1, count), random(255) / pow(1.1, count)) ;
  currentParticle++;
  if(currentParticle >= 1000)
    currentParticle = 0;
}

void drawSound(int x, int y, float val) {
  if(x < 0 || y < 0) {
    return;
  }
  rectMode(CENTER);
  fill(0);
  noStroke();
  
  rect(gridSize / 2 + gridSize * x, height / 2, val * gridSize / 2, height);
  rect(width / 2, gridSize / 2 + gridSize * y, width, val * gridSize / 2);
  //ellipse(gridSize / 2 + gridSize * x, gridSize / 2 + gridSize * y, val * gridSize, val * gridSize);
  
}

float NotetoFreq(int note) {
  return 440 * pow(2, note / 12.0);
}
