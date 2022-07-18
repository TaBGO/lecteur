/*
* Cette classe a été créée pour alléger le programme tabgo
* Elle positionne dans la liste des TopCodes et Cubarithmes ceux nécessaires pour implémenter:
* - l'initalisation des variables quart et demi
* - la récupération des données
* @author Mathieu Campan
*/
public class Automatique{
  
  public void traite(TopCodesP ts, DetectionCube dc){
    /* Ajout TopCodes quart, demi et FIN */
    ajoutVariablesTP(ts);
    
    /* Ajout Cubarithmes associés */
    ajoutVariablesCB(ts, dc);
    
    /* Ajout Bloc Définition Récup Données et appels à ce bloc */
    ajoutBlocCustomSauvegardeDonnee(ts,dc);
  }
  
    /**
   * Rajoute à la liste des TopCodes les TopCodes nécessaires pour initialiser les variables quart et demi à 90 et 180 resp,
   * ainsi que FIN à 0;
   * On va les rajouter de la forme : 
   * Set x x 9 5 2 quart  => quart = (9 x 5) x 2
   * Set x quart 2 demi   => demi = quart x 2
   * Set 0 FIN            => FIN = 0
   * @param TopCodesP ts liste des TopCodes
  */
  private void ajoutVariablesTP(TopCodesP ts){
    float ymax;
    int nbblocsy = 4; //nombre de blocs à insérer (sur l'axe y), plus pratique si on veut en rajouter 
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
    TopCode setFIN = new TopCode();
    setFIN.setCode(369);
    
    /* Quart de tour : 90 */
    /* Input */
    /* 90 = 9 * 5 * 2 (cubarithmes) */
    TopCode fois1 = new TopCode();
    fois1.setCode(299);
    fois1.setLocation(sauv.getCenterX()+10, ymax/nbblocsy);
    
    TopCode fois2 = new TopCode();
    fois2.setCode(299);
    fois2.setLocation(sauv.getCenterX()+20, ymax/nbblocsy);
    
    ts.codes.addFirst((fois1));
    ts.codes.addFirst((fois2));
    
    /* Field */
    TopCode quart = new TopCode();
    quart.setCode(403);
    quart.setLocation(sauv.getCenterX()+60,ymax/nbblocsy);
    setquart.setLocation(sauv.getCenterX(), ymax/nbblocsy);
    
    ts.codes.addFirst(quart);
    ts.codes.addFirst(setquart);
    
    /* Demi-tour : 180 */
    /* Input */
    /* 180 = 90 * 2 (variable et cubarithme) */
    TopCode fois3 = new TopCode();
    fois3.setCode(299);
    fois3.setLocation(sauv.getCenterX()+10, 2*ymax/nbblocsy);

    TopCode quartint = new TopCode();
    quartint.setCode(403);
    quartint.setLocation(sauv.getCenterX()+20,2*ymax/nbblocsy);
    
    ts.codes.addFirst(fois3);
    ts.codes.addFirst((quartint));
    
    /* Field */
    TopCode demi = new TopCode();
    demi.setCode(405);
    demi.setLocation(sauv.getCenterX()+60, 2*ymax/nbblocsy);
    setdemi.setLocation(sauv.getCenterX(), 2*ymax/nbblocsy);
    
    ts.codes.addFirst(demi);
    ts.codes.addFirst(setdemi);
    
        
    /* FIN : 0 */
    /* Input vide (cubarithme pas TopCode) */
    /* Field */
    TopCode FIN = new TopCode();
    FIN.setCode(421);
    FIN.setLocation(sauv.getCenterX()+40, 3*ymax/nbblocsy);
    setFIN.setLocation(sauv.getCenterX(), 3*ymax/nbblocsy);
    
    ts.codes.addFirst(FIN);
    ts.codes.addFirst(setFIN);
    
    
    
    /* On trie les codes pour les avoir dans la liste dans l'ordre voulu */
    ts.triCodes(ts.codes);
   
  }
  
  
  /**
   * Rajoute les cubarithmes nécessaire au calcul des variables : 9, 5, 2 pour 90, 2 pour 180 et 0 pour FIN
   * @param TopCodes ts contient la liste des TopCodes pour obtenir les coordonées où mettre les cubarithmes
   * @param DetectionCube dc contient la liste des cubes
  */
  private void ajoutVariablesCB(TopCodesP ts, DetectionCube dc){
    /* Cubes 9, 5, 2 : même ordonnée, différente abscisse*/
    TopCode tc = ts.codes.get(1);
    int tab[] = new int[]{0,1,1,0,0,1};
    addCubarithme(floor(tc.getCenterX())+30, floor(tc.getCenterY()), '9', tab, dc);
  
    tab = new int[]{1,0,0,1,0,1};
    addCubarithme(floor(tc.getCenterX())+40, floor(tc.getCenterY()), '5', tab, dc);
  
    tab = new int[]{1,0,1,0,0,1};
    addCubarithme(floor(tc.getCenterX())+50, floor(tc.getCenterY()), '2', tab, dc);
  
    /* cube demi : 2 */
    tc = ts.codes.get(5);
    tab = new int[]{1,0,1,0,0,1};
    addCubarithme(floor(tc.getCenterX())+30, floor(tc.getCenterY()), '2', tab, dc);
  
    
     /* cube FIN : 0 */
    TopCode tfin = ts.codes.get(9);
    tab = new int[]{0,1,0,1,1,1};
    addCubarithme(floor(tfin.getCenterX())+30, floor(tfin.getCenterY()), '0', tab, dc);
    
    dc.trie();
  }
  
  
  /*
  * Cette fonction sert à récupérer les données du programme : déplacement du chat ou parole
  * Ajoute à la liste des TopCodes des topcodes correspondant à une définition d'un bloc custom 
  * et d'autres correspondant à 2 appels de ce bloc si le drapeau est pressé ou si la barre espace l'est pour lancer le bloc custom
  * Ajoute également à la fin du code de base, un bloc mettant FIN à 1 pour signifier au bloc custom qu'il peut arrêter de boucler
  * @param ToCodesP ts la liste des TopCodes pù l'on va les rajouter
  */
  private void ajoutBlocCustomSauvegardeDonnee(TopCodesP ts, DetectionCube dc){
    /* Récupération des données */
    int x,y;
    x = floor(ts.codes.peekLast().getCenterX());
    y = floor(ts.codes.peekLast().getCenterY())+50;
    
    /* Ajout de FIN */
    TopCode setFIN = new TopCode();
    setFIN.setCode(369);
    setFIN.setLocation(x,y);
    ts.codes.add(setFIN);
    x += 20;
    
    int tab[] = new int[]{1,0,0,0,0,1};
    addCubarithme(x, y, '1', tab, dc);
  
    
    dc.trie();
    x += 20;

    TopCode FIN = new TopCode();
    FIN.setCode(421);
    FIN.setLocation(x,y);
    ts.codes.add(FIN);
    x -= 40;
    y += 50;

    
    /* Appel 1 : event_whenflagcliked */
    TopCode tflag = new TopCode();
    tflag.setCode(31);
    tflag.setLocation(x,y);
    y += 10;
    ts.codes.add(tflag);
    TopCode tcall1 = new TopCode();
    tcall1.setCode(419);
    tcall1.setLocation(x,y);
    y+=30;
    ts.codes.add(tcall1);
    /* Appel 2 : event_whenkeypressed */
    TopCode tspacebar = new TopCode();
    tspacebar.setCode(47);
    tspacebar.setLocation(x,y);
    ts.codes.add(tspacebar);
    y += 10;
    TopCode tcall2 = new TopCode();
    tcall2.setCode(419);
    tcall2.setLocation(x,y);
    ts.codes.add(tcall2);
    
    y += 50;
    
    /* Définition du bloc : TopCode 409 */
    definitionBlocCustom(x,y,ts,dc);
 
    
    
    ts.triCodes(ts.codes);
  }
  
  
  /*
  * Méthode créant le bloc custom de récupération des données au bon endroit
  */
  private void definitionBlocCustom(int x, int y, TopCodesP ts, DetectionCube dc){
    TopCode t = new TopCode();
    t.setCode(409);
    t.setLocation(x,y);
    ts.codes.add(t);
    y += 20;

    // Cache liste_export et liste_temp 
    t = new TopCode();
    t.setCode(457);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
   
    t = new TopCode();
    t.setCode(433);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 20;
    y += 20;
    t = new TopCode();
    t.setCode(457);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
   
    t = new TopCode();
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 20;
    y += 20;

    
    // Vide liste_export et liste_temp     
    
    t = new TopCode();
    t.setCode(551);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode();
    t.setCode(433);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 20;
    y += 20;
    
    t = new TopCode();
    t.setCode(551);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode();
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 20;
    y += 20;


    // Répéter jusqu'à FIN == 1 

    t = new TopCode();
    t.setCode(59);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode();
    t.setCode(313);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode();
    t.setCode(421);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    int tab[] = new int[]{1,0,0,0,0,1};
    addCubarithme(x, y, '1', tab, dc);
 
    x -= 40; // on laisse un += 20 pour symboliser l'alignement
    y += 20;
    /* Si une coordonnée change ou que le chat parle :
       Si non et = x (elem 1 list temp) et = y (elem 2 list temp) = chat_parle (elem 3 list temp) */
    t = new TopCode(); // Si
    t.setCode(55);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode(); // non
    t.setCode(333);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode(); // et
    t.setCode(327);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode(); // =
    t.setCode(313);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode(); // x
    t.setCode(203);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode(); // elem xxx de yyy
    t.setCode(555);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    tab = new int[]{1,0,0,0,0,1}; // 1
    addCubarithme(x, y, '1', tab, dc); 
    x += 20;
    
    t = new TopCode(); // liste_temp
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    // On a ici : Si non ( x == elem 1 de liste temp) et ()
    
    t = new TopCode(); // et
    t.setCode(327);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode(); // =
    t.setCode(313);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode(); // y
    t.setCode(205);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode(); // elem xxx de yyy
    t.setCode(555);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    tab = new int[]{1,0,1,0,0,1}; // 2
    addCubarithme(x, y, '2', tab, dc); 
    x += 20;
    
    t = new TopCode(); // liste_temp
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    // On a ici : Si non ( x == elem 1 de liste temp) et ((y == elem 2 de liste temp) et ())
    
    t = new TopCode(); // =
    t.setCode(313);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode(); // chat_parle
    t.setCode(425);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    t = new TopCode(); // elem xxx de yyy
    t.setCode(555);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    tab = new int[]{1,1,0,0,0,1}; // 3
    addCubarithme(x, y, '3', tab, dc); 
    x += 20;
    
    t = new TopCode(); // liste_temp
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    // On a ici : Si non ( x == elem 1 de liste temp) et ((y == elem 2 de liste temp) et (chat_parle == elem 3 de liste temp))
  
    x -= 18 * 20; // On en garde un pour symboliser l'alignement
    y += 20;
    
    // Vider liste temp 
    t = new TopCode(); 
    t.setCode(551);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
        
    t = new TopCode();
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 20;
    y += 20;
    
    // Ajout x à liste temp
    t = new TopCode();
    t.setCode(563);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    t = new TopCode();
    t.setCode(203);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
        
    t = new TopCode();
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 40;
    y += 20;
 
    // Ajout y à liste temp  
    t = new TopCode();
    t.setCode(563);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    t = new TopCode();
    t.setCode(205);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
        
    t = new TopCode();
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 40;
    y += 20;
   
    // Ajout chat_parle à liste temp 
    t = new TopCode();
    t.setCode(563);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    t = new TopCode();
    t.setCode(425);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
        
    t = new TopCode();
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 40;
    y += 20;
    
    // Ajout liste temp à liste a exporter 
    t = new TopCode();
    t.setCode(563);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    t = new TopCode();
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
        
    t = new TopCode();
    t.setCode(433);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 40;
    y += 20;
    
    // Mettre chat_parle à 0   
    t = new TopCode();
    t.setCode(369);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
 
    tab = new int[]{0,1,0,1,1,1};
    addCubarithme(x, y, '0', tab, dc);
    x += 20;
     
    t = new TopCode();
    t.setCode(425);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 40;
    y += 20;
       
    // Montrer liste temp 
    t = new TopCode();
    t.setCode(465);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;

    t = new TopCode();
    t.setCode(453);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 40; // Pour revenir au niveau du Si
    y += 20;
    
    // Fin Si 
    t = new TopCode();
    t.setCode(93);
    t.setLocation(x,y);
    ts.codes.add(t);
    x -= 20; // Pour revenir au niveau du Répeter
    y += 20;
    
    // Fin Répéter 
    t = new TopCode();
    t.setCode(93);
    t.setLocation(x,y);
    ts.codes.add(t);
    y += 20;
    
    // Montrer liste à exporter    
    t = new TopCode();
    t.setCode(465);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;

    t = new TopCode();
    t.setCode(433);
    t.setLocation(x,y);
    ts.codes.add(t);
    x += 20;
    
    ts.triCodes(ts.codes);
    dc.trie();
  }
   
