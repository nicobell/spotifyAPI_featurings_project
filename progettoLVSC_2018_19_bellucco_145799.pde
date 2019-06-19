import http.requests.*;
import java.util.Base64;

String CLIENTID = "8d1bd0beb84948929afa42f792e4e32f";
String CLIENTSECRET = "91a8d6ad7c304f278c7170bdb005fe76";
String baseURL = "https://api.spotify.com/v1/";
String TOKEN;

String[] artisti = {};

String[] pop = {"Jovanotti", "Mahmood", "Tommaso Paradiso", "Coez", "Elisa"};
String[] rap = {"Gemitaiz", "Salmo", "Fabri Fibra", "MadMan", "Priestess", "Nitro"};
String[] trap = {"Ghali", "Sfera Ebbasta", "Rkomi", "Achille Lauro", "Lazza"};
String[] indie = {"Franco126", "Carl Brave", "Calcutta ", "Willie Peyote", "Frah Quintale"};


ArrayList<Artista> cantanti = new ArrayList<Artista>();
ArrayList<Artista> nascosti;
ArrayList<Link> pallini = new ArrayList<Link>();

//selezione artista
int moving;
int selected = -1;
int prevSelected = -1;
int collegato = -1;
int linked = -1;
int balet;

//visualizzazione dettagli
Boolean found = false;
Boolean toggleCollabs = false;

int livello = 0;

void setup() {

  //size(800, 600);
  fullScreen();

  println("Loading ...");

  //carica eventuali nuove richieste
  if (artisti.length > 0) {
    byte[] encode = Base64.getEncoder().encode((CLIENTID+":"+CLIENTSECRET).getBytes());
    PostRequest post = postAuth(encode);  
    TOKEN = parseJSONObject(post.getContent()).getString("access_token");
    loadData(TOKEN, 2);
  }

  //carica i file JSON già calcolati
  loadJSON(pop, 1);
  loadJSON(rap, 2);
  loadJSON(trap, 3);
  loadJSON(indie, 4);

  loadDurations();

  println("Fine caricamento!");

  grafico();
}

void draw() {
  livello0_wrapper();
}

void mousePressed() {
  if (livello == 0) {
    Boolean trovato = false;
    for (int i = 0; i < pallini.size(); i++) {
      Link pall = pallini.get(i);
      if (dist(mouseX, mouseY, pall.getCX(), pall.getCY()) < 5) {
        balet = i;
        trovato = true;
        //println("from " + pall.getA().getNome() + " to " + pall.getB().getNome());
        //println(pall.getSongs());
        disegnaBarre(pall);
      }
    }
    if (trovato) linked = balet;
    else linked = -1;

    //cerca il primo cantante vicino al punto di click
    for (int j = 0; j < cantanti.size(); j++) {
      Artista c = cantanti.get(j);

      if ( dist(mouseX, mouseY, c.getXPos(), c.getYPos()) < (c.getAura()+c.getRadius())/2 ) {
        found = true;
        moving = j;
        collegato = j;
      }
    }

    //se clicco fuori de-seleziona artista
    if (found) { 
      selected = moving;
    } else { 
      selected = -1;
    }

    if (selected == prevSelected) toggleCollabs = !toggleCollabs;
    else toggleCollabs = true;

    if (selected==-1) toggleCollabs = false;

    if (toggleCollabs) drawCollabs();

    prevSelected = selected;
  }
}

void mouseDragged() {
  if (livello == 0) 
    moveArtist(moving, moving);
}

void mouseReleased() {
  moving = -1;
  //println(mouseX + " " + mouseY);
  //println("moving: \t" + moving + ", selected: \t" + selected + ", collegato: \t" + collegato);
}
