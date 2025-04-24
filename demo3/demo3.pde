import processing.sound.*;

int gap = 15;
int beat = 0;
int size = 32;

int gridSize = 50;

int count = 0;

SinOsc[] sine = new SinOsc[size];

SawOsc saw;
SqrOsc square;
TriOsc triangle;
SoundFile layer1, layer2, layer3;
Waveform waveform;
AudioIn in;
FFT fft;
int bands = 512;
float[] spectrum = new float[bands];

int samples = 600;


float sineAmp = 0;
float lastAmp = 0;

float[] amp = new float[size];
int[] clickX = new int[size];
int[] clickY = new int[size];
float[] currentAmp = new float[size];
int[] freq = new int[size];

float[] bgAmp = new float[4];

int[] notes = new int[12];

// Particles
int currentParticle = 0;
float[] posX = new float[1000];
float[] posY = new float[1000];
float[] alpha = new float[1000];
color[] col = new color[1000];

void setup() {
  frameRate(60);
  layer1 = new SoundFile(this, "layer1.wav");
  layer2 = new SoundFile(this, "layer2.wav");
  layer3 = new SoundFile(this, "layer3.wav");
  layer1.amp(0);
  layer2.amp(0);
  layer3.amp(0);
  layer1.loop();
  bgAmp[1] = 0;
  layer2.loop();
  bgAmp[2] = 0;
  layer3.loop();
  bgAmp[3] = 0;
  size(512,512);
  background(255);
  notes[0] = 2;
  notes[1] = 3;
  notes[2] = 7;
  notes[3] = 10;
  notes[4] = 2 - 12;
  notes[5] = 3 - 12;
  notes[6] = 7 - 12;
  notes[7] = 10 - 12;
  notes[8] = 2 + 12;
  notes[9] = 3 + 12;
  notes[10] = 7 + 12;
  notes[11] = 10 + 12;
  //saw.play();
  //square.play();
  
  for(int i = 0;i < size;i++) {
    amp[i] = 0;
    clickX[i] = width / 2;
    clickY[i] = height / 2;
    sine[i] = new SinOsc(this);
  }
  amp[0] = 0.1;
  freq[0] = 2;
  triangle = new TriOsc(this);
  triangle.play();
  in = new AudioIn(this, 0);
  waveform = new Waveform(this, samples);
  waveform.input(in);
  fft = new FFT(this, bands);
  fft.input(in);
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
  text(beat + 1, width / 2, height / 2);
  
  
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
  triangle.freq(NotetoFreq(24));
  if(frameCount % gap == 0) {
    currentAmp[beat] = amp[beat];
    playSound(amp[beat], NotetoFreq(freq[beat]));
    if(count > 5)
      currentAmp[rotateNum(beat, -1, 0, size - 1)] = amp[rotateNum(beat, -1, 0, size - 1)];
    if(count > 10)
      currentAmp[rotateNum(beat, -2, 0, size - 1)] = amp[rotateNum(beat, -2, 0, size - 1)];
    if(count > 15)
      currentAmp[rotateNum(beat, -3, 0, size - 1)] = amp[rotateNum(beat, -3, 0, size - 1)];
    
    
  }
  lastAmp = lerp(lastAmp, sineAmp, 0.05);
  sineAmp = min(sineAmp, 1);
  for(int i = 0; i < size;i++) {
    drawSound(clickX[i], clickY[i], currentAmp[i]);
    
    sine[i].amp(currentAmp[i]);
    if(currentAmp[i] == 0.5) {
      addParticle(i);
    }
  }
  drawParticles();
  bgAmp[1] = min(0.8, count / 8.0);
  bgAmp[2] = max(0, min(0.4, (count - 4) / 5.0));
  bgAmp[3] = max(0, min(1, (count - 7) / 3.0));
  layer1.amp(bgAmp[1]);
  layer2.amp(bgAmp[2]);
  layer3.amp(bgAmp[3]);
  drawWaveForm();
  drawFFT();
}

void drawFFT() {
  stroke(201, 10, 255);
  fft.analyze(spectrum);

  for(int i = 0; i < bands; i++) {
    float dif = spectrum[i]*height*20;
    line(i * 5, height / 2 + dif, i * 5, height / 2 - dif );
  } 
}
void drawWaveForm() {
  stroke(0);
  strokeWeight(2);
  noFill();


  waveform.analyze();

  beginShape();
  for(int i = 0; i < samples; i++)
  {
    vertex(
      map(i, 0, samples, 0, width),
      map(waveform.data[i], -1, 1, 0, height) - lastAmp * height + height / 2
    );
  }
  endShape();
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
    float sz = max(20, (lastAmp + .2) * 200 - dist(posX[i], posY[i], mouseX, mouseY) / 10);
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
  sineAmp += val * 0.8;
  sine[beat].amp(val);
  sine[beat].freq(freq);
  
  sine[beat].play();
}

void mousePressed() {
  amp[beat] = 0.5;
  clickX[beat] = mouseX;
  clickY[beat] = mouseY;
  freq[beat] = notes[floor(random(12))];
  playSound(amp[beat], NotetoFreq(freq[beat]));
  drawSound(clickX[beat], clickY[beat], currentAmp[beat]);
  currentAmp[beat] = amp[beat];
  count++;
  addParticle(beat);
  
}

void addParticle(int i) {
  posX[currentParticle] = clickX[i];
  posY[currentParticle] = clickY[i];
  
  alpha[currentParticle] = 100;
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
  
  rect(x, height / 2, val * gridSize / 2, height);
  rect(width / 2, y, width, val * gridSize / 2);
  //ellipse(gridSize / 2 + gridSize * x, gridSize / 2 + gridSize * y, val * gridSize, val * gridSize);
  
}

float NotetoFreq(int note) {
  return 440 * pow(2, note / 12.0);
}  
