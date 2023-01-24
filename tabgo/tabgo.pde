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
 * Last Revision: 24/01/2023
 * 
 *
 * utilise OpenCV 4.52 (12/10/20)
 * nettoyage du code (01/12/20)
 * création machine à états, changement de nom pour TaBGO (02/12/20)
 * ajout webcam + mode "T"est (03/12/20)
 * ajout du feedback audio via la librairie ttslib (05/05/21)
 * modification de l'exemple de test
 * utilisation de ttslib "home-made" pour compatibilité Processing 4.0 (20/10/2020)
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
 *  - Ajout et automatisation du bloc de définition Récupération des données : 
 *       Fonctionnement des call et définition de bloc custom
 *       Utilisation possible de plusieurs bloc de départ
 *       Fonctionnement des listes : hidelist, showlist, deletealloflist, itemoflist, addtolist
 *       Variable privées : listtemp, listexport, FIN
 *       Variable chatparle à utiliser si on ajoute le son dans l'exécution (pas celui du feedback) 
 *       Modification de la documentation appropriée
 *  - Ajout d'un fichier dans le dossier tabgo pour les topcodes des variables privées
 *  - Ajout de tests et explications du résultat attendu
 * Last Revision: 19/07/2022
 *
 * vérification pointeurs (20/06/22)
 * copie profonde des blocs (23/06/22) 
 * ajout des variables (23/06/22)
 * correction liste TopCodes (24/06/22)
 * implémentation des blocs customs et plusieurs blocs de départ possibles (5/07/22)
 * implémentation des listes (6/07/22)
 * variables listes, FIN, chatparle (8/07/22)
 * automatisation de la récupération de données (8/07/22)
 * modification doc et ajout fichier sur variables privées (18/07/22)
 * création de tests et explications (19/07/22)
 
 * modification TTS (20/10/22)
 * ajout drag and drop images (23/01/23) et corrections (24/01/23)
 */

// import librairies
import java.awt.Rectangle;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
// Drag and drop capabilities
import drop.*;

import org.opencv.core.MatOfPoint2f;
import org.opencv.core.RotatedRect;
import org.opencv.imgproc.Imgproc;
import org.opencv.imgproc.Moments;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import gab.opencv.Contour;
import processing.core.*;
import processing.video.*;

import eu.upssitech.ttslib.*;

// variables
  private PImage src, destination;
  private Capture cam;
  protected Scanner scanner;
  private Gson gson;
  private PFont f;
  
  private SDrop drop;
  
  public enum FSM { 
      INITIAL, // Etat initial
      CREATION, // création de l'algorithme
      DND, // drag and drop
    }     

  private FSM mae; // Finite State Machine
  
  private GestionBlocks g;
  private TTS tts;
  private TopCodesP  ts;
  private List<TopCode> codes;
  private DetectionCube maDetect;
  private int indCam;
  private String[] listCams;
  
  // boolean to allow automatic added code for accessibility (false by default)
  private boolean addCodeAccessibility = false;
  
  public void settings() {
    size(800,600);
  }
  
  public void setup() {    
    GsonBuilder builder = new GsonBuilder();
    builder.serializeNulls();
    gson = builder.create();
    g = new GestionBlocks();
    // all concerning font 
    f = loadFont("B612-Bold-20.vlw");
    
    drop = new SDrop(this);
    
    tts = new TTS();
    mae = FSM.INITIAL;
    indCam = 0;
    listCams = Capture.list();
    try {
      cam = new Capture(this,800,600, listCams[0]);
    }
    catch (ArrayIndexOutOfBoundsException aiobe) {
      cam = new Capture(this, 800,600, "pipeline:autovideosrc"); // essaye la caméra interne
    }
    cam.start();
    
  }
  
  public void draw() {
    switch (mae) {
      case INITIAL:
        image(cam,0,0); 
        fill(49,49,49);
        textSize(20);
        textFont(f);
        text("Pour lancer l'exécution, appuyez sur la touche \" espace \"",10,20);
        text("Pour lancer un test, appuyez sur la touche \" T \"",10,40);
        text("Pour un drag and drop, appuyez sur la touche \" I \"",10,60);
        text("Pour changer de caméra, appuyez sur la touche \" C \"",10,80);
        affichage();
        break;
        
      case CREATION: // creation de l'algorithme  
        text("Création du prgramme en cours ",10,100);
        creation(src);
        mae=FSM.INITIAL;
        src = null;
        break;
      
      case DND: // attente drag and drop
        background(255);
        fill(49,49,49);
        textSize(20);
        textFont(f);
        text("Glissez-Déposez votre photographie sur la fenêtre TaBGo",10,20);
        if (src != null)
          mae=FSM.CREATION;
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
        // Drag and drop
        case 'I':
        case 'i':             
            mae = FSM.DND;
          break;
          
        
        // Pour lancer une image test
        case 'T':
        case 't':
          String im = dataPath("")+"/tests/test_S9.png";
          src = loadImage(im);
          tts.speak("Starting test");
          mae = FSM.CREATION;
          break;
         
        // Pour changer de caméra
        case 'C':
        case 'c':
          tts.speak("Changing webcam");
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
    
    
    // Detection des cubes
     println("__DETECTION DES CUBES__");
     maDetect = new DetectionCube(src);
     println("Nombre de cubes trouvés : " + maDetect.getListCubes().size());
  
    // *** ajout du code supplémentaire (option à activer) ***
    if (addCodeAccessibility)
      if (!ts.codes.isEmpty()){
        Automatique auto = new Automatique();
        auto.traite(ts, maDetect);
      }  
   
    // Construire l'algorithme 
    println("__CONSTRUCTION DE L'ALGORITHME__");
    FiltrageCubes fc = new FiltrageCubes(); 
    
    List<Blocks> listBlocks = fc.construitAlgorithme(ts.getCodes(), maDetect.getListCubes(),g);  
    println("Nombre de blocks : " + listBlocks.size()); 
    
    /* Affichage des blocks : Numéro : opcode, inputs, fields, next, parent, mutation 
     * À décommenter pour l'affichage 
     
    int i = 0;
    for ( Blocks bl : listBlocks){
      if (bl instanceof BlockCustoms){
        BlockCustoms bc = (BlockCustoms)bl;
        println("block" + i + " : " + bc.opcode + ", " + bc.inputs + ", " + bc.fields + ", " + bc.next + ", " + bc.parent + ", " + bc.mutation + ", " + bc.topLevel);
      } else {
        println("block" + i + " : " + bl.opcode + ", " + bl.inputs + ", " + bl.fields + ", " + bl.next + ", " + bl.parent + ", " + bl.topLevel);
      }
      i++;
    }
    */
    
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
  
void dropEvent(DropEvent theDropEvent) {
  // println("\nisFile()\t"+theDropEvent.isFile());
  // println("isImage()\t"+theDropEvent.isImage());
  // println("isURL()\t"+theDropEvent.isURL());  
  // if the dropped object is an image, then load the image into our PImage
  if(theDropEvent.isImage()) {
    // println("### loading image ...");
    // println("Where: " + theDropEvent.filePath());
    src = loadImage(theDropEvent.filePath());
    // println("### image loaded ... Taille : " + src.width + " " + src.height);
  }
  else 
    src = null;
}
  
  
  
  
  
  
  
  
  
  
