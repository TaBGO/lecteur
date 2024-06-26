/**
 * Classe correspondant un ensemble de méthodes de filtrage des objets reconnus par OpenCV. 
 *
 */



import java.util.ArrayDeque;

import java.util.Deque;
import java.util.LinkedList;


import java.util.List;
import org.opencv.core.RotatedRect;

public class FiltrageCubes {  
  private float gammaCoeff; //Paramètre représentant le gamma de l'image
     
  public float getGammaCoeff() {
    return gammaCoeff;
  }

  public void setGammaCoeff(float gammaCo) {
    gammaCoeff = gammaCo;
  }
  
  
  /**
   * Détermine si deux rectangles ont la même ordonnée
   * @param cube1 : cube 1
   * @param cube2 : cube 2 à comparer avec cube 1
   * @return vrai si cube1.c.y = cube2.c.y, false sinon
   */
  public boolean memeOrdonnee(Cube cube1, Cube cube2) {      
    double y1 = cube1.c.y;
    double y2 = cube2.c.y;    
    double height = (cube1.hauteur + cube2.hauteur)/2;
        
    return (y1 - height <= y2) && (y2 <= y1 + height);
  }
  
  /**
   * Détermine si un TopCode et un rectangle ont la même ordonnée
   * @param tc : TopCode
   * @param cube : Cube à comparer avec tc
   * @return vrai si tc.y = cube.c.y, false sinon
   */
  public boolean memeOrdonnee(TopCode tc, Cube cube) {    
    double y1 = tc.getCenterY();
    double y2 = cube.c.y;    
    double height = (double)cube.hauteur*0.9;
    return (y1 - height <= y2) && (y2 <= y1 + height);
  }
  
  /**
   * Détermine si deux rectangles ont la même abscisse
   * @param cube1 : cube 1
   * @param cube2 : cube 2 à comparer avec cube 1
   * @return vrai si cube1.c.x = cube2.c.x, false sinon
   */
  public boolean memeAbscisse(Cube cube1, Cube cube2) {
    double x1 = cube1.c.x;        
    double x2 = cube2.c.x;        
    double width = (cube1.largeur + cube2.largeur)/2;
    
    return (x1 - width <= x2) && (x2 <= x1 + width);
  }
  
  /**
   * Détermine si un rectangle rect1 est supérieur à rect2 en termes de coordonnées
   * @param cube1 : cube 1 
   * @param cube2 : cube 2 à comparer avec cube 1
   * @return vrai si (coordonées de cube1) est supérieur à (coordonnées de cube2), false sinon
   */
  public boolean estSuperieur(Cube cube1, Cube cube2) {
    if (memeOrdonnee(cube1, cube2)) {
      return (cube1.c.x > cube2.c.x);
    }
    else {
      return (cube1.c.y > cube2.c.y);
    }
  }
  
  /**
   * Détermine si un TopCode tc est supérieur à un rectangle en termes de coordonnées
   * @param tc : TopCode
   * @param cube : Cube à comparer avec tc
   * @return vrai si (coordonées de tc) est  supérieur à (coordonnées de cube), false sinon
   */
  public boolean estSuperieur(TopCode tc, Cube cube) {
    if (memeOrdonnee(tc, cube)) {
      return (tc.getCenterX() < cube.c.x);
    }
    else {
      return (tc.getCenterY() < cube.c.y);
    }
  }

  /**
   * Détermine si deux TopCodes tc1 et tc2 sont situés à la même ordonnée
   * @param tc : TopCode
   * @param tc2 : TopCode
   * @return vrai si tc et tc2 sont à la même ordonnée, false sinon
   */
  public boolean memeOrdonnee(TopCode tc, TopCode tc2) {    
    double y1 = tc.getCenterY();        
    double y2 = tc2.getCenterY();    
    double height = ((tc.getDiameter()+tc2.getDiameter())/2)*0.8;
    
    return (y1 - height <= y2) && (y2 <= y1 + height);
  }
  
