void setup() {
  size(20, 600);
}

void draw() {
  int set=240;
  colorMode( HSB, 360, 100, 100);
  noStroke();
  for(int j=0; j<2; j++){
    for(int i=0; i<set; i++){
        fill(i, 80, 100);
        if(j>0){rect(360*j,i,20,1);}
        rect(0,i,20,1);
    }
  }
}
