import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Iterator;
/*
* Classe permettant de gérer la gestion des blocs et notamment de l'ajout d'un TopCode ou d'un cubarithmes
* @author EBRAN Kenny
*/
public class GestionBlocks {
  private Map<String,Blocks> listBlocks = new LinkedHashMap<String,Blocks>();
  private tabgo tb = new tabgo();
  
  /*
  * Constructeur permettant d'initialiser la map listBlocks en créant tous les blocs de l'INJA
  * à partir d'un fichier "blocs.csv" dans le dossier "data"
  */
  public GestionBlocks() {
    String csvFile = dataPath("") + "/blocs.csv";
    BufferedReader br = null;
    String line = "";
    String csvSplitBy = ",";
    
    
    try {
      br = new BufferedReader(new FileReader(csvFile));
      while((line = br.readLine()) != null) {
        //Suppression des espaces de fins
        line.trim();
        
        //On saute les lignes vides
        if(line.length() == 0) {
          continue;
        }
        
        //On saute les lignes de commentaires
        if(line.startsWith("#")) {
          continue;
        }
        
        //use comma as separator
        String[] blocks = line.split(csvSplitBy);
        Blocks b = tb.new Blocks(blocks[2]);
        boolean field = false;
        int i = 3;
        while(i < blocks.length && ! field) {
          if(blocks[i].equals("F")) {
            field = true;
          } else {
            b.getInputs().put(blocks[i], new ArrayList<Object>());
          }
          i++;
        }
        if(field) {
          List<Object> tmp = new ArrayList<Object>();
          tmp.add(blocks[i+1]);
          tmp.add(null);
          b.getFields().put(blocks[i],tmp);
        }
        listBlocks.put(blocks[1], b);
       }
    } catch(IOException e) {
      e.printStackTrace();
    } finally {
      if(br != null) {
        try {
          br.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }  
    }
  }
  /*
  * Renvoie une copie profonde de la liste des blocks disponibles
  * @return la copie de la liste des blocks disponibles
  */
  public Map<String,Blocks>getListBlocks() {
    Map<String, Blocks> res = new LinkedHashMap<String, Blocks>();
    for (Map.Entry<String, Blocks> bl : this.listBlocks.entrySet()){
       String val = bl.getKey();
       res.put(val,bl.getValue().copy());
    }
    return listBlocks;
  }
  
  /*
  * Méthode permettant de savoir quels sont les blocs qui ont des inputs
  * @return true si le blocs à des inputs, sinon false
  */
  public boolean hasInput(String code) {
    return ! listBlocks.get(code).getInputs().isEmpty();
  }
  
  /* Méthode privée vérifiant si un bloc peut avoir un bloc suivant : si ce n'est pas une variable, liste, valeur de x/y ou un opérateur ou un itemoflist 
  * @param Blocks der bloc à tester
  * @return true s'il peut avoir un bloc suivant, false sinon
  */
  private boolean canHaveNext(Blocks der){
    boolean res = true;
    if (der.opcode.contains("operator")){
      res = false;
    } 
    if (der.opcode.contains("demi") || 
        der.opcode.contains("quart") || 
        der.opcode.contains("var1") || 
        der.opcode.contains("var2") ||
        der.opcode.contains("chatparle") ||
        der.opcode.contains("liste_temp") ||
        der.opcode.contains("liste_export")        
        ){
      res = false;
    }
    if (der.opcode.equals("motion_xposition") || der.opcode.equals("motion_yposition")){
      res = false;
    }
    if (der.opcode.equals("data_itemoflist")){
      res = false;
    }
    if (der.opcode.equals("control_stop") || der.opcode.equals("control_forever")){
      res = false;
    }
    return res;
  }
  /*
  * Méthode permettant d'ajouter à la liste des blocs donné en paramètre le bloc correspondant au TopCode donné (Version sans parent)
  * @param list : Liste des blocs
  * @param code : le TopCode lu par le programme
  * @param topLevel : booléen permettant de savoir si le code donné correspond au premier bloc du programme
  * @param current : numéro du bloc courant, correspond à l'ordre de traitement
  * @param prev : numéro du bloc précédant, correspond à l'ordre de traitement
  */
  public void ajoutTopCode(List<Blocks> list, TopCode code, boolean topLevel,int current, int prev) {
    Blocks blockToAdd = tb.new Blocks(getListBlocks().get(String.valueOf(code.getCode())));
    List<Object> listToAdd;
    if (isCustomBlock(code.getCode())){
      if (isDefinition(code.getCode())){
        
        /* Block Définition */
        blockToAdd.setOpcode("procedures_definition");
        listToAdd = new ArrayList<Object>();
        listToAdd.add(1);
        listToAdd.add("bloc" + ++current);
        blockToAdd.inputs.put("custom_block", listToAdd);          
        list.add(blockToAdd);
        /* Block Prototype */
        BlockCustoms proto = new BlockCustoms("data_quart"); // Opcode temporaire
        proto = proto.protoBlock(code.getCode());
        proto.parent = "bloc"+--current;
        current++;
        list.add(proto);
        
      } else {
        /* Appel de block custom*/
        BlockCustoms blockcall = new BlockCustoms("data_quart"); // Opcode temporaire
        blockcall = blockcall.protoBlock(code.getCode());
        blockcall.setOpcode("procedures_call");          
        blockcall.x = floor(code.getCenterX());
        blockcall.y = floor(code.getCenterY());
        Blocks der = list.get(prev);
        /* S'il n'y a pas de parent, on regarde si le précédant était un bloc de départ pour l'y rattacher
         * Utile pour utiliser plusieurs blocs de départ */
        if (list.get(prev).getOpcode().contains("event")){
          blockcall.setParent("bloc"+prev);
        } 
        int ancien = prev;
        while(!canHaveNext(der)){
          ancien--;
          der = list.get(ancien);
        } 
        list.get(ancien).setNext("bloc"+current);
                
        blockcall.mutation.remove("argumentnames");
        blockcall.mutation.remove("argumentdefaults");
        list.add(blockcall); 
      }
    } else {
      blockToAdd.setTopLevel(topLevel);
      if( !topLevel) {
        Blocks der = list.get(prev);
        int ancien = prev - 1;
        if (list.get(prev).getOpcode().contains("event") || list.get(prev).getOpcode().equals("procedures_definition")){
          blockToAdd.setParent("bloc"+prev);
        }

        while(!canHaveNext(der)){
          der = list.get(ancien);
          ancien--;
        }
        ancien++;
        
        if (ancien >= 0 && list.get(ancien).getOpcode().equals("procedures_prototype")){
          ancien--;
          blockToAdd.parent = "bloc"+ancien;
        }
        list.get(ancien).setNext("bloc"+current); 
      }
      list.add(blockToAdd);
    }
  }
  
  /*
  * Méthode permettant d'ajouter à la liste des blocs donné en paramètre le bloc correspondant au TopCode donné (Version avec parent)
  * @param list : Liste des blocs
  * @param code : le TopCode lu par le programme
  * @param topLevel : booléen permettant de savoir si le code donné correspond au premier bloc du programme
  * @param current : numéro du bloc courant, correspond à l'ordre de traitement
  * @param prev : numéro du bloc précédant, correspond à l'ordre de traitement
  * @param parent : numéro du bloc parent, correspond à l'ordre de traitement
  */
  public void ajoutTopCode(List<Blocks> list, TopCode code,boolean topLevel, int current, int prev, int parent) {
    if(isVariable(code.getCode())) {
        addVariable(list, code, parent); 
      } else {
        addBlock(list, code, topLevel, current, prev, parent);
      }
  }
  
  /*
  * Méthode privée qui permet d'ajouter un bloc.
  * @see ajoutTopCode()
  * @param list : Liste des blocs
  * @param code : le TopCode lu par le programme
  * @param topLevel : booléen permettant de savoir si le code donné correspond au premier bloc du programme
  * @param current : numéro du bloc courant, correspond à l'ordre de traitement
  * @param prev : numéro du bloc précédant, correspond à l'ordre de traitement
  * @param parent : numéro du bloc parent, correspond à l'ordre de traitement
  */
  private void addBlock(List<Blocks> list, TopCode code, boolean topLevel, int current, int prev, int parent) {
    String champ;
    List<Object> listToAdd;
    List<Object> tmp;
    Blocks blockToAdd = tb.new Blocks(getListBlocks().get(String.valueOf(code.getCode())));
    blockToAdd.setTopLevel(topLevel);
    if( ! topLevel) {
      if (isCustomBlock(code.getCode())){
        if (isDefinition(code.getCode())){
          
          /* Block Définition */
          blockToAdd.setOpcode("procedures_definition");
          listToAdd = new ArrayList<Object>();
          listToAdd.add(1);
          listToAdd.add("bloc" + ++current);
          blockToAdd.inputs.put("custom_block", listToAdd);          
          list.add(blockToAdd);
          
          /* Block Prototype */
          BlockCustoms proto = new BlockCustoms("data_quart"); // Opcode temporaire
          proto = proto.protoBlock(code.getCode());
          proto.parent = "bloc"+ --current;
          current++;
          list.add(proto);
          
        } else {
          /* Appel de block custom*/
          BlockCustoms blockcall = new BlockCustoms("data_quart"); // Opcode temporaire
          blockcall = blockcall.protoBlock(code.getCode());
          blockcall.setOpcode("procedures_call");
          blockcall.x = floor(code.getCenterX());
          blockcall.y = floor(code.getCenterY());
          Blocks der = list.get(prev);
          int ancien = prev;
          while(!canHaveNext(der)){
            ancien--;
            der = list.get(ancien);
          }  
          list.get(ancien).setNext("bloc"+current);
                  
          if ((list.get(prev).inputs != null) &&  (blockcall.opcode.contains("operator"))){
            blockcall.setParent("bloc"+parent);
          } else {
            der = list.get(prev);
            ancien = prev - 1;
            while (ancien >= 0 && (!der.opcode.contains("control_if") && !der.opcode.contains("control_repeat") && !der.opcode.contains("control_forever"))){ 
              der = list.get(ancien);
              ancien--;
            }
            if (ancien++ >= 0){
              blockcall.setParent("bloc"+ancien);
            }
          }
          blockcall.mutation.remove("argumentnames");
          blockcall.mutation.remove("argumentdefaults");
          list.add(blockcall);
        }
      } else {
        champ = list.get(parent).hasInput();
        if(!champ.equals("")) {
          listToAdd = new ArrayList<Object>();
          if(hasShadow(champ)) {
            listToAdd.add(3);
            listToAdd.add("bloc"+current);
            tmp = new ArrayList<Object>();
            tmp.add(10);
            tmp.add("");
            listToAdd.add(tmp);
           } else {
            listToAdd.add(2);
            listToAdd.add("bloc"+current);
           }
          list.get(parent).getInputs().put(champ, listToAdd);
          blockToAdd.parent = "bloc"+parent;
          
        } else {
          Blocks der = list.get(prev);
          int ancien = prev;
          while(!canHaveNext(der)){
            ancien--;
            der = list.get(ancien);
          }  
          if (list.get(ancien).getOpcode().equals("procedures_prototype")){
            ancien--;
          }
          if (list.get(ancien).hasInput().equals("") && list.get(ancien).hasField().equals("") && canHaveNext(list.get(ancien))) {
            list.get(ancien).setNext("bloc"+current);
          }    
          if ((list.get(prev).inputs != null) &&  (blockToAdd.opcode.contains("operator"))){
            blockToAdd.setParent("bloc"+parent);
          } else {
            der = list.get(prev);
            ancien = prev - 1;
            while (ancien >= 0 && (!der.opcode.contains("control_if") && !der.opcode.contains("control_repeat") && !der.opcode.contains("control_forever"))){ // A Modifier : on remonte jusqu'au dernier controle, à vérifier si ce n'est pas un controle déjà finit, alors remonter encore plus loin
              der = list.get(ancien);
              ancien--;
            }
            if (ancien++ >= 0){
              blockToAdd.setParent("bloc"+ancien);
            }
          }
        }
        list.add(blockToAdd);
      }
    } 
  }
  
  /*
  * Méthode privée qui permet d'ajouter un bloc variable à un bloc parent.
  * @see ajoutTopCode()
  * @param list : Liste des blocs
  * @param code : le TopCode lu par le programme
  * @param parent : numéro du bloc parent, correspond à l'ordre de traitement
  */
  private void addVariable(List<Blocks> list, TopCode code, int parent) {
    String champ;
    List<Object> listToAdd;
    List<Object> tmp;
    listToAdd = new ArrayList();
    champ = list.get(parent).hasInput();
    String variable;
    switch(code.getCode()){
    case 357:
      variable = "var1";
      break;
    case 361:
      variable = "var2";
      break;
    case 403: // 90°
      variable = "quart_de_tour";
      break;
    case 405: // 180°
      variable = "demi_tour";
      break;
    case 421:
      variable = "FIN";
      break;
    case 425:
      variable = "chatparle";
      break;
    case 433:
      variable = "liste_export";
      break;
    case 453:
      variable = "liste_temp";
      break;  
    default:
      variable = "erreur";
    }
    if(champ.equals("") && isDataVariable(list.get(parent).getOpcode())) {
      listToAdd.clear();
      listToAdd.add(variable);
      listToAdd.add(variable);
      list.get(parent).getFields().put("VARIABLE", listToAdd);
    } else if (isDataList(list.get(parent).getOpcode())) {
      List<Object> listToAdd2 = new ArrayList<Object>();
      if (champ == ""){
        /* Pas d'input on rempli Field */
        listToAdd.clear();
        listToAdd.add(variable);
        listToAdd.add(variable);
        list.get(parent).getFields().put("LIST",listToAdd);
      } else {
        /* Input : soit data_itemoflist soit data_addtolist */
        if (champ.equals("INDEX")){
          listToAdd.clear();
          listToAdd.add(1);
          listToAdd2.add(7);
          listToAdd.add(listToAdd2);
        } else {
          listToAdd.clear();
          listToAdd.add(3);
          if (variable.contains("list")){
            listToAdd2.add(13);
          } else {
            listToAdd2.add(12);                        
          }
          listToAdd2.add(variable);
          listToAdd2.add(variable);
          listToAdd.add(listToAdd2);
          listToAdd2 = new ArrayList();
          listToAdd2.add(10);
          listToAdd2.add("");
          listToAdd.add(listToAdd2);
        }
        list.get(parent).getInputs().put(champ, listToAdd);   
      }
    } else {
      listToAdd.add(3);
      tmp = new ArrayList();
      tmp.add(12);
      tmp.add(variable);
      tmp.add(variable);
      listToAdd.add(tmp);
      List<Object> tmp2 = new ArrayList();
      tmp2.add(10);
      tmp2.add("");
      listToAdd.add(tmp2);
      list.get(parent).getInputs().replace(champ, listToAdd);
    }
  }
  
  /*
  * Méthode permettant d'ajouter un cubarithme à un input d'un bloc
  * @param list : liste des blocs
  * @param chaine : caractere correspond au braille du cubarithme
  * @param prev : numéro du bloc précédant, ordre de traitement
  */
  public void ajoutCubarithme(List<Blocks> list, String chaine,int prev) {
    if(! list.isEmpty()){
      String champ = list.get(prev).hasInput();
      List<Object> listToAdd = new ArrayList<Object>();
      listToAdd.add(1);
      List<Object> tmp = new ArrayList<Object>();
      if (champ.contains("INDEX")){
        tmp.add(7);
      } else {
        tmp.add(10);
      }
      tmp.add(chaine);
      listToAdd.add(tmp);
      list.get(prev).getInputs().put(champ, listToAdd);
    }
  }
  
  /*
  * Méthode qui détermine si le code donné en paramètre correspond au bloc qui signifie l'arrêt d'un bloc de contrôle
  * @param code : TopCode
  * @return true si le TopCode correspond au bloc qui signifie l'arrêt d'un bloc de contrôle, sinon false
  */
  public boolean isStopBlock(int code) {
    return code == 93;
  }
  
  /*
  * Méthode qui détermine si le code donné en paramètre correspond au bloc qui signifie que l'on rentre dans un else
  * @param code : TopCode
  * @return true si le TopCode correspond au bloc qui signifie que l'on rentre dans le else, sinon false
  */
  public boolean isElseBlock(int code){
    return code == 91;
  }
  
  /*
  * Méthode qui détermine si le code donné en paramètre correspond à un bloc de contrôle
  * @param code : TopCode
  * @return true si le TopCode correspond à un bloc de contrôle, sinon false
  */
  public boolean isControlBlock(int code) {
    switch(code){
      case 55:
      case 59:
      case 61:
      case 79:
      case 91:
        return true;
       default:
         return false;
    }
  }
  
  /*
  * Méthode qui détermine si le champ donné en paramètre peut être un champ "Shadow"
  * @param champ : Champ d'input
  * @return true si le champ peut être shadow, sinon false
  */
  public boolean hasShadow(String champ) {
    switch(champ){
      case "TIMES":
      case "DURATION":
      case "MESSAGES":
      case "SECS":
      case "STEPS":
      case "DEGREES":
      case "DIRECTION":
      case "X":
      case "Y":
      case "DX":
      case "DY":
      case "QUESTION":
      case "NUM1":
      case "NUM2":
      case "NUM":
      case "OPERAND1":
      case "OPERAND2":
      case "FROM":
      case "TO":
      case "STRING1":
      case "STRING2":
      case "VALUE":
      case "ITEM":
        return true;
      default:
        return false;
    }
  }
  
  /*
  * Méthode qui permet de savoir si le TopCode donné en paramètre correspond à un bloc variable
  * @param code : TopCode
  * @return true si le TopCode correspond à une variable, sinon false
  */
  public boolean isVariable(int code) {
    switch(code) {
    case 357:
    case 361:
    case 403:
    case 405:
    case 421:
    case 425:
    case 433:
    case 453:
      return true;
    default:
      return false;
    }
  }
  
  /*
  * Méthode qui permet de savoir si le opcode donné en paramètre correspond à un bloc data_variable
  * @param opcode : Opcode
  * @return true si le opCode correspond à un bloc data_variable, sinon false
  */
  public boolean isDataVariable(String opcode) {
    switch(opcode) {
    case "data_setvariableto":
    case "data_changevariableby":
    case "data_showvariable":
    case "data_hidevariable":
      return true;
    default:
      return false;
    }
  }
  /*
  * Méthode qui permet de savoir si le opcode donné en paramètre correspond à un bloc data_variable
  * @param opcode : Opcode
  * @return true si le opCode correspond à un bloc data_variable, sinon false
  */
  public boolean isDataVariable(int code) {
    switch(code) {
    case 369:
    case 391:
    case 395:
    case 397:
      return true;
    default:
      return false;
    }
  }
  public int getTopcode(String opcode) {
    for(Map.Entry<String,Blocks> entry : listBlocks.entrySet()) {
      if(entry.getValue().getOpcode().equals(opcode)) {
        return Integer.parseInt(entry.getKey());
      }
    }
    return -1;
  }
  
  /*
  * Méthode permettant de savoir si un block est un block custom : définition ou appel
  */
  public boolean isCustomBlock(String opcode){
      if ((opcode.equals("procedures_definition")) ||(opcode.equals("procedures_call"))){
        return true;
      } else {
        return false;
      }
  }
  
  /*
  * Méthode permettant de savoir si un block est un block custom : définition ou appel
  */
  public boolean isCustomBlock(int code){
      boolean test;
      switch(code){
      case 213:
      case 217:
      case 227:
      case 229:
      case 233:
      case 241:
      case 409:
      case 419:
        test = true;
        break;
      default:
        test = false;
      }
      return test;
  }
  /*
  * Méthode permettant de savoir si un block est un block custom : définition ou appel
  */
  public boolean isDefinition(int code){
      boolean test;
      switch(code){
      case 213:
      case 217:
      case 227:
      case 409:
        test = true;
        break;
      default:
        test = false;
      }
      return test;
  }
  
  /*
  * Méthode qui permet de savoir si le opcode donné en paramètre correspond à un bloc data_list
  * @param opcode : Opcode
  * @return true si le opCode correspond à un bloc data_list, sinon false
  */
  public boolean isDataList(String opcode) {
    switch(opcode) {
    case "data_hidelist":
    case "data_showlist":
    case "data_deletealloflist":
    case "data_itemoflist":
    case "data_addtolist":
      return true;
    default:
      return false;
    }
  }
   
  /*
  * Méthode qui permet de savoir si le code donné en paramètre correspond à un bloc data_list
  * @param code : code
  * @return true si le code correspond à un bloc data_list, sinon false
  */
  public boolean isDataList(int code) {
    switch(code) {
    case 457:case 465:case 551:case 555:case 563:
      return true;
    default:
      return false;
    }
  }
}

