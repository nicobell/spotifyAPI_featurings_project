class Link {

  Artista a;
  Artista b;

  int aXpos, aYpos;
  int bXpos, bYpos;

  int cx;
  int cy;

  JSONArray songs;
  JSONArray names;

  Link (Artista a, Artista b) {
    this.a = a;
    this.b = b;
    this.aXpos = this.a.getXPos();
    this.aYpos = this.a.getYPos();
    this.bXpos = b.getXPos();
    this.bYpos = b.getYPos();
    this.songs = new JSONArray();
    this.names = new JSONArray();

    int medioX = (this.aXpos + this.bXpos) / 2;
    int medioY = (this.aYpos + this.bYpos) / 2;

    int quartoX = (this.aXpos + medioX) / 2;
    int quartoY = (this.aYpos + medioY) / 2;

    this.cx = quartoX;
    this.cy = quartoY;
  }

  void getInfos() {
    
  }

  void collega(int num, int index) {
    line(this.aXpos, this.aYpos, cx, cy);
    line(cx, cy, this.bXpos, this.bYpos);

    if (collegato == index || dist(mouseX, mouseY, this.aXpos, this.aYpos) < (this.a.getRadius()+this.a.getAura())/2) {
      fill(#ffffff, 150);
      ellipse(cx, cy, 10, 10);
    }

    if (dist(mouseX, mouseY, this.aXpos, this.aYpos) < (this.a.getRadius()+this.a.getAura())/2
        || dist(mouseX, mouseY, this.cx, this.cy) < 5) {
      fill(#1ed760);
      textAlign(CENTER);
      textFont(createFont("Arial Bold", 11));
      text(num, cx, cy-10);
    }
  }
  
  JSONArray getNames() {
    return this.names;
  }
  
  void setNames(JSONArray n) {
    
    this.names = n;
  }

  JSONArray getSongs() {
    return this.songs;
  }

  void setSongs(JSONArray s) {
    this.songs = s;
  }

  int getCX() {
    return this.cx;
  }

  int getCY() {
    return this.cy;
  }

  Artista getA() {
    return this.a;
  }

  Artista getB() {
    return this.b;
  }
}
