#!/bin/bash

fichier="livres.txt"

_verifier_doublon() {

    local titre="$1"
    local auteur="$2"
    local annee="$3"
    local fichier="$4"

    doublon=`awk -F'|'  -v t="$titre" -v a="$auteur" -v y="$annee" '
        $2 == t && $3 == a && $4 == y { print $0 }
    ' "$fichier"`

    if [[ -n "$doublon" ]]; then
        echo "Attention : un livre identique existe déjà :"
        echo "$doublon"
        return 1 
    else
        return 0 
    fi
}
verifier_annee() {
    local annee="$1"

    if [[ -z "$annee" ]]; then
        echo "Erreur : l'année ne peut pas être vide."
        return 1
    fi

    if ! [[ "$annee" =~ ^[0-9]+$ ]]; then
        echo "Erreur : l'année doit être un nombre."
        return 1
    fi

    local annee_courante=$(date +%Y)
    if (( annee > annee_courante )); then
        echo "Erreur : l'année ne peut pas être supérieure à $annee_courante."
        return 1
    fi

    if (( annee < 0 )); then
        echo "Erreur : l'année doit être positive."
        return 1
    fi

    return 0   
}
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

        if verifier_annee "$annee"
        then
            break
        else
            echo "Année non valide"

        fi
    done

    while true
    do
        read -p "Genre : " genre
        [[ -n "$genre" ]] && break
        echo "Erreur : le genre ne peut pas être vide."
    done

    read -p "Statut (disponible par défaut) : " statut
    statut=${statut:-disponible}
    _verifier_doublon "$titre" "$auteur" "$annee" "$fichier" || { return 1; }

    local dern_id=`tail -n 1 "$fichier" | cut -d '|' -f1`
    if [[ -z "$dern_id" ]]
	then
		nouv_id="001"
	else
		nouv_id=`printf "%03d" $((10#$dern_id + 1))`
	fi

    echo -e "${nouv_id}|${titre}|${auteur}|${annee}|${genre}|${statut}" >> "$fichier"
	echo "Livre ajouté avec l'ID : $nouv_id"

}
_demander_modification() {
    local message="$1"
    local valeur_actuelle="$2"
    local valeur_lue

    read -p "$message [$valeur_actuelle] : " valeur_lue
    echo "${valeur_lue:-$valeur_actuelle}"
}
_remplacer_ligne_fichier() {
    local id="$1"
    local nouvelle_ligne="$2"
    local fichier="$3"
    local tmpfile="${fichier}.tmp"

    > "$tmpfile"

    awk -F'|' -v id="$id" -v nl="$nouvelle_ligne" '
        $1 == id {print nl; next}
        {print}
    ' "$fichier" > "$tmpfile" && mv "$tmpfile" "$fichier"
}
modifier_livre() {

    while true
    do
        read -p "Entrez l'ID du livre (ou q pour quitter) : " id

        if [[ "$id" = "q" ]]; then
            echo "Sortie."
            return 0
        fi

        if ! [[ "$id" =~ ^[0-9]+$ ]]; then
            echo "Erreur : l'ID doit être un nombre."
            continue
        fi

        ligne=`grep -E "^$id\|" "$fichier"`

        if [[ -n "$ligne" ]]; then
            echo "Livre trouvé : $ligne"
            break
        else
            echo "Aucun livre trouvé avec cet ID. Réessayez."
        fi
    done

    echo "Pour chaque champ, tapez la nouvelle information ou appuyez sur Entrée si vous ne voulez pas modifier."

    # Extraction et nettoyage des champs
    _id=`echo "$ligne" | cut -d'|' -f1 | tr -d '\r\n'`
    _titre=`echo "$ligne" | cut -d'|' -f2 | tr -d '\r\n'`
    _auteur=`echo "$ligne" | cut -d'|' -f3 | tr -d '\r\n'`
    _annee=`echo "$ligne" | cut -d'|' -f4 | tr -d '\r\n'`
    _genre=`echo "$ligne" | cut -d'|' -f5 | tr -d '\r\n'`
    _statut=`echo "$ligne" | cut -d'|' -f6- | tr -d '\r\n'`

    # Champs texte simples
    titre=`_demander_modification "Titre" "$_titre"`
    titre=`echo "$titre" | tr -d '\r\n'`

    auteur=`_demander_modification "Auteur" "$_auteur"`
    auteur=`echo "$auteur" | tr -d '\r\n'`

    while true
    do
        read -p "Année [$_annee] (Entrée pour garder) : " saisie

        if [[ -z "$saisie" ]]; then
            annee="$_annee"
            break
        fi

        verifier_annee "$saisie"
        if [[ $? -eq 0 ]]; then
            annee="$saisie"
            break
        fi

        echo "Valeur invalide. Entrez une année valide ou appuyez sur Entrée pour garder : $_annee"
    done
    annee=`echo "$annee" | tr -d '\r\n'`

    genre=`_demander_modification "Genre" "$_genre"`
    genre=`echo "$genre" | tr -d '\r\n'`

    statut=`_demander_modification "Statut" "$_statut"`
    statut=`echo "$statut" | tr -d '\r\n'`

    nouvelle_ligne="$id|$titre|$auteur|$annee|$genre|$statut"
    ancienne_ligne="$id|$_titre|$_auteur|$_annee|$_genre|$_statut"

    if [[ "$nouvelle_ligne" == "$ancienne_ligne" ]]; then
        echo "Aucune modification détectée. Le livre reste inchangé."
        return 0
    fi

    _verifier_doublon "$titre" "$auteur" "$annee" "$fichier" || { return 1; }

    _remplacer_ligne_fichier "$id" "$nouvelle_ligne" "$fichier"

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

        ligne=`grep -E "^$id\|" "$fichier"`

        if [[ -n "$ligne" ]]; then
            echo "Livre trouvé : $ligne"
            break  
        else
            echo "Aucun livre trouvé avec cet ID. Réessayez."
        fi
    done
    
    grep -v "^$id|" "$fichier" > tmp.txt
    mv tmp.txt "$fichier"

    echo "Livre supprimé !"

}
lister_livres() {

    read -p "Combien de livres souhaitez vous afficher ? (10 par defaut) " page_user
    page_size=${page_user:-10}

    local total_lines=$(wc -l < "$fichier")
    local current_line=1

    # Si le fichier est vide
    if (( total_lines == 0 )); then
        echo "Aucun livre enregistré."
        return
    fi

    while (( current_line <= total_lines ))
    do
        clear
        echo "Affichage des livres — lignes $current_line à $((current_line + page_size - 1))"
        echo "-----------------------------------------------------------"

        sed -n "${current_line},$((current_line + page_size - 1))p" "$fichier"

        echo "-----------------------------------------------------------"
        echo "Page $(( (current_line - 1) / page_size + 1 )) / $(( (total_lines + page_size - 1) / page_size ))"
        echo "Appuie sur Entrée pour continuer, q pour quitter…"
        read -r input

        [[ "$input" == "q" ]] && break

        (( current_line += page_size ))
    done
}
#4 emprunts:
#---------------------------raja----------------------------------

