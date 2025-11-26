# Projet Shell 

Créer un système complet de gestion de livres avec fichiers plats

### Membres 

Arbia Bochra (22408220) : Gestion de livres  
Talbi Imane (22408534): Recherche et filtres  
Boumghar Imene : Statistiques et rapports  
Ouali Raja (22321721): Emprunts  


### Gestion des livres : Bochra

**ajouter_livre** : ajoute un nouveau livre dans livres.txt, et génère un ID. On utilise la commande read , on vérifie que le champ n'est pas vide, ensuite on vérifie que le livre n'existe pas dans le fichier afin de ne pas avoir de doublons grâce à une fonction intermédiaire. S'il existe on sort sinon on reprends le dernier ID crée et on l'incrémente. On finit par ajouter le livre au fichier.

**modifier_livre** : Modifie un livre existant, on a crée deux fonctions intermédiaires, on réutilise celle qui vérifie l'unicité des livres, on a crée une pour demander les modifications, et une pour remplacer la ligne dans le fichier. Si l'utilisateur ne souhaite pas modifier un champ, il appuie sur entrée, et e s'il veut sortir. 

**supprimer_livre** : Permet de supprimer un livre du fichier livres.txt avec son ID. Demande un ID tant que l'ID n'est pas valide, l'utilisateur peut sortir en appuyant sur e, on retranstrit les modifications dans un nouveau fichier et écrase le contenu de l'ancien fichier pour le remplacer.

**lister_livres** : Permet de lister tous les livres dans le fichier livres.txt.





### Emprunts : Ouali Raja

emprunter_livre :
Permet d’emprunter un livre en saisissant son titre et le nom de l’emprunteur. On récupère l’ID du livre à partir du titre grâce à une fonction auxiliaire.
La fonction vérifie ensuite si le livre existe et s’il est bien disponible. Si oui, elle ajoute une ligne dans emprunts.txt contenant l’ID, l’emprunteur, la date d’emprunt et la date de retour prévue (dans 14 jours). Enfin, elle modifie le statut du livre dans livres.txt en le passant à "emprunté".

retourner_livre :
Permet de retourner un livre emprunté. L’utilisateur saisit le titre du livre, on retrouve son ID et l'entrée correspondante dans emprunts.txt. Si le livre est bien emprunté, l’emprunt est déplacé dans historique.txt avec la date réelle de retour. Le livre est retiré de la liste des emprunts en cours et son statut est remis à "disponible" dans livres.txt.

lister_emprunts :
Affiche tous les emprunts actuellement en cours. Si aucun emprunt n’est enregistré dans emprunts.txt, un message indique que la liste est vide.

alerte_retards :
Analyse chaque emprunt dans emprunts.txt et compare la date de retour prévue avec la date actuelle. Lorsqu’un emprunt dépasse la date limite, la fonction affiche une alerte indiquant l'ID du livre et le nom de l’emprunteur qui est en retard.

historique_emprunts :
Affiche l’historique complet des livres empruntés et déjà retournés. Les informations proviennent du fichier historique.txt, contenant les dates d’emprunt et de retour effectives.

obtenir_id_par_titre (fonction auxiliaire) :
Recherche dans livres.txt la première entrée correspondant au titre fourni, et renvoie l’ID associé. Permet de relier les emprunts à l’ID unique du livre.

livre_existe (fonction auxiliaire) :
Vérifie qu’un ID correspond à un livre existant et que ce livre est disponible. Utilisée pour sécuriser les opérations d’emprunt.


### Recherche et filtres : imane TALBI 

recherche_par_titre: Demande à l’utilisateur un titre et affiche tous les livres dont le titre contient le mot saisi. Si aucun livre ne correspond, un message indique qu’aucun résultat n’a été trouvé.

recherche_par_auteur: Demande à l’utilisateur un nom d’auteur et affiche tous les livres correspondants. Si aucun auteur ne correspond, un message indique qu’aucun résultat n’a été trouvé.

filtrer_par_genre: Demande un genre et affiche tous les livres appartenant à ce genre. Si aucun livre ne correspond, un message indique qu’aucun résultat n’a été trouvé.

filtrer_par_annee: Demande un intervalle d’années et affiche tous les livres publiés entre ces années. Si aucun livre n’est trouvé dans l’intervalle, un message indique qu’aucun résultat n’a été trouvé.

recherche_avancee : Permet de rechercher des livres en combinant plusieurs critères (titre, auteur, année, genre, statut). L’utilisateur peut ignorer certains critères en entrant un symbole spécial(#) ou de lisser le critère vide. Affiche tous les livres correspondant aux critères ou un message si aucun résultat n’est trouvé.