  /**
   * Méthode qui construit l'algorithme a partir de la liste de TopCode et la liste des cubes reconnus
   * @param tc : liste de TopCodes
   * @param lcubes : liste des cubes reconnus
   * @return algorithme construit sous la forme d'une liste de Blocks
   * Modifié par EBRAN Kenny pour être adapté à la nouvelle implémentation du programme
   */
  public List<Blocks> construitAlgorithme(List<TopCode> tc, List<Cube> lcubes, GestionBlocks g){
    int i = 0;
    int j = 0;
    boolean cubarithmeDejaAjoute = false;
    int prev = 0;
    int cur = 0;
    String cubeValue="";
    
    List<Blocks> listBlocks = new LinkedList <Blocks>();
    Deque<Integer> parents = new ArrayDeque<Integer>();
    
    TopCode code;
    boolean topLevel = false;  
    Cube cube;
    
    while (i<tc.size()) {
      code = tc.get(i);   
       if(j < lcubes.size()){
         cube = lcubes.get(j);
         if(estSuperieur(code, cube)){
           switch(code.getCode()){
           case 31:
           case 213:
             topLevel = true;
           case 217:
             topLevel = true;
           case 227:
             topLevel = true;
           case 47:
             topLevel = true;
             break;
           default:
             topLevel = false;
           }

           println("code : " + code.getCode()); 
           if(cubarithmeDejaAjoute==true && j>0){
             addCubarithme(g, prev, listBlocks, parents, cubeValue);
             cubeValue="";
             cubarithmeDejaAjoute=false;
           }
           if(g.isStopBlock(code.getCode())) {
             prev = parents.removeFirst();
           } else if (g.isElseBlock(code.getCode())){
             listBlocks.get(parents.peekFirst()).getInputs().put("SUBSTACK2",new ArrayList());
             listBlocks.get(parents.peekFirst()).setOpcode("control_if_else");
           } else {
             prev = addTopCode(g, prev, cur, listBlocks, parents, code, topLevel);
             cur = g.isVariable(code.getCode()) ? cur : cur + 1;
             cur = g.isDefinition(code.getCode()) ? cur + 1 : cur;
           }
           if(i+1<tc.size()){
             if(estSuperieur(tc.get(i+1),cube) && getNombreVariableTopCode(code) == 1 && !g.isVariable(tc.get(i+1).getCode())){
                 println("cube par défaut : " + getValeurDefautTopCode1(code));
                 addCubarithme(g, prev, listBlocks, parents, String.valueOf(getValeurDefautTopCode1(code)));
             }
             if(estSuperieur(tc.get(i+1),cube) && getNombreVariableTopCode(code) == 2 && !g.isVariable(tc.get(i+1).getCode())){
                 Object[] numbers = getValeurDefautTopCode2(code);
                 if(numbers != null && numbers.length == 2){
                     if(numbers[0] instanceof Integer && numbers[1] instanceof Integer){
                       int number1 = (int) numbers[0];
                       int number2 = (int) numbers[1];
                       println("cube par défaut : " + number1);
                       println("cube par défaut : " + number2);
                       addCubarithme(g, prev, listBlocks, parents, String.valueOf(number1));
                       addCubarithme(g, prev, listBlocks, parents, String.valueOf(number2));
                     }if(numbers[0] instanceof String && numbers[1] instanceof Integer){
                        String number1 = (String) numbers[0];
                        int number2 = (int) numbers[1];
                        println("cube par défaut : " + number1);
                        println("cube par défaut : " + number2);
                        addCubarithme(g, prev, listBlocks, parents, number1);
                        addCubarithme(g, prev, listBlocks, parents, String.valueOf(number2));
                     }
                 }
             }
           }
           i++;
         } 
         else {
           println("cube : " + cube.getValue());
           cubeValue = cubeValue + cube.getValue();
           cubarithmeDejaAjoute = true;
           j++;
         } 
         
       } 
       else {
         if(cubarithmeDejaAjoute==true && j>0){
             addCubarithme(g, prev, listBlocks, parents, cubeValue);
             cubeValue="";
             cubarithmeDejaAjoute=false;
           }
         println("code : " + code.getCode());
         switch(code.getCode()){
         case 31:
         case 213:
             topLevel = true;
         case 217:
             topLevel = true;
         case 227:
             topLevel = true;
         case 47:
           topLevel = true;
           break;
         default:
           topLevel = false;
         }
         if(g.isStopBlock(code.getCode())) {
             prev = parents.removeFirst();
         } else if (g.isElseBlock(code.getCode())){
             listBlocks.get(parents.peekFirst()).getInputs().put("SUBSTACK2",new ArrayList());
             listBlocks.get(parents.peekFirst()).setOpcode("control_if_else");
           } else {
           prev = addTopCode(g, prev, cur, listBlocks, parents, code, topLevel);
           cur = g.isVariable(code.getCode()) ? cur : cur + 1;
           cur = g.isDefinition(code.getCode()) ? cur+1 : cur;
         }
         if(getNombreVariableTopCode(code) == 1){
           if(i+1<tc.size()){
             if(TopCodeInserable(tc.get(i+1))){  
             }
           }
           println("cube par défaut : " + getValeurDefautTopCode1(code));
           addCubarithme(g, prev, listBlocks, parents, String.valueOf(getValeurDefautTopCode1(code)));
         }
         if(getNombreVariableTopCode(code) == 2){
           Object[] numbers = getValeurDefautTopCode2(code);
           if(numbers != null && numbers.length == 2){
             if(numbers[0] instanceof Integer && numbers[1] instanceof Integer){
                int number1 = (int) numbers[0];
                int number2 = (int) numbers[1];
                println("cube par défaut : " + number1);
                println("cube par défaut : " + number2);
                addCubarithme(g, prev, listBlocks, parents, String.valueOf(number1));
                addCubarithme(g, prev, listBlocks, parents, String.valueOf(number2));
             }if(numbers[0] instanceof String && numbers[1] instanceof Integer){
                String number1 = (String) numbers[0];
                int number2 = (int) numbers[1];
                println("cube par défaut : " + number1);
                println("cube par défaut : " + number2);
                addCubarithme(g, prev, listBlocks, parents, number1);
                addCubarithme(g, prev, listBlocks, parents, String.valueOf(number2));
             }
           }
         }
         i++;
       }   
    }
    cubeValue = "";
    boolean cubeRestant = false;
    while (j < lcubes.size()){
      cubeRestant = true;
      cube = lcubes.get(j);
      println("cube : " + cube.getValue());
      cubeValue = cubeValue + cube.getValue();
      j++;
    }
    
    if(cubeRestant){
      addCubarithme(g, prev, listBlocks, parents, String.valueOf(cubeValue));
    }
    return listBlocks;  
  }  
  