#fonction pour emprunter les livres 

emprunter_livre() {
    local choix livre_id titre dispo emprunteur date_emprunt ligne_livre

    echo "Rechercher le livre par :"
    echo "1) ID"
    echo "2) Titre"
    read -p "Votre choix (1 ou 2) : " choix

    # --- ÉTAPE 1 : Trouver l'ID du livre ---
    if [ "$choix" = "1" ]; then
        read -p "Donnez l'ID du livre : " livre_id
        # On vérifie si la ligne existe
        titre=$(grep "^$livre_id|" livres.txt | cut -d '|' -f2)
        
        if [ -z "$titre" ]; then
            echo "Erreur : Aucun livre trouvé avec cet ID."
            return
        fi

    elif [ "$choix" = "2" ]; then
        read -p "Donnez le titre du livre : " titre
        livre_id=$(obtenir_id_par_titre "$titre")

        if [ -z "$livre_id" ]; then
            echo "Erreur : Aucun livre trouvé avec ce titre."
            return
        fi
        # On récupère le vrai titre formaté depuis le fichier
        titre=$(grep "^$livre_id|" livres.txt | cut -d '|' -f2)
    else
        echo "Choix invalide."
        return
    fi

    # --- ÉTAPE 2 : Vérifier la disponibilité ---
    # On récupère la ligne complète pour analyser le dernier champ
    ligne_livre=$(grep "^$livre_id|" livres.txt)
    # On suppose que le statut est le 6ème champ (ajustez le $6 si votre fichier a plus/moins de colonnes)
    dispo=$(echo "$ligne_livre" | awk -F'|' '{print $6}') 
    
    # Nettoyage des espaces éventuels (trim)
    dispo=$(echo "$dispo" | xargs)

    if [ "$dispo" != "disponible" ]; then
        echo "⛔ Désolé, le livre « $titre » est déjà emprunté (Statut : $dispo)."
        return
    fi

    # --- ÉTAPE 3 : Effectuer l'emprunt ---
    read -p "Nom de l'emprunteur : " emprunteur
    date_emprunt=$(date +"%Y-%m-%d")

    
    echo "$livre_id|$emprunteur|$date_emprunt|2025-12-31" >> emprunts.txt

    
    sed -i "s/^$livre_id|\(.*\)|disponible$/$livre_id|\1|emprunte/" livres.txt

    echo "Le livre « $titre » a été emprunté avec succès."
}

