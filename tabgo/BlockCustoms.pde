/*
* Classe héritant de Blocks, donc des mêmes propriétés
* Utilisée pour les blocs customs, elle a un attribut en plus : mutation (voir doc)
* @author CAMPAN Mathieu
*/

public class BlockCustoms extends Blocks{
  
  /* Attention mutation est un Map de <String, Object> pas <String, List<Object>>*/
  private Map<String,Object> mutation = new LinkedHashMap<String,Object>();
  
  public BlockCustoms(String opcode){
    super(opcode);
  }
  
  public Blocks copy(){
    BlockCustoms b = new BlockCustoms("data_quart"); // OpCode temporaire
    Blocks bint = super.copy(); 
    b.next = bint.next;
    b.parent = bint.parent;
    b.shadow = bint.shadow;
    b.topLevel = bint.topLevel;
    b.x = bint.x;
    b.y = bint.y;
    b.fields = bint.fields;
    b.inputs = bint.inputs;
    return b;
  }
  
  public Map<String, Object> getMutation(){
    return mutation; 
  }
  
  public void setMutation(Map<String, Object> mutation){
    this.mutation = mutation; 
  }

  /*
  * Renvoie un block initialisé tel un bloc custom prototype (pas dans la liste car non accessible par l'utilisateur)
  */
  public BlockCustoms protoBlock(int code){
    BlockCustoms b = new BlockCustoms("pen_penUp");    
    b.opcode = "procedures_prototype";
    b.next = null;
    b.parent = null;
    b.shadow = true;
    b.topLevel = false;
    b.x = 0;
    b.y = 0;
    b.mutation.put("tagName", "mutation");
    b.mutation.put("children",new ArrayList<Object>());
    String s;
    switch(code){
    case 213:
    case 229:
      s = "Bloc_Custom_1";
      break;
    case 217:
    case 233:
      s = "Bloc_Custom_2";
      break;
    case 227:
    case 241:
      s = "Bloc_Custom_3";
      break;
    case 409:
    case 419:
      s = "Bloc_Custom_Recup_Donnees";
      break;
    default:
      s = "ERREUR";
    }
    b.mutation.put("proccode", s);
    b.mutation.put("argumentids","[]");
    b.mutation.put("argumentnames","[]");
    b.mutation.put("argumentdefaults","[]");
    b.mutation.put("warp",false);
    return b;
  }
 
  
}
