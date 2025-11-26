#!/bin/bash
source lib_functions.sh

while true; do
    clear
    echo "==========================================="
    echo "     SYSTÈME DE GESTION DE BIBLIOTHÈQUE     "
    echo "==========================================="
    echo "1. Gestion des livres"
    echo "2. Recherche et filtres"
    echo "3. Statistiques et rapports"
    echo "4. Emprunts"
    echo "5. Sauvegarde et Backup"
    echo "0. Quitter"
    echo "-------------------------------------------"
    read -p "Votre choix : " choix

    case "$choix" in

        1)
            clear
            echo "---- Gestion des livres ----"
            echo "1. Ajouter un livre"
            echo "2. Modifier un livre"
            echo "3. Supprimer un livre"
            echo "4. Lister les livres"
            echo "0. Retour"
            read -p "Choix : " c1

            case "$c1" in
                1) ajoute_livre ;;
                2) modifier_livre ;;
                3) supprime_livre ;;
                4) lister_livres ;;
            esac
        ;;

        2)
            clear
            echo "---- Recherche ----"
            echo "1. Rechercher par titre"
            echo "2. Rechercher par auteur"
            echo "3. Filtrer par genre"
            echo "4. Filtrer par année"
            echo "5. Recherche avancée"
            echo "0. Retour"
            read -p "Choix : " c2

            case "$c2" in
                1) recherche_par_titre ;;
                2) recherche_par_auteur ;;
                3) filtrer_par_genre ;;
                4) filtrer_par_annee ;;
                5) recherche_avancee ;;
            esac
        ;;

        
       3)
        
            clear
            echo "---- Statistiques ----"
            echo "1. Nombre total de livres"
            echo "2. Répartition par genre (ASCII)"
            echo "3. Top 5 auteurs"
            echo "4. Livres par décennie"
            echo "5. Export en HTM"
            echo "0. Retour"
            read -p "Choix : " c3

            case "$c3" in
                1) stats_total ;;       
                2) stats_genre ;;       
                3) top_auteurs ;;       
                4) stats_decennies ;;   
                5) export_html ;;   
            esac
            ;;

        4)
            clear
            echo "---- Gestion des emprunts ----"
            echo "1. Emprunter un livre"
            echo "2. Retourner un livre"
            echo "3. Liste des emprunts"
            echo "4. Retards"
            echo "5. Historique des emprunts"
            echo "0. Retour"
            read -p "Choix : " c4

            case "$c4" in
                1) emprunter_livre ;;   
                2) retourner_livre ;;  
                3) lister_emprunts ;;
                4) alerte_retards ;;
                5) historique_emprunts ;;
            esac
        ;;

        5)
            clear
            echo "---- Sauvegarde & Backup ----"
            echo "1. Sauvegarde manuelle"
            echo "2. Voir les backups"
            echo "0. Retour"
            read -p "Choix : " c5

            case "$c5" in
                1) backup_manuel ;;
                2) afficher_backups ;;
            esac
        ;;

        0)
            echo "Au revoir !"
            exit 0
        ;;

        *)
            echo "Choix invalide"
            sleep 1
        ;;
    esac

    read -p "Appuyez sur Entrée pour continuer..."
done

#le script principal

source ./lib_functions.sh

modifier_livre
