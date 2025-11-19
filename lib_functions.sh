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
