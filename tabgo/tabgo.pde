/*
 * TaBGO - Tangible Blocks Go Online
 * First prototype by Jean-Baptiste Marco (summer 2018)
 * Original code by Léa Berquez (summer 2020)
 * Adapté et amélioré par l'équipe du Bureau d'étude "TabGo" suivi par Philippe Truillet en 2021 :
 *  - Changement de la génération du JSON grâce à la librairie GSON
 *  - Nouvelle prise en charge des blocs et TopCode (nouvelle implémentation)
 *  - Amélioration de la détection des cubarithmes
 *  - Ajout du feedback audio
 *
 * Last Revision: 30/05/2022
 * 
 *
 * utilise OpenCV 4.52 (12/10/20)
 * nettoyage du code (01/12/20)
 * création machine à états, changement de nom pour TaBGO (02/12/20)
 * ajout webcam + mode "T"est (03/12/20)
 * ajout du feedback audio via la librairie ttslib (05/05/21)
 * modification de l'exemple de test
 *
 *
 * Amélioré par Mathieu Campan suivi par Philippe Truillet en été 2022 :
 *  - Résolution erreur changement caméra unique
 *  - Résolution erreur utilisation du bloc modifié après appel : copie profonde des blocs (pour qu'ils ne référencent pas la même zone)
 *  - Ajout de variables initialisées pour faciliter la programmation des élèves : quart = 90, demi = 180 (topcodes 403, 405 resp.)
 *  - Modification blocs.csv => Field blocs data_variables; 
 *                              Ajout lignes pour variables quart, demi, var1, var2
 *                              Ajout ligne pour control_fin
 *  - Modification documentation : Lignes var1, mettre ... à ... => mettre ... à ..., ajouter ... à ...
 *                                 Ajout lignes documentation pour variables : quart, demi, var1, var2
 *                                 Ligne si ... alors ... sinon renommée => sinon, dû à son utilisation (topcode 91)
 *                                 Correction nom ligne Fin de boucle => Stop tout (topcode 103)
 *                                 Ajout ligne Fin boucle / Fin si (topcode 93)
 * Last Revision: 29/06/2022
 *
 * vérification pointeurs (20/06/22)
 * copie profonde des blocs (23/06/22) 
 * ajout des variables (23/06/22)
 * correction liste TopCodes (24/06/22)
 *
 * 
 */

// import librairies
import java.awt.Rectangle;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.opencv.core.MatOfPoint2f;
import org.opencv.core.RotatedRect;
import org.opencv.imgproc.Imgproc;
import org.opencv.imgproc.Moments;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import gab.opencv.Contour;
import processing.core.*;
import processing.video.*;

import guru.ttslib.*;

