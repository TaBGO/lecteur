import java.util.LinkedHashMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.*;

/*
* Cette classe comprend tout ce qui est nécessaire pour créer un block sur Scratch et être reconnu par celui-ci lors de la génération du JSON
* @author EBRAN Kenny
*/

public class Blocks {
  private String opcode;
  private String next = null;
  private String parent = null;
  private Map<String,List<Object>> inputs = new LinkedHashMap<String,List<Object>>();
  private Map<String,List<Object>> fields = new LinkedHashMap<String,List<Object>>();
  private boolean shadow;
  private boolean topLevel;
  private int x;
  private int y;
  
  /*
  * Constructeur qui crée une instance d'un Block
  * @param op : opcode du bloc
  */
  public Blocks(String op) {
    opcode = op;
  }


  /*
  * Constructeur qui permet de créé un bloc à partir d'un autre. En d'autre terme, fait une copie du bloc passé en paramètre
  * @param b : bloc à copier
  */
  public Blocks(Blocks b) {
      Blocks bint = b.copy();
      opcode = bint.opcode;
      next = bint.next;
      parent = bint.parent;
      inputs = bint.inputs;
      fields = bint.fields;
      shadow = bint.shadow;
      topLevel = bint.topLevel;
      x = bint.x;
      y = bint.y;
  }
  
  
  /* 
  * Méthode privée utilisée pour faire une copie profonde d'une liste d'objets, dans une autre. Elles représent généralement le field ou input du block
  * @param List<Object> ldest liste où l'on veut copier la liste. Soit l'attribut input, soit l'attribut field du Block.
  * @param List<Object> lsource liste que l'on veut copier
  */
  private void copieList(List<Object> ldest, List<Object> lsource){
    /* Object o peut être soit un String, un Integer ou une autre List<Objects> */
    for (Object o : lsource){
      if (o instanceof String){
        String s = (String) o;
        ldest.add(s);
      } else if (o instanceof Integer){
        int val = (int) o;
        ldest.add(val);
      } else if (o instanceof List){
        List<Object> l1 = (List<Object>)o;
        List<Object> ldestint = new ArrayList<Object>();
        copieList(ldestint, l1);
        ldest.add(ldestint);
      }
    }
  }
  
  /**
   * Renvoie la copie profonde de soi même
   * @return copie profonde de soi même
  */
  public Blocks copy(){
    Blocks b = new Blocks(this.opcode);
    b.inputs = new LinkedHashMap<String, List<Object>>();
    /* Parcours des inputs du bloc courant */
    for (Map.Entry<String, List<Object>> bin : inputs.entrySet()){
      /* Copie profonde de la liste obtenue */
      List<Object> l = new ArrayList<Object>();
      copieList(l, bin.getValue());
      b.inputs.put(bin.getKey(),l);
    }
    
    b.fields = new LinkedHashMap<String, List<Object>>();
    /* Parcours des fields du bloc courant */
    for (Map.Entry<String, List<Object>> bf : fields.entrySet()){
      /* Copie profonde de la liste obtenue */
      List<Object> l = new ArrayList<Object>();
      copieList(l, bf.getValue());
      b.fields.put(bf.getKey(),l);
    }    
    b.next = this.next;
    b.parent = this.parent;
    b.shadow = this.shadow;
    b.topLevel = this.topLevel;
    b.x = this.x;
    b.y = this.y;
    return b;
  }
  
  public String getOpcode() {
    return opcode;
  }
  public void setOpcode(String opcode) {
    this.opcode = opcode;
  }
  public String getNext() {
    return next;
  }
  public void setNext(String next) {
    this.next = next;
  }
  public String getParent() {
    return parent;
  }
  public void setParent(String parent) {
    this.parent = parent;
  }
  public Map<String,List<Object>> getInputs() {
    return inputs;
  }
  public void setInputs(Map<String,List<Object>> inputs) {
    this.inputs = inputs;
  }
  public int getX() {
    return x;
  }
  public void setX(int x) {
    this.x = x;
  }
  public int getY() {
    return y;
  }
  public void setY(int y) {
    this.y = y;
  }

  public Map<String, List<Object>> getFields() {
    return fields;
  }

  public void setFields(Map<String, List<Object>> fields) {
    this.fields = fields;
  }

  public boolean isShadow() {
    return shadow;
  }

  public void setShadow(boolean shadow) {
    this.shadow = shadow;
  }

  public boolean isTopLevel() {
    return topLevel;
  }

  public void setTopLevel(boolean topLevel) {
    this.topLevel = topLevel;
  }
  
  /*
  * Méthode permettant de savoir si un bloc a des inputs et renvoie le champ de l'input qui est vide, sinon une chaine vide
  * @return le champ de l'input non encore rempli, sinon une chaine vide
  */
  public String hasInput() {
    for(Map.Entry<String, List<Object>> entry : inputs.entrySet()) {
      if(entry.getValue().isEmpty()) {
        return entry.getKey();
      }
    }
    return "";
  }
  
  /*
  * Méthode permettant de savoir si un bloc a des fields et renvoie le champ du field qui est vide, sinon une chaine vide
  * @ return le champ du field non encore rempli, sinon une chaine vide
  */
  public String hasField(){
    for(Map.Entry<String, List<Object>> entry : fields.entrySet()) {
      if(entry.getValue().isEmpty()) {
        return entry.getKey();
      }
    }
    return "";
  }
  
  
  /**
   * Méthode privée utilisée pour vérifier si l'objet en question est une variable
   * @param Object o objet à tester
   * @ return true s'il s'agit d'une variable, false sinon
  */
  private boolean testVariable(Object o){
    /* Pour être une variable o doit soit :
    * - être un String VARIABLE
    * - être une liste d'objets telle que pour chaque nouveau objet, testVariable(nouveau_objet) renvoie true 
    */
    boolean res = true;
    if (o instanceof String){
      String s = (String)o;
      if(!s.equals("VARIABLE")){
        res = false;
      }
    } else if (o instanceof List){
      List<Object> l = (List<Object>) o;
      for (int i = 0; i < l.size() && res; i++){
        res = res && testVariable(l.get(i));
      }
    } else {
      res = false;
    }
    
    return res;
    
  }
  
  /**
   * Renvoie true si tout les fields sont initialisé à VARIABLE, false sinon
   * @return true si chaque field vaut VARIABLE, false sinon.
  */
  public boolean allFieldVariable(){
    boolean res = !(this.fields.isEmpty());
    for(Map.Entry<String,List<Object>> bf : this.fields.entrySet()){
      for (Object o : bf.getValue()){
        res = res && testVariable(o);  
      }
    }
    return res;
    
  }
  
}
