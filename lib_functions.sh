#!/bin/bash


#Fonction de gestion des livres (Bochra)
demander_champ() {
    local message="$1"
    local valeur=""

    while [[ -z "$valeur" ]]; do
        read -p "$message" valeur
        if [[ -z "$valeur" ]]; then
            echo "Erreur : ce champ ne peut pas être vide."
        fi
    done
    echo "$valeur"
}

ajoute_livre() {

    while true; do
        read -p "Titre : " titre
        [[ -n "$titre" ]] && break
        echo "Erreur : le titre ne peut pas être vide."
    done

    # Auteur obligatoire
    while true; do
        read -p "Auteur : " auteur
        [[ -n "$auteur" ]] && break
        echo "Erreur : l'auteur ne peut pas être vide."
    done

    # Année obligatoire
    while true; do
        read -p "Année : " annee
        [[ -n "$annee" ]] && break
        echo "Erreur : l'année ne peut pas être vide."
    done

    while true; do
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

    # Vérifier si un autre livre (ID différent) a déjà le même Titre|Auteur|Année
    doublon=$(awk -F'|' -v id="$id" -v t="$titre" -v a="$auteur" -v y="$annee" '
        $1 != id && $2 == t && $3 == a && $4 == y { print $0 }
    ' "$fichier")

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

        ligne=$(grep -E "^$id\|" livres.txt)

        if [[ -n "$ligne" ]]; then
            echo "Livre trouvé : $ligne"
            break  
        else
            echo "Aucun livre trouvé avec cet ID. Réessayez."
        fi
    done

    echo "Pour chaque champ, tapez la nouvelle information ou appuyez sur Entrée si vous ne voulez pas modifier."

    _id=$(echo "$ligne" | cut -d'|' -f1)
    _titre=$(echo "$ligne" | cut -d'|' -f2)
    _auteur=$(echo "$ligne" | cut -d'|' -f3)
    _annee=$(echo "$ligne" | cut -d'|' -f4)
    _genre=$(echo "$ligne" | cut -d'|' -f5)
    _statut=$(echo "$ligne" | cut -d'|' -f6-)

    titre=$(demander_modification "Titre" "$_titre")
    auteur=$(demander_modification "Auteur" "$_auteur")
    annee=$(demander_modification "Année" "$_annee")
    genre=$(demander_modification "Genre" "$_genre")
    statut=$(demander_modification "Statut" "$_statut")

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

        ligne=$(grep -E "^$id\|" livres.txt)

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


#recherches et filtres
#------------------ IMANE ---------------------------------

fichier="livres.txt"

recherche_par_titre () {
[ "$#" -eq 0 ] && echo "Erreur : Veuillez specifier un titre de livre a rechercher." && exit 1
local recherche="$1"
local trouve=0

while IFS='|' read -r id titre auteur annee genre statut; do
        if echo "$titre" | grep -iq "$recherche"; then
            echo "ID: $id | Titre: $titre | Auteur: $auteur | Statut: $statut"
            trouve=1
        fi
done < "$fichier"
if [ "$trouve" -eq 0 ]; then
 echo "Aucun livre ne correspond au titre : $recherche"
 return 1
fi
}


recherche_par_auteur () {
[ "$#" -eq 0 ] && echo "Erreur : Veuillez specifier un nom d'auteur a rechercher." && exit 2
local recherche="$1"
local trouve=0

while IFS='|' read -r id titre auteur annee genre statut; do
        if echo "$auteur" | grep -iq "$recherche"; then
            echo "ID: $id | Titre: $titre | Auteur: $auteur | Statut: $statut"
            trouve=1
        fi
done < "$fichier"

if [ "$trouve" -eq 0 ]; then
    echo "Aucun auteur ne correspond à : $recherche"
    return 1
fi
}


filtrer_par_genre() {
[ "$#" -eq 0 ] && echo "Erreur : Veuillez specifier un genre a rechercher." && exit 2
local recherche="$1"
local trouve=0

while IFS='|' read -r id titre auteur annee genre statut; do
        if echo "$genre" | grep -iq "$recherche"; then
            echo "ID: $id | Titre: $titre | Auteur: $auteur | Genre: $genre | Annee: $annee | Statut: $statut"
            trouve=1
        fi
done < "$fichier"

if [ "$trouve" -eq 0 ]; then
    echo "Aucun livre n'appartient au genre : $recherche"
    return 1
    fi
return 0
}


filtrer_par_annee() {
[ "$#" -lt 2 ] && echo "Erreur : Veuillez specifier un intervelle des annees" && exit 3
local debut="$1"
local fin="$2"
local trouve=0

while IFS='|' read -r id titre auteur annee genre statut; do
    if [ "$annee" -ge "$debut" ] && [ "$annee" -le "$fin" ]; then
       echo "ID: $id | Titre: $titre | Auteur: $auteur | Genre: $genre | Annee: $annee | Statut: $statut"
    trouve=1
    fi
done < "$fichier"
if [ "$trouve" -eq 0 ]; then
    echo "Aucun livre entre $debut et $fin"
    return 1
    fi
}


#recherche avance par titre auteur genre
recherche_avancee() {
[ "$#" -lt 3 ] && echo "Erreur: Veillez specifier 3 criteres(Titre auteur genre)" && exit 4
local titre_recherche="$1"
local auteur_recherche="$2"
local genre_recherche="$3"
local trouve=0

while IFS='|' read -r id titre auteur annee genre statut; do
    if [[ "$titre" == *"$titre_recherche"* ]] && [[ "$auteur" == *"$auteur_recherche"* ]] && [[ "$genre" == *"$genre_recherche"* ]]; then
       echo "ID: $id | Titre: $titre | Auteur: $auteur | Genre: $genre | Annee: $annee | Statut: $statut"
       trouve=1
    fi
done < "$fichier"
if [ "$trouve" -eq 0 ]; then
    echo "Aucun livre ne correspond à : Titre='$titre_recherche', Auteur='$auteur_recherche', Genre='$genre_recherche'"
    return 1
fi
}
 
# =================================================================
# 3. STATISTIQUES ET RAPPORTS (Imene)
# =================================================================

# 3.1 Nombre total de livres
stats_total() {
    echo "--- Nombre total de livres ---"
    if [ -s "livres.txt" ]; then
        local total_livres=$(wc -l < livres.txt | xargs)
        echo "Nombre Total de livres : $total_livres livres enregistrés."
    else
        echo "Le fichier livres.txt est vide ou n'existe pas."
    fi
}

# 3.2 Répartition par genre (Graphique ASCII)
stats_genre() {
    echo "--- Répartition des livres par genre (Graphique ASCII) ---"
    if [ ! -s "livres.txt" ]; then
        echo "Le fichier livres.txt est vide ou n'existe pas."
        return
    fi

    # 1. Compter les genres (5ème champ)
    local genres_counts=$(awk -F'|' '{print $5}' livres.txt | sort | uniq -c | sort -nr)
    
    if [ -z "$genres_counts" ]; then
        echo "Aucun genre trouvé."
        return
    fi

    local max_count=$(echo "$genres_counts" | head -n 1 | awk '{print $1}')
    local echelle_max=50 
    local total_livres=$(wc -l < livres.txt | xargs)

    echo "Genres / Nombre de livres :"
    echo "$genres_counts" | while IFS= read -r line; do
        local count=$(echo "$line" | awk '{print $1}')
        local genre=$(echo "$line" | awk '{$1=""; print $0}' | xargs)
        
        # Calcul du pourcentage et de la longueur de la barre (utilise bc pour le calcul flottant)
        local pourcentage=$(echo "scale=1; ($count / $total_livres) * 100" | bc)
        local longueur_barre=$(echo "scale=0; ($count * $echelle_max) / $max_count" | bc)
        
        # Afficher le genre, le compte et le graphique (█ est le caractère barre)
        printf "%-20s (%3s livres - %5.1f%%) : %s\n" "$genre" "$count" "$pourcentage" "$(printf '█%.0s' $(seq 1 $longueur_barre))"
    done
}

# 3.3 Top 5 auteurs les plus présents
top_auteurs() {
    echo "--- Top 5 Auteurs ---"
    if [ ! -s "livres.txt" ]; then
        echo "Le fichier livres.txt est vide ou n'existe pas."
        return
    fi

    # Extraire et compter les auteurs (3ème champ), trier et prendre le top 5
    awk -F'|' '{print $3}' livres.txt | sort | uniq -c | sort -nr | head -n 5 | while IFS= read -r line; do
        local count=$(echo "$line" | awk '{print $1}')
        local auteur=$(echo "$line" | awk '{$1=""; print $0}' | xargs)
        printf "%s livres : %s\n" "$count" "$auteur"
    done
}

# 3.4 Livres par décennie
stats_decennies() {
    echo "--- Livres par décennie ---"
    if [ ! -s "livres.txt" ]; then
        echo "Le fichier livres.txt est vide ou n'existe pas."
        return
    fi
    
    # Calcule la décennie (ex: 1984 -> 1980), compte et trie
    awk -F'|' '
        /^[0-9]*\|.*\|.*\|[0-9]{4}\|/ {
            decennie = int($4/10)*10; 
            print decennie
        }
    ' livres.txt | sort -n | uniq -c | sort -n | while IFS= read -r line; do
        local count=$(echo "$line" | awk '{print $1}')
        local debut=$(echo "$line" | awk '{print $2}')
        local fin=$((debut + 9)) 
        printf "Années %s-%s : %s livres\n" "$debut" "$fin" "$count"
    done
}

# 3.5 Export des résultats en HTML ou PDF
export_html_pdf() {
    echo "--- Export des résultats ---"
    read -p "Format d'export (html/h ou pdf/p) : " format

    case "$format" in
        html|H|h) format="html";;
        pdf|P|p) format="pdf";;
        *) echo "Format non reconnu. Annulation de l'export."; return;;
    esac

    read -p "Nom du fichier de sortie (par défaut: rapport_bibliotheque) : " nom_fichier
    local fichier_sortie="${nom_fichier:-rapport_bibliotheque}.${format}"

    if [ "$format" = "html" ]; then
        echo "Création du fichier HTML : $fichier_sortie"
        
        # Début du fichier HTML (utilisation de Here Document)
        cat <<EOT > "$fichier_sortie"
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="UTF-8"><title>Rapport Bibliothèque</title>
<style> table { border-collapse: collapse; width: 100%; } th, td { border: 1px solid #ddd; padding: 10px; text-align: left; } th { background-color: #f2f2f2; } pre { background-color: #eee; padding: 15px; } </style>
</head>
<body><h1>Rapport de la Bibliothèque Personnelle</h1>
<h2>Liste des Livres</h2>
<table>
    <tr><th>ID</th><th>Titre</th><th>Auteur</th><th>Année</th><th>Genre</th><th>Statut</th></tr>
EOT
        
        # Ajout des données de livres.txt
        if [ -s "livres.txt" ]; then
            awk -F'|' '{ print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 "</td><td>" $4 "</td><td>" $5 "</td><td>" $6 "</td></tr>" }' livres.txt >> "$fichier_sortie"
        else
            echo "<tr><td colspan='6'>Aucun livre enregistré.</td></tr>" >> "$fichier_sortie"
        fi

        # Fin du tableau et ajout des statistiques
        cat <<EOT >> "$fichier_sortie"
</table>
<h2>Statistiques</h2>
<pre>
EOT
        
        # Rediriger la sortie des fonctions statistiques vers le fichier HTML
        stats_total | grep -v '---' >> "$fichier_sortie"
        echo "" >> "$fichier_sortie"
        stats_genre | grep -v '---' | grep -v 'Genres /' >> "$fichier_sortie"
        echo "" >> "$fichier_sortie"
        top_auteurs | grep -v '---' >> "$fichier_sortie"
        echo "" >> "$fichier_sortie"
        stats_decennies | grep -v '---' >> "$fichier_sortie"
        
        # Fermer les balises
        cat <<EOT >> "$fichier_sortie"
</pre>
</body></html>
EOT
        
        echo "✔ Export HTML terminé. Fichier : $fichier_sortie"
    elif [ "$format" = "pdf" ]; then
        echo "L'export PDF nécessite un outil externe. Le HTML a été choisi comme livrable pour ce projet."
    fi
}

# =================================================================
# 5. SAUVEGARDE ET BACKUP 
# =================================================================

backup_manuel() {
    echo "--- Sauvegarde Manuelle ---"
    echo "Fonction à implémenter pour créer une archive compressée des fichiers de données."
}

afficher_backups() {
    echo "--- Liste des Backups ---"
    echo "Fonction à implémenter pour lister les backups existants."
}
 




