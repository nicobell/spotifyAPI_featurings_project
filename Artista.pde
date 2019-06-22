class Artista {

  String nome, id;
  String profile;
  color colore;
  int radius; //raggio cerchio interno
  int aura; //spessore corona circolare featurings
  int xPos, yPos; //posizione cerchio

  //collegamenti
  JSONArray feats; //collaborazioni per canzone
  JSONArray idFeats; //collaboraizoni per id canzone
  int Acount; //count feats
  int Bcount; //count Bcount

  Artista(String n, String prof) {
    this.feats = new JSONArray();
    this.idFeats = new JSONArray();

    this.Acount = 0;
    this.Bcount = 0;

    this.nome = n;
    this.colore = color(#ffffff, 150);

    this.profile = prof;
    this.radius = 25;
    
    this.xPos = int(random(this.radius+this.aura, width-this.radius-this.aura));
    this.yPos = int(random(this.radius+this.aura, height-this.radius-this.aura-160));
    
    if(this.xPos <= 120 && this.yPos <= 170) {
      this.xPos = 120;
      this.yPos = 170;
    }
    
  }

  void drawArtist(float angolo) {

    noStroke();

    //CORONA CIRCOLARE
    fill(this.colore);

    ellipse(this.xPos, this.yPos, this.radius + this.aura, this.radius + this.aura);

    //MAIN CERCHIO
    
    //int alpha = round(map(cos(radians(angolo)), -1, 1, 300, 40)); 
    
    if (angolo < 361.0) fill(#191414);//, alpha);
    else fill(#191414);
    ellipse(this.xPos, this.yPos, this.radius, this.radius);

    //TESTO ARTISTA e DIDASCALIA FEATS
    this.scriviTesto(angolo);
  }

  void drawLinks(int index) {
    
    for (int i = 0; i < this.feats.size(); i++) {
      for (int j = 0; j < cantanti.size(); j++) {
        
        String nomeAnalizzato = this.feats.getJSONObject(i).getString("name");
        
        //per ogni featuring scorri i cantanti presenti, se il nome è uguale ...
        if (nomeAnalizzato.equals(cantanti.get(j).getNome()) && !nomeAnalizzato.equals(this.nome)) {

          //... mappa la larghezza della linea con il numero di collaborazioni tra i due ...
          stroke(255, 100);
          strokeWeight(map(this.feats.getJSONObject(i).getInt("appears"), 1, 40, 0, 10));
          
          //... e disegna il collegamento!
          Link link = new Link(this, cantanti.get(j));
          link.collega(this.feats.getJSONObject(i).getInt("appears"), index);
          link.setSongs(this.idFeats.getJSONObject(i).getJSONArray("ids"));
          link.setNames(this.feats.getJSONObject(i).getJSONArray("songs"));
          pallini.add(link);
        }
      }
    }
  }


  void addFeat(String a, String cz) {
    Boolean pres = false;

    //CONTROLLA SE IL FEATURING è GIà PRESENTE
    for (int i = 0; i < this.feats.size(); i++) {
      if ( this.feats.getJSONObject(i).getString("name").equals(a) ) {
        //SE LO è AGGIORNA IL AcountER DELLE COLLAB. CON L'ARTISTA E AGGIUNGE LA CANZONE ALLA LISTA RELATIVA
        this.feats.getJSONObject(i).setInt("appears", this.feats.getJSONObject(i).getInt("appears")+1);
        this.feats.getJSONObject(i).getJSONArray("songs").setString( this.feats.getJSONObject(i).getJSONArray("songs").size(), cz) ;
        pres = true;
      }
    }

    //SE NO è PRESENTE CREA UN NUOVO ELEMENTO DI COLLABORAZIONE CON IL NUOVO ARTISTA
    //e incrementa il Acounter per la posizione in cui aggiungere il successivo
    if (!pres) {
      JSONObject p = new JSONObject();
      p.setString("name", a);
      p.setInt("appears", 1);
      p.setJSONArray("songs", new JSONArray().setString(0, cz));
      this.feats.setJSONObject(this.Acount, p);
      this.Acount++;
    }
  }

  void addIdFeat(String a, String id) {
    Boolean pres = false;

    //CONTROLLA SE IL FEATURING è GIà PRESENTE
    for (int i = 0; i < this.idFeats.size(); i++) {
      if ( this.idFeats.getJSONObject(i).getString("name").equals(a) ) {
        //SE LO è AGGIORNA IL AcountER DELLE COLLAB. CON L'ARTISTA E AGGIUNGE LA CANZONE ALLA LISTA RELATIVA
        this.idFeats.getJSONObject(i).setInt("appears", this.idFeats.getJSONObject(i).getInt("appears")+1);
        this.idFeats.getJSONObject(i).getJSONArray("ids").setString( this.idFeats.getJSONObject(i).getJSONArray("ids").size(), id) ;
        pres = true;
      }
    }

    //SE NO è PRESENTE CREA UN NUOVO ELEMENTO DI COLLABORAZIONE CON IL NUOVO ARTISTA
    //e incrementa il Acounter per la posizione in cui aggiungere il successivo
    if (!pres) {
      JSONObject p = new JSONObject();
      p.setString("name", a);
      p.setInt("appears", 1);
      p.setJSONArray("ids", new JSONArray().setString(0, id));
      this.idFeats.setJSONObject(this.Bcount, p);
      this.Bcount++;
    }
  }
  
  void drawCollabs() {
  if (selected != -1 && found) {

    nascosti = new ArrayList<Artista>();

    for (int i = 0; i < this.getFeats().size(); i++) {
      Boolean valido = true;

      for (int j = 0; j < cantanti.size(); j++) {
        if (this.getFeats().getJSONObject(i).getString("name").equals(cantanti.get(j).getNome()) ) {
          valido = false;
        }
      }

      if (valido) {
        Artista agg = new Artista(cantanti.get(selected).getFeats().getJSONObject(i).getString("name"), "");
        agg.setAura(this.getFeats().getJSONObject(i).getInt("appears"));
        nascosti.add(agg);
      }
    }

    float angolo = nascosti.size();

    Artista a = this;

    float newR = ( 2*PI*(a.getRadius()+a.getAura()) / nascosti.size()) - 2 ;
    if (newR > 20) newR = 20;


    a.dettaglio();

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
  
  void dettaglio() {

   Artista a = this;
    
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

  int getXPos() { 
    return this.xPos;
  }
  void setXPos(int x) { 
    this.xPos = x;
  }

  int getYPos() { 
    return this.yPos;
  }
  void setYPos(int y) { 
    this.yPos = y;
  }

  int getRadius() { 
    return this.radius;
  }
  void setRadius(int r) {
    this.radius = r;
  }
  int getAura() { 
    return this.aura;
  }
  void setAura(int a) {
    this.aura = a;
  }
  String getNome() { 
    return this.nome;
  }
  String getProfile() { 
    return this.profile;
  }
  void setProfile(String p) {
    this.profile = p;
  }
  JSONArray getFeats() { 
    return this.feats;
  }
  void setFeats(JSONArray f) {
    this.feats = f;
  }
  JSONArray getIdFeats() { 
    return this.idFeats;
  }
  void setIdFeats(JSONArray f) {
    this.idFeats = f;
  }
  void setColor(color c, int o) {
    this.colore = color(c, o);
  }
  color getColore() {
    return this.colore;
  }

  void scriviTesto(float angolo) {
    if (angolo != 361.0) {
      pushMatrix();
      translate(this.xPos, this.yPos);
      rotate(radians(angolo));
      fill(255);

      if (cos(radians(angolo))<0) {
        scale(-1, -1);

        textAlign(RIGHT);
        textFont(createFont("Arial", 13));
        text(this.nome, -this.radius/2-3, 5);
        
        /* numero feats nascosto
        textAlign(LEFT);
        textFont(createFont("Arial", 11));
        text(this.aura, this.radius/2+3, 5);
        */
      } else {
        scale(1, 1);

        textAlign(LEFT);
        textFont(createFont("Arial", 13));
        text(this.nome, this.radius/2+3, 5);
        
        /* numero feats nascosto
        textAlign(RIGHT);
        textFont(createFont("Arial", 11));
        text(this.aura, -this.radius/2-3, 5);
        */
      }

      scale(1, 1);
      popMatrix();
    } else {
      fill(255);
      textAlign(CENTER);
      textFont(createFont("Arial", 13));
      text(this.nome, this.xPos, this.yPos);
      textFont(createFont("Arial", 11));
      text("feats. " + this.aura, this.xPos, this.yPos+10);
    }
  }
}
