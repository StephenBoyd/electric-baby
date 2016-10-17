import processing.sound.*;

final double SEMITONE_RATIO = pow(2.0, (1.0 / 12.0));

float frequency;
double[] roots = { 110.0, 146.832, 195.997, 246.94 };
boolean playing = false;
char lastKey = ' ';
StringList keysPressed;
SawOsc[] strings = new SawOsc[4];
PFont font;
String note;
Env envelope;

float attackTime = 0.0001;
float sustainTime = 0.15;
float sustainLevel = 0.05;
float releaseTime = 0.3;

String[] frets = {
  "zxcvbnm,./",
  "asdfghjkl;'",
  "qwertyuiop[]",
  "1234567890-="
};

String[] notes = {"A", "A\u266F", "B", "C", "C\u266F", "D", "D\u266F", "E", "F", "F\u266F", "G", "G\u266F"};

float tune(double currentFrequency, int intervalSemitones) {
  double newFrequency = currentFrequency;
  for (int i = 0; i < intervalSemitones; i++) {
    newFrequency = newFrequency * SEMITONE_RATIO;
  }
  if (intervalSemitones < 0) {
    intervalSemitones = intervalSemitones * -1;
    for (int i = 0; i < intervalSemitones; i++) {
      newFrequency = newFrequency / SEMITONE_RATIO;
    }
  }
  return (float) newFrequency;
}

void pluck(int fret) {
    int keyInterval = frets[fret].indexOf(key);
    frequency = tune(roots[fret], keyInterval);
    note = notes[keyInterval % 12];
    println(note + " : " + frequency);
    strings[fret].play(frequency, 0.6);
    envelope.play(strings[fret], attackTime, sustainTime, sustainLevel, releaseTime);
    playing = true;
}

void keyPressed() {
  println("keypressed: " + key);
  if (key == '+') {
    for (int i = 0; i < frets.length; i++) {
      roots[i] = tune(roots[i], 1);
    }
  }
  if (key == '_') {
    for (int i = 0; i < frets.length; i++) {
      roots[i] = tune(roots[i], -1);
    }
  }
  if (playing && (key == lastKey)) {
    return;
  }
  if (playing) {
    playing = false;
  }
  for (int i = 0; i < frets.length; i++) {
    if (frets[i].indexOf(key) != -1) {
      pluck(i);
      break;
    }
  }
  lastKey = key;
}

void keyReleased() {
  if (!keyPressed) {
    println("stopping: " + key);
    note = "";
    playing = false;
  }
}

void setup() {
  println(SEMITONE_RATIO);
  size(640, 360);
  keysPressed = new StringList();
  font = createFont("Open Sans", 48, true);
  envelope = new Env(this);
  float volume = 0.01;
  for (int i = 0; i < strings.length; i++) {
    strings[i] = new SawOsc(this);
    strings[i].amp(volume);
  }
}

void draw() {
  if (!keyPressed && playing) {
    println("stopping");
    playing = false;
  }
  background(0);
  if (playing) {
    textFont(font);
    fill(255);
    textAlign(CENTER, CENTER);
    text(note, 320, 180);
  }
}
