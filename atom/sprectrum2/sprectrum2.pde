import processing.pdf.*;
String[] lines;
String[] m;
String[] s;
String title;
boolean draw_rotate;
float[] la = new float[3];
int n_atom;
float min = 10000;
float max = -10000;
int set = 360;
int last = 60 + set;
int mid = (60+last)/2;

void setup() {
  size(600, 480);
  load_poscar();
  noLoop();
  beginRecord(PDF, "filename.pdf");
}

void draw() {
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  background(0);
  draw_atoms(); 
  draw_line();
  endRecord();
}

void load_poscar() {
  lines = loadStrings("POSCAR_ene");
  title = lines[0];
  m = match(title, "n_expand=\\s*(\\d+) x\\s*(\\d+) x\\s*(\\d+), n_t=\\s*(\\d+)(.*)");
  println("$header ='"+m[0]+"'");
  //println(m[1], m[2], m[3], m[4]);
  //println(m[5]);
  if (match(m[5], ".+mirrored.+")==null) {
    draw_rotate = true;
  } else {  
    draw_rotate = false;
  };  
  for (int i = 0; i< 3; i++) {
    m = match(lines[i + 2], "\\s*(\\d+.\\d+)\\s+(\\d+.\\d+)\\s+(\\d+.\\d+)");
    la[i] = float(m[i + 1]);
    println(la[i]);
  }
  m = match(lines[6], "\\s*(\\d+)");
  n_atom = int(m[1]);
  println(n_atom);
}

void draw_atoms(){
  for (int i = 0; i < n_atom; i++) {
    s = match(lines[i + 8], "\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)");
    //println(m[4]);
    if (min > float(s[4])){
      min = float(s[4]);
    }
    if (max < float(s[4])){
      max = float(s[4]);
    }
  }
  String mins = str(min);
  String maxs = str(max);
  String midle = str((max+min)/2);
  
  println(maxs);
  println(mins);
  println(midle);
  
  colorMode( HSB, 360, 100, 100);
  noStroke();
  for(int i=0;i<set;i++){
      fill(i, 100, 100);
      rect(200,60+i,50,1);
  }
  
  fill(255);
  textSize(20);
  //text("0",150,65);
  //text("180",135,(last+60)/2+5);
  //text("360",135,last+5);
  text(maxs,120,65);
  text(midle,65,(last+60)/2+5);
  text(mins,120,last+5);
}

void draw_line(){
  stroke(#FFFFFF);
  strokeWeight(2);
  line(180,60,180,last);
  line(170,60,190,60);
  line(175,(mid+60)/2,185,(mid+60)/2);
  line(170,mid,190,mid);
  line(175,(mid+last)/2,185,(mid+last)/2);
  line(170,last,190,last);
}
