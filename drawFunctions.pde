void dettaglio(Artista a) {

  float raggio = a.getAura() + a.getRadius();
  PImage photo = loadImage(a.getProfile(), "jpg");

  pushMatrix();

  float scala = raggio*2/photo.width;
  //println(scala);
  scale(scala, scala);

  PGraphics mask = createGraphics(photo.width, photo.height);
  mask.beginDraw();

  if (a.getNome().equals("Achille Lauro") || a.getNome().equals("Coez") || a.getNome().equals("Salmo") ) {
    mask.ellipse(photo.width/2, photo.height/2, raggio*1.3*(1/scala), raggio*1.3*(1/scala));
    mask.endDraw();
    photo.mask(mask);

    translate(a.getXPos()*(1/scala), a.getYPos()*(1/scala));
    image(photo, -photo.width/2, -photo.height/2);
  } else {
    mask.ellipse(photo.width/2, photo.height*0.4, raggio*1.3*(1/scala), raggio*1.3*(1/scala));
    mask.endDraw();
    photo.mask(mask);

    translate(a.getXPos()*(1/scala), a.getYPos()*(1/scala));
    image(photo, -photo.width/2, -photo.height*0.4);
  }
  popMatrix();
}

void drawCollabs() {
  if (selected != -1 && found) {

    nascosti = new ArrayList<Artista>();

    for (int i = 0; i < cantanti.get(selected).getFeats().size(); i++) {
      Boolean valido = true;

      for (int j = 0; j < cantanti.size(); j++) {
        if (cantanti.get(selected).getFeats().getJSONObject(i).getString("name").equals(cantanti.get(j).getNome()) ) {
          valido = false;
        }
      }

      if (valido) {
        Artista agg = new Artista(cantanti.get(selected).getFeats().getJSONObject(i).getString("name"), "");
        agg.setAura(cantanti.get(selected).getFeats().getJSONObject(i).getInt("appears"));
        nascosti.add(agg);
      }
    }

    float angolo = nascosti.size();

    Artista a = cantanti.get(selected);

    float newR = ( 2*PI*(a.getRadius()+a.getAura()) / nascosti.size()) - 2 ;
    if (newR > 20) newR = 20;


    dettaglio(a);

    for (int i = 0; i < nascosti.size(); i++) {

      int newDist = a.getAura();
      if (a.getAura() < 20) newDist = 20;

      float newX = a.getXPos() + (a.getRadius()+newDist) * cos(radians(i*(360/angolo)));
      float newY = a.getYPos() + (a.getRadius()+newDist) * sin(radians(i*(360/angolo)));

      nascosti.get(i).setXPos(round(newX));
      nascosti.get(i).setYPos(round(newY));

      nascosti.get(i).setRadius(round(newR));

      nascosti.get(i).drawArtist(i*(360/angolo));
    }
  }
}

void moveArtist(int moving, int index) {
  if (moving != -1) {

    cantanti.get(moving).setXPos(mouseX);
    cantanti.get(moving).setYPos(mouseY);

    //controllo movimento x out of border
    if (mouseX < cantanti.get(moving).getRadius()/2)
      cantanti.get(moving).setXPos(cantanti.get(moving).getRadius()/2);
    if (mouseX > width - cantanti.get(moving).getRadius()/2)
      cantanti.get(moving).setXPos(width - cantanti.get(moving).getRadius()/2);

    //controllo movimento y out of border
    if (mouseY < cantanti.get(moving).getRadius()/2)
      cantanti.get(moving).setYPos(cantanti.get(moving).getRadius()/2);
    if (mouseY > height - cantanti.get(moving).getRadius()/2 - 160)
      cantanti.get(moving).setYPos(height - cantanti.get(moving).getRadius()/2 - 160);


    if(mouseX < 120 && mouseY < 170) {
      cantanti.get(moving).setXPos(mouseX);
      cantanti.get(moving).setYPos(170);
    }

    cantanti.get(moving).drawLinks(index);
    cantanti.get(moving).drawArtist(361.0);
  }
}

