#!/bin/bash
### This script should work to transform our .tex file into a html webpage 
### run it in the same folder where the .tex file is. 
### open problems are how to do alt text (worst case would be writing a table and adding a loop at the end to insert it)
### also no proofreading has been done, so there might be format messes to figure out still.
file="SusHep.html"
cd Sections
### convert all images 
## only needs to run once so comment out after 
find ./Figs -type f -name "*.pdf" |while read line
do  
   dir=${line%/*}
   file=${line##*/}
   file=${file%.*}
   convert -transparent white $line ${file}.png
   #echo mv ${file}.png ${dir}/${file}.png
   mv ${file}.png ${dir}/${file}.png
done
### change the image filenames
for f in *.tex
do
    echo $f
    sed -i "s/\.pdf}/\.png}/g" "$f"
done


cd ../
pwd
### 
pandoc -s SustainableHEP.tex -o temp.html -t html5 --mathjax --metadata title="Striving towards Environmental Sustainability in HECAP" --standalone #--embed-resources

### get the image paths correct
for part in "Intro" "Computing" "Energy" "Common" "Food" "Technology" "Travel" "Waste"
do
    echo $part
    sed -i "s/${part}\//Sections\/Figs\/${part}\//" temp.html
done

### fixing the fix
sed -i "s/Sections\/Figs\/Sections\/Figs\//Sections\/Figs\//" temp.html

### get the alt text from file 
### currently this fails bc the file contains all plots and is not correctly formatted
sed -e 's/^/s|/; s/$/|g/' replacelist.txt | sed -i -f - temp.html

### fix the SDG goals
sed -e 's/^/s|/; s/$/|g/' goals_replace.txt | sed -i -f - temp.html

# ### convoluted way to add the commands to get the right font in
head -12 temp.html >$file
echo "@import url("https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible:wght@400\;700\&display=swap");">>$file
echo "body {" >> $file
echo "font-family: "Atkinson Hyperlegible", sans-serif;"  >>$file
tail +14 temp.html >>$file 
rm temp.html