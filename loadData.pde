void loadJSON(String[] nomi, int col) {
  for (int i = 0; i < nomi.length; i++) {
    JSONObject file = loadJSONObject("data/"+nomi[i]+"_final.json");

    int q = 0;
    for (int j = 0; j < file.getJSONArray("feats").size(); j++) {
      if (file.getJSONArray("feats").getJSONObject(j).getString("name").equals(file.getString("artistName")))
        q = file.getJSONArray("feats").getJSONObject(j).getInt("appears");
    }

    Artista art = new Artista(file.getString("artistName"), file.getString("profile"));
    art.setAura(q);

    art.setFeats(file.getJSONArray("feats"));
    art.setIdFeats(file.getJSONArray("idFeats"));

    int o = 150;
    switch(col) {
    case 1:
      art.setColor(#0b4f6c, o);
      break;
    case 2:
      art.setColor(#ba2d0b, o);
      break;
    case 3:
      art.setColor(#6B017C, o);
      break;
    case 4:
      art.setColor(#ffc857, o);
      break;
    default:
      art.setColor(#1ed760, o);
      break;
    }
    cantanti.add(art);
  }
}

void loadDurations() {
  byte[] encode = Base64.getEncoder().encode((CLIENTID+":"+CLIENTSECRET).getBytes());
  PostRequest post = postAuth(encode);  
  TOKEN = parseJSONObject(post.getContent()).getString("access_token");

  for (int i = 0; i < cantanti.size(); i++) {
    JSONObject ds = new JSONObject();
    /*if (cantanti.get(i).getNome() != "Franco126"
      && cantanti.get(i).getNome() != "Carl Brave"
      && cantanti.get(i).getNome() != "Coez") {*/
      println("canzoni di "+cantanti.get(i).getNome()+" ...");
      for (int j = 1; j < cantanti.get(i).getIdFeats().size(); j++) {
        println(cantanti.get(i).getIdFeats().getJSONObject(j).getString("name"));
        for (int k = 0; k < cantanti.get(i).getIdFeats().getJSONObject(j).getJSONArray("ids").size(); k++) {
          String nome = cantanti.get(i).getIdFeats().getJSONObject(j).getJSONArray("ids").getString(k);
          GetRequest get = new GetRequest(baseURL + "tracks/" + nome);
          get.addHeader("Authorization", "Bearer " + TOKEN);
          get.send();
          int d = parseJSONObject(get.getContent()).getInt("duration_ms");
          int p = parseJSONObject(get.getContent()).getInt("popularity");
          JSONObject nuovo = new JSONObject();
          nuovo.setInt("d", d);
          nuovo.setInt("p", p);
          ds.setJSONObject(nome, nuovo);
        }
      }
      saveJSONObject(ds, "data/"+cantanti.get(i).getNome()+"_durations.json");
    }
  //}

  //saveJSONObject(ds, "data/pops.json");
}

void loadData(String TOKEN, int index) {
  //PER OGNI ARTISTA NELL'ARRAY ...
  for (int w = 0; w < artisti.length; w++) {
    if (!artisti[w].equals("Franco126") || !artisti[w].equals("Carl%20Brave") || !artisti[w].equals("Coez")) {
      //... CERCA ARTISTA PER NOME E TROVA ID
      GetRequest get = new GetRequest(baseURL + "search?q="+artisti[w]+"&type=artist");
      get.addHeader("Authorization", "Bearer " + TOKEN);
      get.send();
      saveJSONObject(parseJSONObject(get.getContent()), "data/risultati.json");
      //println(get.getContent());

      JSONObject json = parseJSONObject(get.getContent());
      JSONObject a = json.getJSONObject("artists").getJSONArray("items").getJSONObject(index);
      String nome = a.getString("name");
      String id = a.getString("id");
      String profile = "images/"+nome+"Profile.jpg";//a.getJSONArray("images").getJSONObject(0).getString("url");
      PImage m = loadImage(a.getJSONArray("images").getJSONObject(0).getString("url"), "jpg");
      m.save("images/"+nome+"Profile.jpg");

      cantanti.add(new Artista(nome, profile));

      //PARAMETRI RICERCA ALBUM
      //50 album alla volta
      int lim = 50, offset = 0;
      //per evitare duplicati cerca nel mercato italiano
      String paese = "IT";
      //condizioni di SELEZIONE CANZONE :
      //se l'album è presente nel mercato, se la canzone non è già stata analizzata e se l'artista è tra i partecipanti 
      Boolean pres = false, unico = true, part = false;
      //totale per ciclare in base a offset e limite (obbligo per API Spotify)
      //aggiornato alla prima chiamata per evitare chiamata esterna in più!
      int total = 0;
      //println("total: " + total);

      //array di supporto per controllare album/canzoni già analizzati ed evitare errori nei duplicati
      ArrayList<String> hash = new ArrayList<String>();
      ArrayList<String> songHash = new ArrayList<String>();
      ArrayList<String> idHash = new ArrayList<String>();

      do {
        //successivi n album dell'artista in questione vengono analizzati, stampo l'artista per vedere la situazione dei cicli
        println(nome + " ...");

        //RICERCA ALBUM PER ARTISTA
        GetRequest get4 = new GetRequest(baseURL + "artists/" + id + "/albums?limit="+lim+"&offset="+offset);
        get4.addHeader("Authorization", "Bearer " + TOKEN);
        get4.send();
        JSONObject json4 = parseJSONObject(get4.getContent());
        //aggiorna totale esterno ad ogni ciclo ma rimane sempre uguale perchè indica gli album totali
        //e non quelli del frammento analizzato
        total = json4.getInt("total");

        //ALBUM TROVATI
        JSONArray albums = json4.getJSONArray("items");

        //PER OGNI ALBUM CERCA LE COLLABORAZIONI TRA ARTISTI IN DIVERSI STEP
        for (int i = 0; i < albums.size(); i++) {

          //COMPILATION ESCLUSE PERCHè NON COLLABORAZIONI DIRETTE (a meno di canzoni feat. --> TODO)
          //if (true) { //!albums.getJSONObject(i).getString("album_type").equals("compilation")) {

          //1) FILTRA SOLO QUELLI PRESENTI NEL MERCATO ITALIANO
          for (int j = 0; j < albums.getJSONObject(i).getJSONArray("available_markets").size(); j++) {
            String market = albums.getJSONObject(i).getJSONArray("available_markets").getString(j);
            if (market.equals(paese)) {
              pres = true;
            }
          }

          //2) CONTROLLA SE L'ALBUM è GIà STATO ANALIZZATO
          //controlla per nome e non per id poichè i duplicati hanno id diversi ma lo stesso nome
          //poichè si tratta dello stesso album (es: album di Elisa per Calcutta)
          if (pres) {
            for (int k = 0; k < hash.size(); k++) {
              if (hash.get(k).equals(albums.getJSONObject(i).getString("name")))
                unico = false;
            }
          }

          //3) SE ENTRAMBI I FLAG SONO POSITIVI ...
          if (pres && unico) {

            //... AGGIUNGI IN ELENCO E ANALIZZA
            hash.add(albums.getJSONObject(i).getString("name"));
            String albumid = albums.getJSONObject(i).getString("id");

            //1) CERCA LE CANZONI DELL'ALBUM IN QUESTIONE
            GetRequest get2 = new GetRequest(baseURL + "albums/" + albumid + "/tracks");
            get2.addHeader("Authorization", "Bearer " + TOKEN);
            get2.send();
            JSONObject json2 = parseJSONObject(get2.getContent());

            //NON DOVREBBERO ESSERCI CANZONI DUPLICATE POICHè PRENDIAMO SEMPRE ALBUM DIVERSI
            //2) PER OGNI CANZONE DELL'ALBUM (suo proprio o in cui appare di altri), PRENDI GLI ARTISTI
            for (int x = 0; x < json2.getJSONArray("items").size(); x++) {

              JSONArray trackartists = json2.getJSONArray("items").getJSONObject(x).getJSONArray("artists");

              //3) SE SONO PIù DI 1, CONTROLLA SE L'ARTISTA IN QUESTIONE PARTECIPA
              //per gli album in cui appare dove ci sono collab che non lo riguardano
              if (trackartists.size() > 1) {

                for (int y = 0; y < trackartists.size(); y++) {
                  if (trackartists.getJSONObject(y).getString("name").equals(nome)) {
                    part = true;
                  }
                }

                String canzone = json2.getJSONArray("items").getJSONObject(x).getString("name");
                String canzoneID = json2.getJSONArray("items").getJSONObject(x).getString("id");

                //4) CANCELLA ANCHE CANZONI REMIX, Instrumental o Live che rappresentano canzoni non originali
                //se una canzone è cantata in feat in live, ma nell'album originale non è un feat, non viene considerata
                //solo se la nuova versione feat è registrata come singolo o in un album successivamente, verrà contata
                for (int u = 0; u < songHash.size(); u++) {
                  if (songHash.get(u).equals(canzone)
                    //queste condizioni più efficienti eliminano canzoni, da debuggare (?)
                    //match(songHash.get(u), canzone)!=null
                    //|| match(canzone, songHash.get(u))!=null
                    || (match(canzone, "Remix")!=null
                    || match(canzone, "RMX")!=null
                    || match(canzone, "Mix")!=null
                    || match(canzone, "mix")!=null
                    || match(canzone, "remix")!=null 
                    || match(canzone, "Bootleg")!=null)
                    || match(canzone, "Instrumental")!=null
                    || match(canzone, "version")!=null
                    || match(canzone, "Version")!=null 
                    || match(canzone, "REMIX")!=null
                    || match(canzone, "Live")!=null) {
                    unico = false;
                  }
                }

                //5) NUOVAMENTE, SE I FLAG SONO POSITIVI ...
                //quindi se l'artista partecipa a una canzone insieme ad altri, 
                if (part && unico) {
                  println(canzone);
                  for (int v = 0; v < trackartists.size(); v++) {
                    //... AGGIUNGE L'ELEMENTO COME DESCRITTO NELLA CLASSE E REGISTRA IL FEATURING
                    cantanti.get(w).addFeat(trackartists.getJSONObject(v).getString("name"), canzone);
                    cantanti.get(w).addIdFeat(trackartists.getJSONObject(v).getString("name"), canzoneID);
                  }

                  //aggiungo la canzone al rispettivo hash per futuri controlli nei prossimi album
                  songHash.add(json2.getJSONArray("items").getJSONObject(x).getString("name"));
                  idHash.add(json2.getJSONArray("items").getJSONObject(x).getString("id"));
                }

                //risetta il parametro per finire di controllare l'album
                part = false;
                unico = true;
              }
            }
          }
          //println(idHash.size() + " " + songHash.size());
          //6) SETTA NUOVAMENTE I PARAMETRI PER IL PROSSIMO ALBUM DA ANALIZZARE
          //fino alla fine degli album dell'artista
          pres = false;
          unico = true;
        }

        //CICLO LE "PAGINE" DEI RISULTATI
        offset += lim;
      } while (offset < total);

      //println(cantanti.get(w).getFeats());
      //SALVO I DATI DELL'ARTISTA ANALIZZATO IN UN JSON SPECIFICO
      JSONObject collab = new JSONObject();
      collab.setString("artistName", cantanti.get(w).getNome());
      collab.setString("profile", cantanti.get(w).getProfile());
      collab.setInt("aura", cantanti.get(w).getAura());
      collab.setJSONArray("feats", cantanti.get(w).getFeats());
      collab.setJSONArray("idFeats", cantanti.get(w).getIdFeats());
      if (cantanti.get(w).getFeats().size() > 0)
        cantanti.get(w).setAura(cantanti.get(w).getFeats().getJSONObject(0).getInt("appears"));
      else {
        println("FEATURINGS NOT FOUND FOR "+nome);
        cantanti.remove(w);
      }
      saveJSONObject(collab, "data/"+nome+"_final.json");
    }
  }
}

PostRequest postAuth(byte[] encode) {
  //POST AUTHORIZATION
  PostRequest post = new PostRequest("https://accounts.spotify.com/api/token");
  post.addData("grant_type", "client_credentials");
  post.addHeader("Authorization", "Basic " + new String(encode));
  post.send();
  return post;
}

void loadFeC() {
  byte[] encode = Base64.getEncoder().encode((CLIENTID+":"+CLIENTSECRET).getBytes());
  PostRequest post = postAuth(encode);  
  TOKEN = parseJSONObject(post.getContent()).getString("access_token");

  GetRequest get = new GetRequest(baseURL + "search?q=Carl%20Brave%20X%20Franco%20126&type=artist");
  get.addHeader("Authorization", "Bearer " + TOKEN);
  get.send();

  String id = parseJSONObject(get.getContent()).getJSONObject("artists").getJSONArray("items").getJSONObject(0).getString("id");

  GetRequest get2 = new GetRequest(baseURL + "artists/" + id + "/albums");
  get2.addHeader("Authorization", "Bearer " + TOKEN);
  get2.send();

  //println(get2.getContent());

  ArrayList<String> f = new ArrayList<String>();
  ArrayList<String> n = new ArrayList<String>();

  for (int i = 0; i < parseJSONObject(get2.getContent()).getJSONArray("items").size(); i++) {
    String id2 = parseJSONObject(get2.getContent()).getJSONArray("items").getJSONObject(i).getString("id");
    GetRequest get3 = new GetRequest(baseURL + "albums/" + id2 + "/tracks");
    get3.addHeader("Authorization", "Bearer " + TOKEN);
    get3.send();

    for (int j = 0; j < parseJSONObject(get3.getContent()).getJSONArray("items").size(); j++) {
      f.add( parseJSONObject(get3.getContent()).getJSONArray("items").getJSONObject(j).getString("id"));
      n.add( parseJSONObject(get3.getContent()).getJSONArray("items").getJSONObject(j).getString("name"));
    }
  }
  println(f);
  println(n);
  JSONObject ff = new JSONObject();

  for (int k = 0; k < f.size(); k++) {
    GetRequest get4 = new GetRequest(baseURL + "tracks/" + f.get(k));
    get4.addHeader("Authorization", "Bearer " + TOKEN);
    get4.send();
    int d = parseJSONObject(get4.getContent()).getInt("duration_ms");
    int p = parseJSONObject(get4.getContent()).getInt("popularity");
    JSONObject cc = new JSONObject();
    cc.setInt("d", d);
    cc.setInt("p", p);
    ff.setJSONObject(f.get(k), cc);
  }

  saveJSONObject(ff, "francoecarlo.json");
  println("fine");
}
