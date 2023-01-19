import processing.pdf.*;

float[] la = new float[3];
float scale = 80.0; // whole scale
float theta;
String[] lines;
String[] m;
String[] s;
String title;

float min = 10000;
float max = -10000;

int n_atom;
int n_t, nx;
int sigma;
float x_lat; // = 168;
float y_lat; // = 100;
int rr = 6; // ellipse radius

float xx = 0.8498366*3*scale; //2*5.6268795*scale; //5.0720005*scale;
float yy = 0.8498366*3*scale; //5.8566415*scale;
float zz = 1.0;
float dif1;
float dif2;
float ratio;
int atom_color;
float x0; //-0.5 * x_lat + width / 2
float y0; //0.5 * y_lat + height / 2
boolean draw_rotate;

void setup() {
  size(600, 480);
  load_poscar();
  noLoop();
  beginRecord(PDF, "filename.pdf");
}

void draw() {
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  background(255);

  draw_grid(x_lat, y_lat);
  //println("$lx=", xx / scale);
  //println("$ly=", yy / scale);
  //println("$lz=", zz);
  //println("$poss=[");
  if (draw_rotate == true) {
    draw_tilt_rect(153);
  }
  draw_rect(153);
  draw_atoms(); 
  draw_title(title);
  //println("]");
  //println("$delete_atoms=[]");
  endRecord();
}

void draw_grid(float x_lat, float y_lat) {
  float mesh = float(nx);
  rect( -0.5 * x_lat + width / 2, 0.5 * y_lat + height / 2, x_lat, -y_lat);
  float xd = x_lat / mesh;
  float yd = y_lat / mesh;
  stroke(126);
  for (int i = 0; i < mesh; i++) {
    float x0= -0.5 * x_lat + xd * i + width / 2;
    line(x0, y0, x0, y0 - y_lat);
  }
  for (int i = 0; i < mesh; i++) {
    float y0 = 0.5 * y_lat - yd * i + height / 2;
    line(x0, y0, x0 + x_lat, y0);
  }
}
void load_poscar() {
  lines = loadStrings("POSCAR_ene");
  title = lines[0];
  m = match(title, "n_expand=\\s*(\\d+) x\\s*(\\d+) x\\s*(\\d+), n_t=\\s*(\\d+)(.*)");
  //println("$header ='"+m[0]+"'");
  //println(m[1], m[2], m[3], m[4]);
  //println(m[5]);
  if (match(m[5], ".+mirrored.+")==null) {
    draw_rotate = true;
  } else {  
    draw_rotate = false;
  };  
  n_t = int(m[4]);
  //println(n_t);
  nx=int(m[1]); // for grid
  //println(nx);
  for (int i = 0; i< 3; i++) {
    m = match(lines[i + 2], "\\s*(\\d+.\\d+)\\s+(\\d+.\\d+)\\s+(\\d+.\\d+)");
    la[i] = float(m[i + 1]);
    //println(la[i]);
  }
  m = match(lines[6], "\\s*(\\d+)");
  n_atom = int(m[1]);
  //println(n_atom);
  x_lat = la[0] * scale;
  //println(x_lat);
  y_lat = la[1] * scale;
  //println(y_lat);
  theta = atan(1.0/float(n_t));
  println(theta);
  x0 =-  0.5 * x_lat +width / 2;
  y0 = 0.5 * y_lat + height / 2;
}