  /* Méthode privée permettant d'ajouter un cubarithme dans la liste
  * @param int x : une des coordonnées voulue pour le cube
  * @param int y l'autre coordonée voulue pour le cube
  * @param char val : la valeur du cube : '1', '5', 'b' etc
  * @int[] tab : tableau contenant le code en braille du cube : '1' => [1,0,0,0,0,1]
  * La méthode s'occupe de convertir les valeurs pour initialiser le cube
  * @param DetectionCube dc : contient la liste des cubes où l'on veut les ajouter
  */
  private void addCubarithme(int x, int y, char val, int[] tab, DetectionCube dc){
    /* Calcul coordonées du cube */
    PVector []p = new PVector[4];
    for (int i = 0; i < 4; i++){
      p[i] = new PVector();
    }
    p[0].x = x - 5;
    p[0].y = y - 5;
    p[1].x = x + 5;
    p[1].y = y - 5;
    p[2].x = x + 5;
    p[2].y = y + 5;
    p[3].x = x - 5;
    p[3].y = y + 5;
    
    Cube c = new Cube(p[0], p[1], p[2], p[3]);
    c.calculCoordoneesPoints();

    /* Ajout de sa valeur */
    int tabval[] = new int[6];
    for (int i = 0; i < 6; i++){
      tabval[i] = 1 - tab[i]; 
    }
    c.s1 = tabval[0];
    c.n1 = 1;
    c.s2 = tabval[1];
    c.n2 = 1;
    c.s3 = tabval[2];
    c.n3 = 1;
    c.s4 = tabval[3];
    c.n4 = 1;
    c.s5 = tabval[4];
    c.n5 = 1;
    c.s6 = tabval[5];
    c.n6 = 1;
    c.monCharacter = val;    
 
    dc.mesCubes.add(c);    
  }
}
