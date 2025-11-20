#!/bin/bash


#Fonction qui permet d'ajouter un livre 
add_book() {

	if [ $# -lt 4 ]
	then
		echo "Usage : add_book <Titre> <Auteur> <Année> <Genre>
		return 1
	fi

	local titre="$1"
	local auteur="$2"
	local annee="$3"
	local genre="$4"
	local genre="disponible"

	echo "Ajout de $titre dans livres.txt"

	echo "${titre}|${titre}|${auteur}|${annee}|${genre}|${statut}" >> livres.txt

}

edit_book(){
}

delete_book(){}

list_books(){}



#4 emprunts:
#---------------------------raja----------------------------------

#fonction pour emprunter les livres 

emprunter_livre() {
    local titre livre_id emprunteur date_emprunt date_retour_prevue

    read -p "Titre du livre : " titre
    read -p "Nom de l'emprunteur : " emprunteur



    livre_id=$(obtenir_id_par_titre "$titre")

    if [ -z "$livre_id" ]; then
        echo "Aucun livre ne correspond à ce titre."
        return
    fi

    # Vérifier si le livre est disponible
    if ! grep -q "^$livre_id|" livres.txt || ! grep "^$livre_id|" livres.txt | grep -q "disponible"; then
        echo "Le livre n'est pas disponible."
        return
    fi

    # Dates
    date_emprunt=$(date +"%Y-%m-%d")
    date_retour_prevue=$(date -d "+14 days" +"%Y-%m-%d")

    # Ajouter l'emprunt à emprunts.txt
    echo "$livre_id|$emprunteur|$date_emprunt|$date_retour_prevue" >> emprunts.txt

    # Changer le statut du livre dans livres.txt
    sed -i "s/^$livre_id|\(.*\)|disponible$/$livre_id|\1|emprunté/" livres.txt

    echo "Le livre « $titre » a été emprunté par $emprunteur jusqu'au $date_retour_prevue."
}

#fonction pour verifier si le livre existe et est disponible
livre_existe() {
    local id="$1"
    grep -q "^$id|" livres.txt && grep "^$id|" livres.txt | grep -q "disponible"
}

#fonction pour obtenir l'id du livre par son titre
obtenir_id_par_titre() {
    local titre="$1"
    # Rechercher le livre par titre (insensible à la casse)
    grep -i "|$titre|" livres.txt | head -n 1 | cut -d '|' -f1
}


#fonction pour retourner les livres

retourner_livre() {
    local titre livre_id ligne emprunteur date_emprunt date_retour_reelle

    read -p "Titre du livre à retourner : " titre

    # Trouver l'ID correspondant
    livre_id=$(obtenir_id_par_titre "$titre")

    if [ -z "$livre_id" ]; then
        echo "Aucun livre ne correspond à ce titre."
        return
    fi

    # Trouver l'entrée dans emprunts.txt
    ligne=$(grep "^$livre_id|" emprunts.txt)

    if [ -z "$ligne" ]; then
        echo "Ce livre n'est actuellement pas emprunté."
        return
    fi

    emprunteur=$(echo "$ligne" | cut -d '|' -f2)
    date_emprunt=$(echo "$ligne" | cut -d '|' -f3)
    date_retour_reelle=$(date +"%Y-%m-%d")

    # Ajouter à l'historique
    echo "$livre_id|$emprunteur|$date_emprunt|$date_retour_reelle" >> historique.txt

    # Retirer des emprunts en cours
    grep -v "^$livre_id|" emprunts.txt > tmp && mv tmp emprunts.txt

    # Remettre le livre comme disponible
    sed -i "s/^$livre_id|\(.*\)|emprunté$/$livre_id|\1|disponible/" livres.txt

    echo "✔ Le livre « $titre » a été retourné avec succès."
}

#fonction pour lister les emprunts en cours

lister_emprunts() {
    echo "=== Livres empruntés ==="
    if [ ! -s emprunts.txt ]; then
        echo "Aucun emprunt."
        return
    fi
    cat emprunts.txt | column -t -s '|'
}

#fonction pour alerter sur les retards

alerte_retards() {
    local today
    today=$(date +"%Y-%m-%d")

    echo "=== Livres en retard ==="

    while IFS='|' read -r id emp date_e date_retour; do
        if [[ "$date_retour" < "$today" ]]; then
            echo "⚠ Livre $id emprunté par $emp en retard depuis $date_retour"
        fi
    done < emprunts.txt
}

#fonction pour afficher l'historique des emprunts
historique_emprunts() {
    echo "=== Historique des emprunts ==="
    if [ ! -s historique.txt ]; then
        echo "Aucun historique."
        return
    fi
    column -t -s '|' historique.txt
}



