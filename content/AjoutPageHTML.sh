#!bin/bash

okegreen='\033[92m'
RESET="\033[00m" #normal

touch final.html
cat do/header.txt > final.html

echo $okegreen " "
echo "Titre de l'article :"
echo $RESET " "
read title
echo $title >> final.html
cat do/header2.txt >> final.html



echo $okegreen " "
echo "Description de l'article :"
echo $RESET " "
read desc
echo $desc >> final.html
cat do/body1.txt >> final.html


echo $okegreen " "
echo "Nombre de paragraphes :"
echo $RESET " "
read number

n=0
a=1
while [ $n = 0 ]
do 
    echo $okegreen " "
    echo "Titre du paragraphe n°" $a
    echo $RESET " "
    read ptitle
    cat do/para1.txt >> final.html
    echo $ptitle >> final.html
    cat do/para2.txt >> final.html
    
    echo $okegreen " "
    echo "Contenu du paragraphe N°" $a
    echo $RESET " "
    read content
    echo $content >> final.html
    echo "</div>" >> final.html

    $a = $(($a + 1))

    echo $okegreen " "
    echo "Ajouter un autre paragraphe ? [O/N]"
    echo $RESET " "
    read ok
    if [ $ok = "O" ]
    then
        $n=0
    fi
    if [ $ok = "N" ]
    then
        $n=1
        echo "</div>" >> final.html
        cat do/footer.txt >> final.html

        echo $okegreen " "
        echo "Fin de la géneration de page html !"
        echo $RESET " "

        exit 1
    fi
    
done