void draw_atoms() {
  for (int i = 0; i < n_atom; i++) {
    s = match(lines[i + 8], "\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)");
    //println(m[4]);
    if (min > float(s[4])){
      min = float(s[4]);
    }
    if (max < float(s[4])){
      max = float(s[4]);
    }
    //println(max);
    //println(min);
  }
  
  dif1 = (max - min) * 100; //difference
  //println(dif1);
  ratio = 240 / dif1; //ratio
  //println(ratio);
  
  for (int i = 0; i < n_atom; i++) {
    //m = match(lines[i + 8], "\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)");
    m = match(lines[i + 8], "\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)\\s*([-]?\\d+.\\d+)");
    
    float zz = float(m[4]); //energy_load
    //println(zz);
    dif2 = (zz - max) * 100;
    //println(dif2);
    atom_color = abs(int(dif2) * (int)ratio);
    //println(atom_color);
    
    for (int j =-  1; j < 2; j++) {
      for (int k =-  1; k < 2; k++) {
        float ra = rr;
        colorMode( HSB, 360, 100, 100);
        fill(atom_color, 100, 100); //(Hue,saturation,brightness)
        //colorMode( HSB, 250, 100, 100);
        //fill(atom_color, 60, 100); //(Hue,saturation,brightness)
        //if (zz >=  0.5  &&  zz < 1.0) { 
          //ra = ra * 0.5;
          //colorMode( HSB, 360, 100, 100 );
          //fill(230,100,100);
          //} else {
          //colorMode( HSB, 260, 100, 100 );
          //fill(0,100,100);
        //}
        //if (draw_rotate) {
        //  fill(255);// gray
        //} else {
         // fill(0);
        //}
        draw_circle(0.0, i, j, k, ra);
        if (draw_rotate) {
          //colorMode( HSB, 360, 100, 100);
          fill(255, 0, 0);   // red*****
          draw_circle(theta, i, j, k, ra);
        }
      }
    }
  }
}

void draw_circle(float theta, int i, int j, int k, float ra) {
  float[] v0 = new float[2];
  float[] v1 = new float[2];
  v0= r_matrix(theta, (j + float(m[1])) * x_lat, (k + float(m[2])) * y_lat);
  v1= shift_pos(v0[0], v0[1]);
  println(v1[0]);
  println(v1[1]);
  circle(v1[0], v1[1], ra);
  if (j ==  0 && k ==  0) {
    draw_number(i, v1);
  }
  if (theta > 0.01) {
    if ((v1[0] >= x0 && v1[0] <= x0 + xx) &&
      (v1[1]<= y0 && v1[1]>= y0 - yy)
      ) {
      println("[", (v1[0] - x0) / xx, ",", 
        - (v1[1] - y0) / yy, ",", m[3], "],#", i);
    }
  }
}

float[] shift_pos(float x, float y) {
  // to see normal view angle
  float[] vv = new float[2];
  vv[0] = x + x0;
  vv[1] =  - y + y0;
  return vv;
}

void circle(int x, int y, int r) {
  ellipse(x, y, r, r);
}

float[] r_matrix(float theta, float x, float y) {
  float[] vv = new float[2];
  vv[0] = cos(theta) * x - sin(theta) * y;
  vv[1] = sin(theta) * x + cos(theta) * y;
  return vv;
}

void draw_tilt_rect(int gray) {
  stroke(gray);
  float[][] p_v = { {0.0, 0.0}, {0.0, y_lat}, {x_lat, y_lat}, {x_lat, 0.0}, {0.0, 0.0} }; 
  float[] v0 = new float[2];
  float[] v1 = new float[2];
  for (int i = 0; i < 4; i++) {
    v0 =r_matrix(theta, p_v[i][0], p_v[i][1]);
    v1 =r_matrix(theta, p_v[i + 1][0], p_v[i + 1][1]);
    line(x0 + v0[0], y0 - v0[1], 
      x0 + v1[0], y0 - v1[1]);
  }
}

void draw_rect(int gray) {
  stroke(gray);
  fill(0, 255, 0, 25);
  //rect(x0,y0,xx-42,-yy);
  //rect(x0, y0, xx, -yy);
}

void draw_title(String title) {
  stroke(255);
  fill(255, 255, 255, 255);
  rect(0, 0, width, 20);
  fill(0, 0, 0, 255);
  textSize(14);
  text(title, 2, 18);
}

void draw_number(int num, float[] pos) {
  fill(0);
  textSize(14);
  text(num, pos[0] - 5, pos[1] - 10);
  
}