  /*
  * Méthode privée qui permet d'ajouter un cubarithme à la liste des blocs
  * @see construitAlgorithme
  * @param g : instance de GestionBlocks
  * @param prev : indice du bloc précédant dans la liste des blocs
  * @param listBlocks : liste des blocs
  * @param parents : Pile qui contient les parents à traiter
  * @param chaine : caractère braille du cubarithme
  */
  private void addCubarithme(GestionBlocks g, int prev, List<Blocks> listBlocks, Deque<Integer> parents, String chaine) {
    int i = 0;
    while ((listBlocks.get(prev)).hasInput() != null && listBlocks.get(prev).hasInput().equals("")){
     prev--;
     i++;
    }
    g.ajoutCubarithme(listBlocks, chaine,prev);
    if(! parents.isEmpty() 
      && listBlocks.get(parents.peekFirst()).hasInput().equals("") 
      && listBlocks.get(parents.peekFirst()).hasField().equals("")
      && !listBlocks.get(parents.peekFirst()).allFieldVariable()
      && !listBlocks.get(parents.peekFirst()).allFieldList()
      && ! g.isControlBlock(g.getTopcode(listBlocks.get(parents.peekFirst()).getOpcode()))) {
      parents.removeFirst();
      if (!parents.isEmpty()){
        Blocks b = listBlocks.get(parents.peekFirst());
        while (!parents.isEmpty() && b.getOpcode().contains("operator") && b.hasInput().equals("")){
          parents.removeFirst();
          b = listBlocks.get(parents.peekFirst());
        }
      }

    }
  
    prev += i;
  }
  /*
  * Méthode privée permettant d'ajouter un bloc à la liste des blocs
  * @param g : instance de GestionBlocks
  * @param prev : indice du bloc précédent dans la liste des blocs
  * @param cur : indice du bloc courant
  * @param listBlocks : liste des blocs
  * @param parents : Pile qui contient les parents à traiter
  * @param code : TopCode à traiter
  * @param topLevel : booléen qui permet de savoir le bloc est le premier de la liste
  * @return le nouvel indice du bloc précédant
  */
  private int addTopCode(GestionBlocks g, int prev, int cur, List<Blocks> listBlocks, Deque<Integer> parents,
    TopCode code, boolean topLevel) {
    if(topLevel){
      parents.clear();
    }
    if(!parents.isEmpty()) {
      g.ajoutTopCode(listBlocks, code,topLevel, cur, prev, parents.peekFirst());      
    } else {
      g.ajoutTopCode(listBlocks, code, topLevel, cur, prev);
    }
    if(g.hasInput(String.valueOf(code.getCode())) || g.isDefinition(code.getCode())) {
      parents.addFirst(cur);
    } else if(g.isDataList(code.getCode()) || g.isDataVariable(code.getCode())){
      parents.addFirst(cur);
    } else if(! parents.isEmpty()
             && listBlocks.get(parents.peekFirst()).hasInput().equals("")
             && listBlocks.get(parents.peekFirst()).hasField().equals("")
             && !listBlocks.get(parents.peekFirst()).allFieldVariable()
             && !listBlocks.get(parents.peekFirst()).allFieldList()
             && ! g.isControlBlock(g.getTopcode(listBlocks.get(parents.peekFirst()).getOpcode()))) {
      parents.removeFirst();
      
      if (!parents.isEmpty()){
        Blocks b = listBlocks.get(parents.peekFirst());
        while (!parents.isEmpty() && (b.getOpcode().contains("operator") && b.hasInput().equals(""))){
          parents.removeFirst();
          b = listBlocks.get(parents.peekFirst());
        }
      }
    }
    prev = listBlocks.size() - 1;
    return prev;
  }

}
