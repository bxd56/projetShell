# Projet Shell 

Créer un système complet de gestion de livres avec fichiers plats

### Membres 

Arbia Bochra (22408220) : Gestion de livres  
Talbi Imane : Recherche et filtres  
Boumghar Imene : Statistiques et rapports  
Ouali Raja (22321721): Emprunts  


### Gestion des livres : Bochra

**ajouter_livre** : ajoute un nouveau livre dans livres.txt, et génère un ID. On utilise la commande read , on vérifie que le champ n'est pas vide puis on reprends le dernier ID crée et on l'incrémente. On finit par ajouter le livre au fichier.

**modifier_livre** : Modifie un livre existant, on a crée trois fonctions intermédiaires, une pour demander les modifications, une pour remplacer la ligne dans le fichier et une pour vérifier que le livre n'existe pas déjà (s'il existe on sort et on ne modifie pas). Si l'utilisateur ne souhaite pas modifier un champ, il appuie sur entrée, et e s'il veut sortir. 

**supprimer_livre** : Permet de supprimer un livre du fichier livres.txt avec son ID. Demande un ID tant que l'ID n'est pas valide, l'utilisateur peut sortir en appuyant sur e, on retranstrit les modifications dans un nouveau fichier et écrase le contenu de l'ancien fichier pour le remplacer.

**lister_livres** : Permet de lister tous les livres dans le fichier livres.txt.
