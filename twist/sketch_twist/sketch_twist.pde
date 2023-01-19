
import processing.pdf.*;

float[] la = new float[3];
float[][] pos;
float scale = 80.0; // whole scale
float theta;
String[] lines;
String[] m;  

int n_atom;
int sigma;
float x_lat; // = 168;
float y_lat; // = 100;
int rr=6; // ellipse radius

void setup() {
  size(600, 480);
  load_poscar();
  noLoop();
  beginRecord(PDF, "filename.pdf");
}
void draw() {
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  background(255);

  rect(-0.5*x_lat+width/2, 0.5*y_lat+height/2, x_lat, -y_lat);
 draw_atom(true, 0.125, 0.0, 1.0); // 0-7  
// draw_atom(true, 0.125, 0.125, 0.5-0.125); // 1-2
// draw_atom(true, 0.125, 0.5-0.125, 0.5+0.125); // 3-4
// draw_atom(true, 0.125, 0.5+0.125, 1.0-0.125); // 5-6

  draw_tilt_rect(153);
  endRecord();
}

void circle(int x, int y, int r) {
  ellipse(x, y, r, r);
}
void up_tri(float x, float y, float r) {
  float rx = 0.866025*1.2;
  float ry = 0.5*1.2;
  float x1 = x- rx*r;
  float y1 = y+ ry*r;
  float x2 = x+ rx*r;
  float y2 = y+ ry*r;
  float x3 = x;
  float y3 = y - r;
  triangle(x1, y1, x2, y2, x3, y3);
}
void down_tri(float x, float y, float r) {
  float rx = 0.866025*1.2;
  float ry = 0.5*1.2;
  float x1 = x- rx*r;
  float y1 = y- ry*r;
  float x2 = x+ rx*r;
  float y2 = y- ry*r;
  float x3 = x;
  float y3 = y + r;
  triangle(x1, y1, x2, y2, x3, y3);
}
float[] r_matrix(float theta, float x, float y) {
  float[] vv = new float[2];
  vv[0] = cos(theta)*x-sin(theta)*y;
  vv[1] = sin(theta)*x+cos(theta)*y;
  return vv;
}
void load_poscar() {
  lines = loadStrings("POSCAR");
  println(lines[0]);
  m = match(lines[0], "n_sigma=\\s+(\\d+)");
  float sigma = float(m[1]);
  theta = atan2(1.0, sigma);
  println(theta);
  for (int i = 0; i < 3; i++) {
    m = match(lines[i+2], "\\s*(\\d+.\\d+)\\s+(\\d+.\\d+)\\s+(\\d+.\\d+)");
    la[i] = float(m[i+1]);
  }
  m = match(lines[5], "\\s*(\\d+)");
  n_atom = int(m[1]);
  println(n_atom);

  x_lat = la[0]*scale;
  y_lat = la[1]*scale;
}
void draw_tilt_rect(int gray) {
  stroke(gray);
  float[][] p_v = { {0.0, 0.0}, {0.0, 1.0}, {1.0, 1.0}, {1.0, 0.0}, {0.0, 0.0} }; 
  float[] v0 = new float[2];
  float[] v1 = new float[2];
  for (int i = 0; i<4; i++) {
    v0 = r_matrix(theta, p_v[i][0], p_v[i][1]);
    v1 = r_matrix(theta, p_v[i+1][0], p_v[i+1][1]);
    line((-0.5+v0[0])*x_lat+width/2, (0.5-v0[1])*y_lat+height/2, 
      (-0.5+v1[0])*x_lat+width/2, (0.5-v1[1])*y_lat+height/2);
    v0 = r_matrix(-theta, p_v[i][0], p_v[i][1]);
    v1 = r_matrix(-theta, p_v[i+1][0], p_v[i+1][1]);
    line((-0.5+v0[0])*x_lat+width/2, (0.5-v0[1])*y_lat+height/2, 
      (-0.5+v1[0])*x_lat+width/2, (0.5-v1[1])*y_lat+height/2);
  }
}
void draw_number(int num, float[] pos, boolean print_num) {
  if (print_num) {
    textSize(14);
    fill(0, 102, 153);
    text(num, pos[0]-5, pos[1]-10);
  }
}
void draw_atom(boolean print_num, float dev,
    float init,  float fin) {
  pos = new float[n_atom][3];
  for (int i = 0; i < n_atom; i++) {
    m = match(lines[i+7], "\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)");
    pos[i][0] = (float(m[1])-0.5)*x_lat+width/2;
    pos[i][1] = (-float(m[2])+0.5)*y_lat+height/2;
    pos[i][2] = float(m[3]);   
    for (int j=-1; j<2; j++) {
      for (int k=-1; k<2; k++) {
        if ( (pos[i][2] >= init) && (pos[i][2] < init+dev) ) { // 1st
          //if ((pos[i][2] >= 0.5-0.125) && (pos[i][2] < 0.5)) { // 4th 
          fill(0);
          down_tri(pos[i][0]+x_lat*j, pos[i][1]+y_lat*k, rr);
          draw_number(i, pos[i], print_num);
        } else if ((pos[i][2] >=  (fin-dev)/1.0) && (pos[i][2] < (fin-0.01)/1.0)) { //
          //} else if ((pos[i][2] >= 0.5) && (pos[i][2] < 0.625)) { // 5th
          fill(255);
          up_tri(pos[i][0]+x_lat*j, pos[i][1]+y_lat*k, rr);
          draw_number(i, pos[i], print_num);
        }
      }
    }
  }
}
