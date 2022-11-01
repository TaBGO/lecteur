# TaBGO <img src="./documentation/images/tabgo.png" width=150 alt="TaBGO">

## Informations générales
Le projet TaBGO a pour objectif de permettre à des personnes non-voyantes d'utiliser le langage de programmation [Scratch](https://scratch.mit.edu) par utilisation de blocs tangibles.
Le logiciel TaBGO permet la reconnaissance des blocs tangibles grâce à des [TopCodes](https://github.com/truillet/TopCodes) ainsi que des cubarithmes et créer un fichier **sb3** exécutable par [Scratch](https://scratch.mit.edu).

<img src="./documentation/images/blocks.jpg" width=400 alt="différents prototypes">

Vous pouvez consulter la documentation pour construire vos blocs au format **[docx](./documentation/TaBGO_blocs_Scratch.docx)** ou **[pdf](./documentation/TaBGO_blocs_Scratch.pdf)**

Des exemples d'algorithmes sont disponibles *ici* (*à venir*)

Le code disponible **[là](./tabgo)** a principalement été développé au travers de plusieurs projets de fin d'étude : Jean-Baptiste Marco dans sa première mouture en java (stage de 2A ISAE-ENSMA) en 2018, Léa Berquez (stage de L3 Informatique - UT3) en 2020, un pool de 10 étudiants de L3 informatique (TER - UT3) en 2021 et Mathieu Campan (stage de 1A ENSEEIHT) en 2022.

D'autres voies sont actuellement explorées pour permettre une exécution complètement non-visuelle du code.

## Technologies utilisées
Le logiciel utilise [processing.org](https://www.processing.org) et les librairies *[OpenCV](./tabgo/code/opencv_processing4.52.jar)* recompilé avec la version OpenCV 4.52, *[Video](https://github.com/processing/processing-video)* (pour la reconnaissance optique) et *[gson](https://github.com/google/gson)* (pour la création des fichiers **sb3**).
Enfin, une librairie de synthèse vocale en angalis est utilisée pour un feedback sonore (fournie directement).

## Installation (à n'effectuer qu'une fois)
* Téléchargement du logiciel [Processing.org](https://processing.org/download) 4.0
* Importation des librairies *[Video](https://github.com/processing/processing-video)* et *[TTSLib](https://www.local-guru.net/blog/pages/ttslib)* []téléchargeable aussi [ici](https://github.com/TaBGO/lecteur/blob/main/librairies/ttslib.zip) : 

`Sketch -> Importer une librairie... -> Ajouter une librairie...`
* Les librairise [gson](https://github.com/google/gson). Normalement la librairie *[gson](https://github.com/google/gson)* et *[OpenCV](./tabgo/code/opencv_processing4.52.jar)* se trouvent dans le sous-dossier **code** et seront chargées automatiquement. Si cela ne fonctionne pas, glissez-déposez les fichiers *.jar* dans la fenêtre Processing lors de l'ouverture du programme.

## Exécution
Après avoir appuyé sur *"lancer le programme Processing"* (bouton *"Play"*), vous pouvez scanner votre environnement de travail et commencer l'exécution du programme en appuyant sur la touche *"espace"*.

Si vous voulez lancer un script de test, appuyez sur *"t*" ou "*T*". Les fichiers de tests (images **.png**) se trouvent dans le sous-dossier **data**. Modifiez le fichier à tester dans la classe "*tabgo.pde*", dans la méthode "*creation*".
Le fichier **.sb3** obtenu se trouve dans le dossier "**data/sb3/Programme_scratch.sb3**" et peut ensuite être chargé et exécuté sur le site web [Scratch](https://scratch.mit.edu) : 

`Bouton Créer puis menu  File -> Load from your computer`

## Financement
Ce projet a été partiellement financé via un appel à projets de l'[UNADEV](https://www.unadev.com/nos-missions/appel-a-projets) - Financement **2019.49** 

## Publications en lien avec le projet
* Marco J.B., Baptiste-Jessel N., Truillet Ph., *[TaBGO : Programmation par blocs tangibles](https://hal.archives-ouvertes.fr/hal-02181953)* In: 30e Conference francophone sur l'Interaction Homme-Machine (IHM 2018), 23 October 2018 - 26 October 2018 (Brest, France)
* Andriamahery-Ranjalahy K., Berquez L., Jessel N., Truillet Ph., *[TaBGO: towards accessible computer science in secondary school](https://hal.archives-ouvertes.fr/hal-03168307v1)*, In : 23rd International Conference on Human-Computer Interaction (HCI International 2021), Jul 2021, virtual place, United States.
* Andriamahery-Ranjalahy K., Truillet Ph.,  *Permettre l’autonomie dans l’activité de programmation par blocs pour des enfants non-voyants*, In : 12e Conférence Handicap 2022, 8-10 Juin 2022 (Paris, France)
* Andriamahery Ranjalahy K., Campan M., Baptiste-Jessel ., Truillet Ph., *An Autonomous Approach for Bloc-Based Coding Activities Oriented Towards Visually Impaired Pupils*, **soon**
