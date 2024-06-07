/***************************************************************** 
                   CONDITIONS FONCTIONNEMENT
    - Ajouter Paths dans Variable environnement : 1er = Processing 
                                                  2nd = Scratch
    Pour ce faire : Aller dans Paramètres -> Système -> Paramètres avancés du système -> Variables d'environnement -> *Double clic* sur "Path" -> Nouveau puis gl ( soit Parcourir soit tu fais à la main )
    ( PS : Windows uniquiment pour le moment) 
    ( !!! POTENTIELLEMENT INUTILE !!!)
    
    - Mettre Ouverture de Programme_scratch.sb3 avec Scratch tout le temps ( celui dans 'tabgo', 'windows-amd64', 'data', 'sb3', 'Programme_scratch.sb3' )
    
    - Installer Node.js , faire npm install, npm install chokidar, npm install ps-node
 **************************************************************/

// Fonction pour exécuter une commande et retourner une promesse

const { exec, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const chokidar = require('chokidar');
const ps = require('ps-node');

// Chemin absolu vers le répertoire contenant le fichier tabgo
const PathLecteur = path.join(__dirname);
  
// Chemin absolu vers le répertoire contenant l'exécutable
const tabgoPath = path.join(PathLecteur, 'tabgo', 'windows-amd64', 'tabgo.exe');
  
const tabgoDir = path.dirname(tabgoPath);

const scratchExecutablePath = "Scratch 3.exe";

// Chemin absolu vers le fichier prog.sb3
const PathSB3 = path.join(PathLecteur, 'tabgo', 'windows-amd64', 'data', 'sb3', 'Programme_scratch.sb3');

//let scratchProcess = null;

function executeCommand(command, options = {}) {
    return new Promise((resolve, reject) => {
         exec(command, options, (error, stdout, stderr) => {
            if (error) {
                reject(`Erreur: ${error.message}`);
                return;
            }
            if (stderr) {
                console.warn(`stderr: ${stderr}`);
            }
            resolve(stdout);
        });
    });
}

const tabgoProcess = spawn(tabgoPath, { cwd: tabgoDir, shell: true });

tabgoProcess.stdout.on('data', (data) => {
    console.log(`tabgo stdout: ${data}`);
});

tabgoProcess.stderr.on('data', (data) => {
    console.error(`tabgo stderr: ${data}`);
});

tabgoProcess.on('close', (code) => {
    console.log(`tabgo process exited with code ${code}`);
});

function executeSB3(PathSB3) {
    executeCommand(PathSB3, { shell: true })
        .then((stdout) => {
            console.log(`Scratch ouvert: ${stdout}`);
        })
        .catch((error) => {
            console.error(error);
        })

};

function launchScratch(PathSB3) {
    // Tuer les processus Scratch existants
    ps.lookup({ command: 'Scratch 3.exe' }, (err, resultList) => {
        if (err) {
            throw new Error(err);
        }

        resultList.forEach(process => {
            if (process) {
                ps.kill(process.pid, (err) => {
                    if (err) {
                        console.error(`Error killing process ${process.pid}: ${err}`);
                    } else {
                        console.log(`Process ${process.pid} killed`);
                    }
                });
            }
        });

        // Lancer une nouvelle instance de Scratch après avoir tué les précédentes
        setTimeout(() => {
            const scratchProcess = executeSB3(PathSB3);

            if (!scratchProcess) {
                console.error('Failed to start Scratch process');
                return;
            }

            // Enregistrer un gestionnaire d'événements pour surveiller la fin du processus Scratch
            scratchProcess.on('close', (code) => {
                console.log(`Scratch exited with code ${code}`);
            });
        }, 1);  // Attendre 1 seconde avant de lancer Scratch
    });
}

launchScratch(PathSB3);

const watcher = chokidar.watch(PathSB3, { persistent: true });

watcher.on('change', (path) => {
    console.log(`${path} has been modified, relaunching Scratch...`);

    launchScratch(PathSB3);
});

// Fermer + ouvrir Scratch à chaque fois que nouveau sb3 créé.

// Ouvrir tabgo.pde, puis ouvrir Scratch
/*
executeCommand(cheminTabgo)
    .then((stdout) => {
        console.log(`Tabgo ouvert: ${stdout}`);
        return executeCommand(scratchPath);
    })
    .then((stdout) => {
        console.log(`Scratch ouvert: ${stdout}`);
    })
    .catch((error) => {
        console.error(error);
    });*/

// Fonction pour lancer Scratch avec le projet spécifié
/*function launchScratch(cheminSB3) {
    if (scratchProcess) {
        scratchProcess.kill();
    }
    scratchProcess = spawn(scratchExecutablePath, [cheminSB3], { shell: true });
    scratchProcess.on('close', (code) => {
        console.log(`Scratch exited with code ${code}`);
        scratchProcess = null;
    });
}*/
//launchScratch(cheminSB3);

// Exécuter tabgo.exe
/*const tabgoProcess = spawn(cheminExecutable, { cwd: tabgoDir, shell: true });

tabgoProcess.stdout.on('data', (data) => {
    console.log(`tabgo stdout: ${data}`);
});

tabgoProcess.stderr.on('data', (data) => {
    console.error(`tabgo stderr: ${data}`);
});

tabgoProcess.on('close', (code) => {
    console.log(`tabgo process exited with code ${code}`);
    if (scratchProcess) {
        scratchProcess.kill();
    }
});*/

// Surveiller les modifications du fichier Programme_scratch.sb3
/*fs.watchFile(cheminSB3, (curr, prev) => {
    if (curr.mtime !== prev.mtime) {
        console.log('Programme_scratch.sb3 a été modifié');
        launchScratch(cheminSB3);
    }
});*/

// Fermer proprement les processus lorsque le script est terminé
/*process.on('exit', () => {
    if (tabgoProcess) {
        tabgoProcess.kill();
    }
    if (scratchProcess) {
        scratchProcess.kill();
    }
});*/

//                                                                                       LETS GOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO

// Chemin Scratch

/*executeCommand(`cd ${tabgoDir} && tabgo.exe`, { shell: true })
    .then((stdout) => {
        console.log(`Programme tabgo.exe terminé: ${stdout}`);
        //launchScratch(cheminSB3);
        return executeCommand(PathSB3, { shell: true });
    })
    .then((stdout) => {
        console.log(`Scratch ouvert: ${stdout}`);
    })
    .catch((error) => {
        console.error(error);
    });*/


/*const http = require('http'); // Utilisation de la syntaxe require pour les anciens modules Node.js

const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello World');
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});
*/

/*
        Faire npm install

 */

/****************************************************
*                                                   *
*           Recherche fichier tabgo                 *
*                                                   *
*                                                   *
****************************************************/

/*const path = require('path');
const { exec } = require('child_process');
const fs = require('fs-extra');
function rechercherDossierTabgo(directory) {
    const cheminLecteur = path.join(directory, 'lecteur');
    const cheminTabgo = path.join(cheminLecteur, 'tabgo');

    console.log("Chemin du dossier 'lecteur' :", cheminLecteur);
    console.log("Chemin du dossier 'tabgo' :", cheminTabgo);

    if (fs.existsSync(cheminTabgo)) {
        return cheminTabgo; // Le dossier "tabgo" a été trouvé, retournez son chemin
    } else {
        return null; // Le dossier "tabgo" n'a pas été trouvé dans ce répertoire
    }
}*/

/********************   Fonction pour rechercher récursivement le dossier "tabgo"    *****************/

/*function rechercherDossierTabgo(directory) {

    try {
        let cheminTabgo = null;

        const fichiers = fs.readdirSync(directory, { withFileTypes: true });

        for (const fichier of fichiers) {
            try {
                const chemin = path.join(directory, fichier.name);

                if (fichier.isDirectory()) {
                    // Ignorer les répertoires cachés et les répertoires système
                    if (fichier.name.startsWith('.') || fichier.name === 'AppData' || fichier.name === 'Windows') {
                        continue;
                    }

                    // Rechercher récursivement dans ce répertoire
                    cheminTabgo = rechercherDossierTabgo(chemin);
                    if (cheminTabgo) {
                        return cheminTabgo; // Le dossier "tabgo" a été trouvé, retournez son chemin
                    }
                } else if (fichier.name === 'tabgo') {
                    return chemin; // Le dossier "tabgo" a été trouvé, retournez son chemin
                }
            } catch (erreur) {
                console.error("Erreur lors du traitement du fichier ou du répertoire :", erreur);
            }
        }

        // Le dossier "tabgo" n'a pas été trouvé dans ce répertoire
        return null;
    } catch (erreur) {
        console.error("Erreur lors de la lecture du répertoire :", erreur);
        return null;
    }
}
*/

/*************** Recherchez récursivement le dossier "tabgo" ***********************/

/*const cheminDossierTabgo = rechercherDossierTabgo(path.sep);
console.log("chemin initial :", path.sep);
if (cheminDossierTabgo) {
    console.log("Le dossier 'tabgo' a été trouvé :", cheminDossierTabgo);
} else {
    console.log("Le dossier 'tabgo' n'a pas été trouvé.");
}*/

// Chemin où vous souhaitez déplacer le dossier "tabgo"
//const nouvelEmplacement = path.join(__dirname, 'nouvel_emplacement');

// Recherche du dossier "tabgo" sur l'ordinateur de l'utilisateur
//const dossierTabgo = 'cheminDossierTabgo'; // Remplacez ceci par le chemin réel vers le dossier "tabgo" sur votre système

// Vérification de l'existence du dossier "tabgo"

/*if (fs.existsSync(dossierTabgo)) {
    try {
        // Déplacement du dossier "tabgo" vers le nouvel emplacement
        fs.moveSync(dossierTabgo, nouvelEmplacement, { overwrite: true });
        console.log('Le dossier "tabgo" a été déplacé avec succès.');
    } catch (erreur) {
        console.error('Une erreur s\'est produite lors du déplacement du dossier "tabgo":', erreur);
    }
} else {
    console.error('Le dossier "tabgo" n\'a pas été trouvé à l\'emplacement spécifié.');
}*/

// Chemin absolu vers le dossier contenant le sketch Processing
/*const cheminSketch = path.join(__dirname, '..', 'tabgo');

// Chemin absolu vers le fichier code Tabgo
const cheminFichierTabgo = path.join(__dirname, '..', 'tabgo.pde');

// Chemin vers l'exécutable processing-java
const cheminProcessingJava = 'processing';

// Commande pour lancer l'application Processing avec le fichier Tabgo spécifique
const commandeProcessing = '"' + cheminProcessingJava + '" --sketch=' + cheminSketch + ' --output=' + cheminSketch + ' --run ' + cheminFichierTabgo;

// Exécution de la commande
exec(commandeProcessing, (erreur, stdout, stderr) => {
    if (erreur) {
        console.error(`Erreur : ${erreur}`);
        return;
    }
    console.log(`Sortie standard : ${stdout}`);
    console.error(`Sortie erreur : ${stderr}`);
});
*/

/*const { exec } = require('child_process');
const path = require('path');

// Chemin absolu vers le dossier contenant le sketch Processing
const cheminSketch = 'C:\\TaBGO_BE\\lecteur\\tabgo';

// Chemin vers l'exécutable processing-java
const cheminProcessingJava = 'C:\\Program Files\\processing-4.3\\processing';

// Commande pour exporter le sketch Processing en un exécutable autonome
const commandeExport = '"' + cheminProcessingJava + '" --sketch=' + cheminSketch + ' --output=' + cheminSketch + ' --force --run';

// Exécution de la commande d'export
exec(commandeExport, (erreur, stdout, stderr) => {
    if (erreur) {
        console.error(`Erreur lors de l'export : ${erreur}`);
        return;
    }

    console.log(`Export terminé : ${stdout}`);
    console.error(`Sortie erreur : ${stderr}`);

    // Chemin absolu vers l'exécutable généré
    const cheminExecutable = path.join(cheminSketch, 'application.windows64', 'tabgo.exe');

    // Commande pour exécuter l'application Tabgo
    const commandeExecution = '"' + cheminExecutable + '"';

    // Exécution de l'application Tabgo
    exec(commandeExecution, (erreurExec, stdoutExec, stderrExec) => {
        if (erreurExec) {
            console.error(`Erreur lors de l'exécution de Tabgo : ${erreurExec}`);
            return;
        }
        console.log(`Tabgo exécuté : ${stdoutExec}`);
        console.error(`Sortie erreur : ${stderrExec}`);
    });
});*/








/******************************************
 *                                        *
 *                                        *
 *            Bonne partie                *
 *                                        *
 *                                        *
 *****************************************/


//const { execFile, exec } = require('child_process');
//const path = require('path');

// Chemin absolu vers le répertoire contenant le fichier tabgo
//const cheminLecteur = path.join(__dirname, 'lecteur');

// Chemin absolu vers le fichier tabgo.pde
//const cheminTabgo = path.join(cheminLecteur, 'tabgo', 'tabgo.pde');

// Commande pour lancer le fichier tabgo.pde avec Processing
//const commandeProcessing = `processing --sketch=${cheminLecteur} --run ${cheminTabgo}`;

// Afficher le chemin de l'exécutable pour vérification
/*console.log(`Chemin de l'exécutable : ${cheminExecutable}`);

// Commande pour lancer l'exécutable
const commandeLancement = `"${cheminExecutable}"`;*/

// Chemin Scratch
//const scratchPath = '"Scratch 3.exe"';

// Exécuter la commande
/*******************************************************
 * exec(cheminTabgo, (erreur, stdout, stderr) => {
    if (erreur) {
        console.error(`Erreur : ${erreur.message}`);
        return;
    }
    if (stderr) {
        console.error(`Erreur standard : ${stderr}`);
        return;
    }
    console.log(`Sortie standard : ${stdout}`);
});

exec(scratchPath, (erreur, stdout, stderr) => {
    if (erreur) {
        console.error(`Erreur : ${erreur.message}`);
        return;
    }
    if (stderr) {
        console.error(`Erreur standard : ${stderr}`);
        return;
    }
    console.log(`Sortie standard : ${stdout}`);
});
********************************************************/

// Commande pour lancer Scratch avec le projet
//const commandeLancement = `xdg-open "${cheminSB3}"`;

// Chemin absolu vers le fichier prog.sb3
//const cheminSB3 = path.join(cheminLecteur, 'tabgo', 'windows-amd64', 'data','sb3','Programme_scratch.sb3');

// Afficher le chemin du projet pour vérification
//console.log(`Chemin du projet : ${cheminSB3}`);

// Exécuter la commande
/*exec(cheminSB3, (erreur, stdout, stderr) => {
    if (erreur) {
        console.error(`Erreur : ${erreur.message}`);
        console.error(`Code de sortie : ${erreur.code}`);
        console.error(`Signal reçu : ${erreur.signal}`);
        return;
    }
    if (stderr) {
        console.error(`Erreur standard : ${stderr}`);
    }
    console.log(`Sortie standard : ${stdout}`);
});*/


// Fonction pour exécuter un programme et retourner une promesse
/***********************************************************
  function executeProgram(program) {
    return new Promise((resolve, reject) => {
        execFile(program, (error, stdout, stderr) => {
            if (error) {
                reject(`Erreur: ${error.message}`);
                return;
            }
            if (stderr) {
                reject(`stderr: ${stderr}`);
                return;
            }
            resolve(stdout);
        });
    });
}
**********************************************************/