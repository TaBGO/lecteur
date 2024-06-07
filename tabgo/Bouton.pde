/*
* Classe pour la création de bouton dans l'interface graphique
*/

public class Bouton{
  private int posX;
  private int posY; 
  private int largeur;
  private int hauteur;
  private int couleur;
  private String texte;
  private PFont f;
  
  public Bouton(int posX, int posY, int largeur, int hauteur, int couleur, String texte) {
  this.posX = posX;
  this.posY = posY;
  this.largeur = largeur;
  this.hauteur = hauteur;
  this.couleur = couleur;
  this.texte = texte;
  f = loadFont("B612-Bold-20.vlw");
  }

  public void afficher(){
    if (over()) {
      fill(couleur + 20);
    } else {
      fill(couleur);
    }
    stroke(couleur - 20);
    rect(posX, posY, largeur, hauteur);
    fill(0);
    textFont(f);
    int textSize = 20;
    textSize(textSize);
    textAlign(CENTER);
    text(texte, posX+(largeur/2), posY+((hauteur+textSize)/2)-(textSize/5));
  }
  
  public boolean over() {
    return (mouseX >= posX && mouseX <= posX+largeur && 
      mouseY >= posY && mouseY <= posY+hauteur);
  }
}