void disegnaBarre(Link pall) {
  dettaglio(pall.getA());
  dettaglio(pall.getB());
  JSONObject durations = loadJSONObject("data/"+pall.getA().getNome()+"_durations.json");

  fill(#1db054);
  textAlign(LEFT);
  textFont(createFont("Arial Italic", 16));
  text(pall.getA().getNome() + " feat. " + pall.getB().getNome(), 20, height-10);

  int larghezza = 10;
  /*300 / pall.getSongs().size();
   if(larghezza > 10) larghezza = 10;
   */
  for (int i = 0; i < pall.getSongs().size(); i++) {


    int d = durations.getJSONObject(pall.getSongs().getString(i)).getInt("d");
    int p = durations.getJSONObject(pall.getSongs().getString(i)).getInt("p");

    String nomecanzone = "";
    if (pall.getNames().getString(i).length() > 17)
      nomecanzone = pall.getNames().getString(i).substring(0, 17)+"...";
    else nomecanzone = pall.getNames().getString(i);

    //nomecanzone += " d = "+float((d/1000)/60);

    int alpha = round(map(p, 0, 80, 1, 300));
    fill(#1db054, alpha);
    //1db054
    int bar = round(map(d, 0, 300000, 0, 110));

    rect(40+i*(larghezza+20), height-30, larghezza, -random(bar-5, bar+5));//-random(bar-5, bar+5));
    pushMatrix();
    translate(40+i*(larghezza+20), height-30);
    rotate(-PI/2);
    textAlign(LEFT);
    textFont(createFont("Arial", 13));
    fill(255);

    text(nomecanzone, larghezza/2, -larghezza/2);
    popMatrix();
  }
}

void grafico() {
  background(#191414);

  legenda();

  pallini = new ArrayList<Link>();

  for (int i = 0; i < cantanti.size(); i++) {
    cantanti.get(i).drawLinks(i);
  }
  for (int i = 0; i < cantanti.size(); i++) {
    cantanti.get(i).drawArtist(361.0);
  }
}

void legenda() {
  textFont(createFont("Arial", 13));
  textAlign(LEFT);

  int r = 7;

  fill(#0b4f6c, 170);
  text("pop", 35, 25);
  ellipse(15, 20, 20, 20);
  fill(#191414);
  ellipse(15, 20, r, r);

  fill(#ba2d0b, 170);
  text("rap", 35, 50);
  ellipse(15, 45, 20, 20);
  fill(#191414);
  ellipse(15, 45, r, r);

  fill(#6B017C, 170);
  text("trap", 35, 75);
  ellipse(15, 70, 20, 20);
  fill(#191414);
  ellipse(15, 70, r, r);

  fill(#ffc857, 170);
  text("indie", 35, 100);
  ellipse(15, 95, 20, 20);
  fill(#191414);
  ellipse(15, 95, r, r);

  fill(#ffffff, 170);
  ellipse(15, 120, 20, 20);
  text("unlistened", 35, 125);
  fill(#191414);
  ellipse(15, 120, r, r);
  //line(15, 120, 25, 120);

  /*line(9, 120, 21, 120);
   line(9, 116, 9, 124);
   line(21, 116, 21, 124);*/

  stroke(#1db054, 170);
  strokeWeight(1.5);
  line(5, 141, 25, 141);
  line(5, 137, 5, 144);
  line(25, 137, 25, 144);

  fill(#1db054, 170);
  text("n° feats", 35, 144);

  /*fill(#ffffff, 150);
   rect(10, 70, 10, 10);
   text("unlistened", 25, 80);*/

  //line(0, height-160, width, height-160);
  noStroke();
  fill(170, 30);
  rect(0, height, width, -160);

  if (selected != -1 && !toggleCollabs) {
    fill(255);
    textAlign(CENTER);
    textFont(createFont("Arial", 15));
    text("Click to show featurings not in the graph", width/2, height-80);
  }

  if (selected != -1 && toggleCollabs) {
    stroke(255);
    strokeWeight(2);
    fill(255);
    textAlign(CENTER);
    textFont(createFont("Arial", 15));
    text("Click to hide featurings not in the graph", width/2, height-80);
  } else if (selected == -1 && linked==-1) {
    stroke(255);
    strokeWeight(2);
    fill(255);
    textAlign(CENTER);
    textFont(createFont("Arial", 15));
    text("Select an Artist for details and connections!", width/2, height-80);
  }

  stroke(#1db054);
  fill(#1db054);
  strokeWeight(1.5);

  line(width-50, height-30, width-50, height-140);
  line(width-55, height-30, width-45, height-30);
  line(width-55, height-140, width-45, height-140);
  textAlign(LEFT);
  textFont(createFont("Arial", 13));
  strokeWeight(1);
  text("~ 0m", width-40, height-25);
  text("~ 4m", width-40, height-135);

  noStroke();
  for (int i = 30; i < 140; i += 5) {
    fill(#1db054, map(i, 30, 140, 40, 250));
    rect(width-90, height-i, 10, -5);
  }

  fill(#ffffff);
  pushMatrix();
  translate(width-35, height-85);
  rotate(radians(-90));
  textAlign(CENTER);
  text("duration", 0, 0);
  text("popularity", 0, -35);
  popMatrix();
}

void livello0_wrapper() {
  noStroke();
  grafico();
  if (toggleCollabs) drawCollabs();
  if (linked != -1)
    disegnaBarre(pallini.get(linked));
}