  public int getNombreVariableTopCode(TopCode code){
    switch(code.getCode()) {
      case 61:case 87:case 155:case 157:case 167:case 171:case 179:case 181:case 185:case 199:case 283:
        return 1;
      case 115:case 173:case 339:
        return 2;
      default:
        return 0;
    }
  }
  
  public Object getValeurDefautTopCode1(TopCode code){
    switch(code.getCode()){
      case 61:case 155:case 179:case 185:
        return 10;
      case 87:
        return 1;
      case 157:
      case 167:
        return 15;
      case 171:
        return 90;
      case 181:case 199:
        return 0;
      case 283:
        return "Quel est ton nom ?";
      default:
        return -1;
    }
  }
  
  public Object[] getValeurDefautTopCode2(TopCode code){
    switch(code.getCode()){
      case 173:
        Object[] numbers173 = {0,0};
        return numbers173;
      case 115:
        Object[] text115 = {"Bonjour !",2};
        return text115;
      case 339:
        Object[] numbers339 = {1,10};
        return numbers339;
      default:
        return null;
    }
  }
  
  public boolean haveOnlyNumberVariable(TopCode code){
    switch(code.getCode()){
      case 61:case 87:case 155:case 167:case 171:case 173:case 179:case 181:case 185:case 199:
        return true;
      default:
        return false;
    }
  }
  
  //la liste des TopCode inserable dans un autre top code, comme par exemple ... + ...
  public boolean TopCodeInserable(TopCode code){
    switch(code.getCode()){
      case 285:case 295:case 299:case 301 :case 339:case 341:case 355:
        return true;
      default:
        return false;
    }
  }