// variables
  private PImage src, destination;
  private Capture cam;
  protected Scanner scanner;
  private Gson gson;
  private PFont f;
  
  
  public enum FSM { 
      INITIAL, // Etat initial
      CREATION, // création de l'algorithme
    }     

  private FSM mae; // Finite State Machine
  
  private GestionBlocks g;
  private TTS tts;
  private TopCodesP  ts;
  private List<TopCode> codes;
  private DetectionCube maDetect;
  private int indCam;
  private String[] listCams;
  
  
  public void settings() {
    size(640,480);
  }
  
  public void setup() {    
    GsonBuilder builder = new GsonBuilder();
    builder.serializeNulls();
    gson = builder.create();
    g = new GestionBlocks();
    // all concerning font 
    f = loadFont("B612-Bold-20.vlw");
    
    tts = new TTS();
    mae = FSM.INITIAL;
    indCam = 0;
    listCams = Capture.list();
    try {
      cam = new Capture(this,listCams[0]);
    }
    catch (ArrayIndexOutOfBoundsException aiobe) {
      cam = new Capture(this, "pipeline:autovideosrc"); // essaye la caméra interne
    }
    cam.start();
    
  }
  
  public void draw() {
    switch (mae) {
      case INITIAL:
        image(cam,0,0); 
        fill(0,0,0);
        textSize(20);
        textFont(f);
        text("Pour lancer l'exécution, appuyez sur la touche \" espace \"",10,20);
        text("Pour lancer un test, appuyez sur la touche \" T \"",10,40);
        text("Pour changer de caméra, appuyez sur la touche \" C \"",10,60);
        affichage();
        break;
        
      case CREATION: // creation de l'algorithme  
        creation(src);
        mae=FSM.INITIAL;
        break;
      
      default :
        break;
    }
  }
  
  public void captureEvent(Capture c) { // when an image is available
      c.read();
    }

  public void keyPressed(){
    // Temporaire 
    if (mae==FSM.INITIAL){
      switch (key) {
       
        // Pour lancer une image test
        case 'T':
        case 't':
          String im = dataPath("")+"/tests/test_S5.png";
          src = loadImage(im);
          tts.speak("Starting test");
          mae = FSM.CREATION;
          break;
         
        // Pour changer de caméra
        case 'C':
        case 'c':
          tts.speak("Changing camera");
          indCam++;
          cam.stop();
          if (listCams.length > 0){
            cam = new Capture(this,listCams[indCam % listCams.length]);
          }
          cam.start();
          break;
     
        case ' ':
          src = cam.copy();
          tts.speak("Creating File");
          mae = FSM.CREATION;
          break;
        }
     } 
  }

  // creation de l'agorithme 
  public void creation(PImage im){
    FileExecution fe; 
    // Pour détection des cubes
    destination = im.copy();
    
    scanner = new Scanner();
    BufferedImage b = (BufferedImage) src.getNative();
    codes = scanner.scan(b); 
    
    // Récupération des TopCodes 
    println("__DETECTION DES TOPCODES__");
    ts = new TopCodesP(); 
    ts.findTopCodes(codes);   
    println("Nombre TopCodes trouvés : " + ts.getCodes().size()); 
    
    
    if (!ts.codes.isEmpty()){
      /* Ajout des TopCodes pour les variables */
      ajoutVariablesTP(ts);            
    }
    // Detection des cubes
     println("__DETECTION DES CUBES__");
     maDetect = new DetectionCube(src);
     println("Nombre de cubes trouvés : " + maDetect.getListCubes().size());
  
    if (!ts.codes.isEmpty()){
      /* Ajout des Cubarithmes pour les variables */
      ajoutVariablesCb(ts, maDetect);            
    }  
   
    // Construire l'algorithme 
    println("__CONSTRUCTION DE L'ALGORITHME__");
    FiltrageCubes fc = new FiltrageCubes(); 
    
    List<Blocks> listBlocks = fc.construitAlgorithme(ts.getCodes(), maDetect.getListCubes(),g);  
    println("Nombre de blocks : " + listBlocks.size()); 
    
    /* Affichage des blocks : Numéro : opcode, inputs, fields, next, parent */
    /* A décommenter pour l'affichage */
    for ( Blocks bl : listBlocks){
       println("block : " + bl.opcode + ", " + bl.inputs + ", " + bl.fields + ", " + bl.next + ", " + bl.parent);
    }
    
    
    //Génération du JSON
    println("__GENERATION DU JSON__");
    String json = gson.toJson(new MainScratch(listBlocks));
    // File Execution pour créer le fichier 
    fe = new FileExecution(); 
    fe.fileE(json,tts);  
  }


  // Affichage des résultats
  public void affichage() {
    destination = cam.copy();
    destination.loadPixels();
    scanner = new Scanner();
    BufferedImage b = (BufferedImage) destination.getNative();
    codes = scanner.scan(b); 
    
    // Affichage des TopCodes
    ts = new TopCodesP(); 
    ts.findTopCodes(codes);  
    for(TopCode tp : codes){
      fill(255,255,255);
      circle(tp.getCenterX(),tp.getCenterY(),tp.getDiameter());
      fill(0,0,0);
      text(tp.getCode(),tp.getCenterX(),tp.getCenterY());
    }
    
    //Affichage des Cubarithmes
    maDetect = new DetectionCube(destination);
    for(Cube cube : maDetect.getListCubes()){
      cube.dessineCube();
    }
  }
  
  /**
   * Rajoute à la liste des TopCodes les TopCodes nécessaires pour initialiser les variables quart et demi à 90 et 180 resp.
   * On va les rajouter de la forme : 
   * Set x x 9 5 2 quart  => quart = (9 x 5) x 2
   * Set x quart 2 demi   => demi = quart x 2
   * @param TopCodesP ts liste des TopCodes
  */
  void ajoutVariablesTP(TopCodesP ts){
    float ymax;
    if (ts.codes == null || ts.codes.size() <= 1){
      // S'il n'y a qu'un bloc de départ
      ymax = 100;
    } else {
      ymax = (ts.codes.get(1)).getCenterY();
    }

    TopCode sauv = ts.codes.get(0);
    sauv.setLocation(sauv.getCenterX(),0);
    
    /* Set */
    TopCode setquart = new TopCode();
    setquart.setCode(369);
    TopCode setdemi = new TopCode();
    setdemi.setCode(369);
    
    /* Quart de tour : 90 */
    /* Input */
    /* 90 = 9 * 5 * 2 (cubarithmes) */
    TopCode fois1 = new TopCode();
    fois1.setCode(299);
    fois1.setLocation(sauv.getCenterX()+10, ymax/3);
    
    TopCode fois2 = new TopCode();
    fois2.setCode(299);
    fois2.setLocation(sauv.getCenterX()+20, ymax/3);
    
    ts.codes.addFirst((fois1));
    ts.codes.addFirst((fois2));
    
    /* Field */
    TopCode quart = new TopCode();
    quart.setCode(403);
    quart.setLocation(sauv.getCenterX()+60,ymax/3);
    setquart.setLocation(sauv.getCenterX(), ymax/3);
    
    ts.codes.addFirst(quart);
    ts.codes.addFirst(setquart);
    
    /* Demi-tour : 180 */
    /* Input */
    /* 180 = 90 * 2 (variable et cubarithme) */
    TopCode fois3 = new TopCode();
    fois3.setCode(299);
    fois3.setLocation(sauv.getCenterX()+10, 2*ymax/3);

    TopCode quartint = new TopCode();
    quartint.setCode(403);
    quartint.setLocation(sauv.getCenterX()+20,2*ymax/3);
    
    ts.codes.addFirst(fois3);
    ts.codes.addFirst((quartint));
    
    /* Field */
    TopCode demi = new TopCode();
    demi.setCode(405);
    demi.setLocation(sauv.getCenterX()+60, 2*ymax/3);
    setdemi.setLocation(sauv.getCenterX(), 2*ymax/3);
    
    ts.codes.addFirst(demi);
    ts.codes.addFirst(setdemi);
    
        
    
    /* On trie les codes pour les avoir dans la liste dans l'ordre voulu */
    ts.triCodes(ts.codes);
   
  }
  
  
  /**
   * Rajoute les cubarithmes nécessaire au calcul des variables : 9, 5, 2 pour 90, et 2 pour 180
   * @param TopCodes ts contient la liste des TopCodes pour obtenir les coordonées où mettre les cubarithmes
   * @param DetectionCube dc contient la liste des cubes
  */
  void ajoutVariablesCb(TopCodesP ts, DetectionCube dc){
      /* Cubes 9, 5, 2 : même ordonnée, différente abscisse*/
      PVector p[] = new PVector[4];
      for (int j = 1; j < 4; j++){
        TopCode tc = ts.codes.get(1);
        p = new PVector[4];
        for (int i = 0; i < 4; i++){
          p[i] = new PVector();
        }
        // Bords du cube
        p[0].x = tc.getCenterX()+ 10 * (2+j) - 5 ;
        p[0].y = tc.getCenterY() - 5;
        p[1].x = tc.getCenterX()+ 10 * (2+j) + 5;
        p[1].y = tc.getCenterY() - 5;
        p[2].x = tc.getCenterX()+ 10 * (2+j) + 5;
        p[2].y = tc.getCenterY() + 5;
        p[3].x = tc.getCenterX()+ 10 * (2+j) - 5;
        p[3].y = tc.getCenterY() + 5;
      
        Cube c = new Cube(p[0], p[1], p[2], p[3]);
        c.calculCoordoneesPoints();
        /* Modification manuelle des champs s et n pour simuler les points blanc de braille*/
        switch(j){
        case 1:
          c.s1 = 1;
          c.n1 = 1;
          c.s2 = 0;
          c.n2 = 1;
          c.s3 = 0;
          c.n3 = 1;
          c.s4 = 1;
          c.n4 = 1;
          c.s5 = 1;
          c.n5 = 1;
          c.s6 = 0;
          c.n6 = 1;
          c.monCharacter = '9';
          break;
        case 2:
          c.s1 = 0;
          c.n1 = 1;
          c.s2 = 1;
          c.n2 = 1;
          c.s3 = 1;
          c.n3 = 1;
          c.s4 = 0;
          c.n4 = 1;
          c.s5 = 1;
          c.n5 = 1;
          c.s6 = 0;
          c.n6 = 1;
          c.monCharacter = '5';
          break;
        case 3:
          c.s1 = 0;
          c.n1 = 1;
          c.s2 = 1;
          c.n2 = 1;
          c.s3 = 0;
          c.n3 = 1;
          c.s4 = 1;
          c.n4 = 1;
          c.s5 = 1;
          c.n5 = 1;
          c.s6 = 0;
          c.n6 = 1;
          c.monCharacter = '2';
          break;
        }
        dc.mesCubes.add(c);
      }
    /* Dernier cube : 2 */
    TopCode tc = ts.codes.get(5);
    p = new PVector[4];
    for (int i = 0; i < 4; i++){
      p[i] = new PVector();
    }
    p[0].x = tc.getCenterX()+ 25;
    p[0].y = tc.getCenterY() - 5;
    p[1].x = tc.getCenterX()+ 35;
    p[1].y = tc.getCenterY() - 5;
    p[2].x = tc.getCenterX()+ 35;
    p[2].y = tc.getCenterY() + 5;
    p[3].x = tc.getCenterX()+ 25;
    p[3].y = tc.getCenterY() + 5;
    
    Cube c = new Cube(p[0], p[1], p[2], p[3]);
    c.calculCoordoneesPoints();
    c.s1 = 0;
    c.n1 = 1;
    c.s2 = 1;
    c.n2 = 1;
    c.s3 = 0;
    c.n3 = 1;
    c.s4 = 1;
    c.n4 = 1;
    c.s5 = 1;
    c.n5 = 1;
    c.s6 = 0;
    c.n6 = 1;
    c.monCharacter = '2';    
    dc.mesCubes.add(c);
    dc.trie();
  }
