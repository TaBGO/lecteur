# TopCodes réservés
Ceci est un document explicitant les TopCodes utilisés dans la récupération de données et qui ne doivent pas être utilisés lors d'une continuation du code

TopCode 409 : procedures_definition
TopCode 419 : procedures_call
TopCode 421 : data_FIN
TopCode 433 : data_listexport
TopCode 453 : data_listtemp

## Autres Informations utiles

Voici quelques informations utiles pour la reprise en main du code : 

### Visualisation des blocs créés

Pour voir les blocs créés par l'algorithme, il faut décommenter l'affichage dans la méthode creation de tabgo avant la création du JSON.
Les blocs sont affichés de la forme : 
bloc*numéro_bloc*, *opcode*, *inputs*, *fields*, *next*, *parent*, *mutation*, *topLevel* 
À noté que mutation n'est affiché que dans les blocs en ayant : blocs custom définition et prototype
Pour plus d'informations sur la signification des différents éléments, voir la documentation accessible depuis le dossier supérieur.


### Changer les tests

Pour changer le test traité en tapant 'T' ou 't', remplacer XXX par le numéro du test voulu : "/tests/test_SXXX.png" dans la méthode keyPressed de tabgo
