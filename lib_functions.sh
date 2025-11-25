#!/bin/bash


ajoute_livre() {

    while true
    do
        read -p "Titre : " titre
        [[ -n "$titre" ]] && break
        echo "Erreur : le titre ne peut pas être vide."
    done

    while true
     do
        read -p "Auteur : " auteur
        [[ -n "$auteur" ]] && break
        echo "Erreur : l'auteur ne peut pas être vide."
    done

    while true
    do
        read -p "Année : " annee
        [[ -n "$annee" ]] && break
        echo "Erreur : l'année ne peut pas être vide."
    done

    while true
    do
        read -p "Genre : " genre
        [[ -n "$genre" ]] && break
        echo "Erreur : le genre ne peut pas être vide."
    done

    read -p "Statut (disponible par défaut) : " statut
    statut=${statut:-disponible}

    local dern_id=`tail -n 1 livres.txt | cut -d '|' -f1`

	if [[ -z "$dern_id" ]]
	then
		nouv_id="001"
	else
		nouv_id=`printf "%03d" $((10#$dern_id + 1))`
	fi

    echo "${nouv_id}|${titre}|${auteur}|${annee}|${genre}|${statut}" >> livres.txt
	echo "Livre ajouté avec l'ID : $nouv_id"

}
demander_modification() {
    local message="$1"
    local valeur_actuelle="$2"
    local valeur_lue

    read -p "$message [$valeur_actuelle] : " valeur_lue
    echo "${valeur_lue:-$valeur_actuelle}"
}
remplacer_ligne_fichier() {
    local id="$1"
    local nouvelle_ligne="$2"
    local fichier="$3"
    local tmpfile="${fichier}.tmp"

    > "$tmpfile"

    while IFS= read -r l; do
        if [[ $l == "$id|"* ]]; then
            echo "$nouvelle_ligne" >> "$tmpfile"
        else
            echo "$l" >> "$tmpfile"
        fi
    done < "$fichier"

    mv "$tmpfile" "$fichier"
}
verifier_doublon() {
    local id="$1"            
    local titre="$2"
    local auteur="$3"
    local annee="$4"
    local fichier="$5"

    doublon=`awk -F'|' -v id="$id" -v t="$titre" -v a="$auteur" -v y="$annee" '
        $1 != id && $2 == t && $3 == a && $4 == y { print $0 }
    ' "$fichier"`

    if [[ -n "$doublon" ]]; then
        echo "Attention : un livre identique existe déjà :"
        echo "$doublon"
        return 1 
    else
        return 0 
    fi
}
modifier_livre() {
    while true
    do
        read -p "Entrez l'ID du livre (ou e pour sortir) : " id

        if [[ "$id" = "e" ]]; then
            echo "Sortie."
            return 0 
        fi

        if ! [[ "$id" =~ ^[0-9]+$ ]]; then
            echo "Erreur : l'ID doit être un nombre."
            continue
        fi

        ligne=`grep -E "^$id\|" livres.txt`

        if [[ -n "$ligne" ]]; then
            echo "Livre trouvé : $ligne"
            break  
        else
            echo "Aucun livre trouvé avec cet ID. Réessayez."
        fi
    done

    echo "Pour chaque champ, tapez la nouvelle information ou appuyez sur Entrée si vous ne voulez pas modifier."

    _id=`echo "$ligne" | cut -d'|' -f1`
    _titre=`echo "$ligne" | cut -d'|' -f2`
    _auteur=`echo "$ligne" | cut -d'|' -f3`
    _annee=`echo "$ligne" | cut -d'|' -f4`
    _genre=`echo "$ligne" | cut -d'|' -f5`
    _statut=`echo "$ligne" | cut -d'|' -f6-`

    titre=`demander_modification "Titre" "$_titre"`
    auteur=`demander_modification "Auteur" "$_auteur"`
    annee=`demander_modification "Année" "$_annee"`
    genre=`demander_modification "Genre" "$_genre"`
    statut=`demander_modification "Statut" "$_statut"`

    nouvelle_ligne="$id|$titre|$auteur|$annee|$genre|$statut"

    [ ! verifier_doublon ] && echo "Ce livre existe déjà" && return 1
    
    remplacer_ligne_fichier "$id" "$nouvelle_ligne" "livres.txt"

    echo "Livre modifié avec succès !"

}

supprime_livre(){

    while true
    do
        read -p "Entrez l'ID du livre (ou e pour sortir) : " id

        if [[ "$id" = "e" ]]; then
            echo "Sortie."
            return 0 
        fi

        if ! [[ "$id" =~ ^[0-9]+$ ]]; then
            echo "Erreur : l'ID doit être un nombre."
            continue
        fi

        ligne=`grep -E "^$id\|" livres.txt`

        if [[ -n "$ligne" ]]; then
            echo "Livre trouvé : $ligne"
            break  
        else
            echo "Aucun livre trouvé avec cet ID. Réessayez."
        fi
    done
    
    grep -v "^$id|" livres.txt > tmp.txt
    mv tmp.txt livres.txt

    echo "Livre supprimé !"

}
lister_livres() {
    
    echo "Voici la liste des livres dans la bibliothèques"
    cat livres.txt

}