retourner_livre() {
    local choix livre_id titre ligne emprunteur date_emprunt date_retour_reelle

    echo "Rechercher le livre à retourner par :"
    echo "1) ID"
    echo "2) Titre"
    read -p "Votre choix (1 ou 2) : " choix

    # --- ÉTAPE 1 : Identifier le livre et l'emprunt ---
    if [ "$choix" = "1" ]; then
        read -p "Donnez l'ID du livre : " livre_id
        
        # Vérifier s'il est dans la liste des emprunts
        ligne=$(grep "^$livre_id|" emprunts.txt)

        if [ -z "$ligne" ]; then
            echo "Erreur : Ce livre n'est pas marqué comme emprunté dans le fichier emprunts."
            return
        fi
        
        titre=$(grep "^$livre_id|" livres.txt | cut -d '|' -f2)

    elif [ "$choix" = "2" ]; then
        read -p "Donnez le titre du livre : " titre_input
        livre_id=$(grep -i "|$titre_input|" livres.txt | cut -d '|' -f1 | head -n 1)

        if [ -z "$livre_id" ]; then
            echo "Erreur : Livre introuvable."
            return
        fi

        ligne=$(grep "^$livre_id|" emprunts.txt)
        if [ -z "$ligne" ]; then
            echo "Ce livre n'est actuellement pas emprunté."
            return
        fi
        
        titre=$(grep "^$livre_id|" livres.txt | cut -d '|' -f2)

    else
        echo "Choix invalide."
        return
    fi

    # --- ÉTAPE 2 : Traiter le retour ---

    # Récupération des infos pour l'historique
    emprunteur=$(echo "$ligne" | cut -d '|' -f2)
    date_emprunt=$(echo "$ligne" | cut -d '|' -f3)
    date_retour_reelle=$(date +"%Y-%m-%d")

    # 1. Ajouter à l'historique
    echo "$livre_id|$emprunteur|$date_emprunt|$date_retour_reelle" >> historique.txt

    # 2. Retirer du fichier emprunts.txt (fichier temporaire pour éviter les bugs)
    grep -v "^$livre_id|" emprunts.txt > emprunts.tmp && mv emprunts.tmp emprunts.txt

    # 3. Remettre le livre comme "disponible" dans livres.txt
    # La regex cherche l'ID, capture le milieu, cherche 'emprunte' et remplace par 'disponible'
    sed -i "s/^$livre_id|\(.*\)|emprunte$/$livre_id|\1|disponible/" livres.txt

    echo "Le livre « $titre » a été retourné et est maintenant disponible."
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
            echo " Livre $id emprunté par $emp en retard depuis $date_retour"
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
SEPARATEUR="|"
SYMBOLE_IGNORER="#"


recherche_par_titre () {
local recherche
local trouve=0
read -r -p "Entrez le titre du livre : " recherche

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
local recherche
local trouve=0
read -r -p "Entrez le nom d'auteur du livre : " recherche
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
local recherche
local trouve=0
read -r -p "Entrez le genre du livre : " recherche
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
local debut
local fin
local trouve=0
read -r -p "Veuillez entrer l'année de début (AAAA) : " debut
read -r -p "Veuillez entrer l'année de fin (AAAA) : " fin

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

recherche_avancee() {
    echo -e "\n--- RECHERCHE AVANCÉE ---"
    echo "Laissez vide ou entrez '${SYMBOLE_IGNORER}' pour ignorer un critère."

    local titre auteur annee genre statut 

    read -r -p "Titre (contient) : " titre
    read -r -p "Auteur (contient) : " auteur
    read -r -p "Année (exacte ou ${SYMBOLE_IGNORER}) : " annee
    read -r -p "Genre (contient) : " genre
    read -r -p "Statut (disponible/emprunté ou ${SYMBOLE_IGNORER}) : " statut

    local resultats=$(<"$fichier")
    local nombre_criteres=0
    if [ ! -z "$titre" ] && [ "$titre" != "$SYMBOLE_IGNORER" ]; then
        resultats=$(echo "$resultats" | grep -i "${SEPARATEUR}${titre}")
        nombre_criteres=$((nombre_criteres + 1))
    fi
    if [ ! -z "$auteur" ] && [ "$auteur" != "$SYMBOLE_IGNORER" ]; then
        resultats=$(echo "$resultats" | grep -i "${SEPARATEUR}${auteur}${SEPARATEUR}")
        nombre_criteres=$((nombre_criteres + 1))
    fi

    if [ ! -z "$annee" ] && [ "$annee" != "$SYMBOLE_IGNORER" ]; then
        resultats=$(echo "$resultats" | grep -w "${SEPARATEUR}${annee}${SEPARATEUR}")
        nombre_criteres=$((nombre_criteres + 1))
    fi

    if [ ! -z "$genre" ] && [ "$genre" != "$SYMBOLE_IGNORER" ]; then
        resultats=$(echo "$resultats" | grep -i "${SEPARATEUR}${genre}${SEPARATEUR}")
        nombre_criteres=$((nombre_criteres + 1))
    fi
    
    if [ ! -z "$statut" ] && [ "$statut" != "$SYMBOLE_IGNORER" ]; then
        resultats=$(echo "$resultats" | grep -i "${SEPARATEUR}${statut}$")
        nombre_criteres=$((nombre_criteres + 1))
    fi

    echo -e "\n -- RESULTAT -----"

    if [ "$nombre_criteres" -eq 0 ]; then
        echo "[ERREUR] Aucun critere choisi."
    elif [ -z "$resultats" ]; then
        echo "Aucun livre trouvé ."
    else
        echo "$resultats" | column -t -s "${SEPARATEUR}"
    fi
}


#  STATISTIQUES ET RAPPORTS 
# =================================IMENE ================================

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


# 3.2 Répartition par genre 
stats_genre() {
    echo "--- Répartition des livres par genre ---"
    if [ ! -s "livres.txt" ]; then
        echo "Le fichier livres.txt est vide ou n'existe pas."
        return
    fi

    # 1. Compter les genres 
    local genres_counts=$(awk -F'|' '{print $5}' livres.txt | sort | uniq -c | awk '{$1=$1; print $0}' | sort -nr)
    
    if [ -z "$genres_counts" ]; then
        echo "Aucun genre trouvé."
        return
    fi

    
    local total_livres=$(echo "$genres_counts" | awk '{sum += $1} END {print sum}')

    local max_count=$(echo "$genres_counts" | head -n 1 | awk '{print $1}')
    local echelle_max=50 

    echo "Genres / Nombre de livres :"
    echo "$genres_counts" | while IFS= read -r line; do
        local count=$(echo "$line" | awk '{print $1}')
        local genre=$(echo "$line" | awk '{$1=""; print $0}' | xargs)
        
        # Calcul du pourcentage et de la longueur de la barre 
        local pourcentage=$(echo "scale=1; ($count / $total_livres) * 100" | bc)
        local longueur_barre=$(echo "scale=0; ($count * $echelle_max) / $max_count" | bc)
        
        # Afficher le genre, le compte et le graphique
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

    local top_list=$(awk -F'|' '$3 ~ /[^[:space:]]/ {print $3}' livres.txt | sort | uniq -c | sort -nr | head -n 5)
    
    # Itérer sur la variable stockée top_liste
    echo "$top_list" | while IFS= read -r line; do
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
    
    # Calcule la décennie et stocke le résultat dans une variable locale
    local decennies_counts=$(awk -F'|' '
        /^[0-9]*\|.*\|.*\|[0-9]{4}\|/ {
            decennie = int($4/10)*10; 
            print decennie
        }
    ' livres.txt | sort -n | uniq -c | sort -n)
    
    # Itérer sur la variable stockée decennies_counts
    echo "$decennies_counts" | while IFS= read -r line; do
        local count=$(echo "$line" | awk '{print $1}')
        local debut=$(echo "$line" | awk '{print $2}')
        local fin=$((debut + 9)) 
        printf "Années %s-%s : %s livres\n" "$debut" "$fin" "$count"
    done
}

export_html() {
    echo "--- Export des résultats en HTML ---"
    
    # 1. Définition du format et du fichier de sortie
    local format="html"
    
    # Demander le nom du rapport à l'utilisateur
    read -p "Nom du fichier de sortie (par défaut: rapport_bibliotheque) : " nom_fichier
    local fichier_sortie="${nom_fichier:-rapport_bibliotheque}.${format}"

    echo "Création du fichier HTML : $fichier_sortie"
    
    # 2. Début du fichier HTML 
    cat <<EOT > "$fichier_sortie"
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>Rapport Bibliothèque</title>
<style>
    body { font-family: sans-serif; }
    table {
        border-collapse: collapse;
        width: 100%;
        table-layout: fixed;
    }
    th, td {
        border: 1px solid #ddd;
        padding: 8px 10px;
        text-align: left;
        word-wrap: break-word;
    }
    th:nth-child(1), td:nth-child(1) { width: 5%; }
    th:nth-child(4), td:nth-child(4) { width: 8%; }
    th:nth-child(6), td:nth-child(6) { width: 12%; }
    th { background-color: #f2f2f2; }
</style>
</head>

<body>
<h1>Rapport de la Bibliothèque Personnelle</h1>
<h2>Liste des Livres</h2>

<table>
<tr>
    <th>ID</th>
    <th>Titre</th>
    <th>Auteur</th>
    <th>Année</th>
    <th>Genre</th>
    <th>Statut</th>
</tr>
EOT

    # 3. Ajout des données depuis livres.txt 
    if [ -s "livres.txt" ]; then


        awk -F'|' '
        NF==6 {
            for(i=1;i<=6;i++) {
                gsub(/^ +| +$/, "", $i)  # Retire espaces début/fin
            }
            print "<tr><td>" $1 "</td><td>" $2 "</td><td>" $3 "</td><td>" $4 "</td><td>" $5 "</td><td>" $6 "</td></tr>"
        }
        ' livres.txt >> "$fichier_sortie"

    else
        echo "<tr><td colspan='6'>Aucun livre enregistré.</td></tr>" >> "$fichier_sortie"
    fi

    cat <<EOT >> "$fichier_sortie"
</table>
</body>
</html>
EOT

    echo "Export HTML terminé. Fichier généré : $fichier_sortie"
}


# 5. SAUVEGARDE ET BACKUP 

# Crée une archive compressée du fichier livres.txt 
backup_manuel() {
    local backup_dir="backups"
    # Format de date pour l'horodatage 
    local date_format=$(date +%Y%m%d_%H%M%S)
    local archive_name="${backup_dir}/livres_backup_${date_format}.tar.gz"

    echo "--- Sauvegarde Manuelle ---"
    
    # Créer le répertoire de backups s'il n'existe pas
    if [ ! -d "$backup_dir" ]; then
        mkdir -p "$backup_dir"
        echo "Dossier de backups créé : ${backup_dir}"
    fi

    # Création de l'archive compressée 
    tar -czf "$archive_name" livres.txt 2>/dev/null
    
    if [ -f "$archive_name" ]; then
        echo "Sauvegarde créée : ${archive_name}"
    else
        echo "Échec de la création de la sauvegarde."
    fi
}

# Liste toutes les sauvegardes existantes
afficher_backups() {
    local backup_dir="backups"
    echo "--- Liste des Backups ---"
    
    if [ ! -d "$backup_dir" ] || [ -z "$(ls -A $backup_dir 2>/dev/null)" ]; then
        echo "Aucune sauvegarde trouvée."
    else
        echo "Fichiers de sauvegarde dans '${backup_dir}':"
        ls -lth "$backup_dir" | grep -E 'livres_backup_|total'
    fi
}
