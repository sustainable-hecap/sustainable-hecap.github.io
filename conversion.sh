#!/bin/bash
### This script should work to transform our .tex file into a html webpage 
### run it in the same folder where the .tex file is. 
### open problems are how to do alt text (worst case would be writing a table and adding a loop at the end to insert it)
### also no proofreading has been done, so there might be format messes to figure out still.
file="SustHecap.html"
cd Sections
### convert all images 
## only needs to run once so comment out after 
# find ./Figs -type f -name "*.pdf" |while read line
# do  
#    dir=${line%/*}
#    file=${line##*/}
#    file=${file%.*}
#    convert -transparent white $line ${file}.png
#    #echo mv ${file}.png ${dir}/${file}.png
#    mv ${file}.png ${dir}/${file}.png
# done
### change the image filenames
for f in *.tex
do
    echo $f
    sed -i "s/\.pdf}/\.png}/g" "$f"
done

### images in casestudies are partly put into center environment (section 6, technology in particular) this needs to be fixed by hand, otherwise the images are not converted with captions etc.

cd ../
pwd
### 
pandoc -s SustainableHEP.tex -o temp.html -t html5 --mathjax --metadata title="Environmental sustainability in basic research" --standalone #--embed-resources

### get the image paths correct
for part in "Intro" "Computing" "Energy" "Common" "Food" "Technology" "Travel" "Waste"
do
    echo $part
    sed -i "s/${part}\//Sections\/Figs\/${part}\//" temp.html
done
### fixing the fix
sed -i "s/Sections\/Figs\/Sections\/Figs\//Sections\/Figs\//" temp.html
### try to remove bad alt text
sed -i 's/alt="image"//g' temp.html
### pandoc creates some linebreaks that mess with me, I can remove them like this 
sed -i ':a;N;$!ba;s/\nstyle/ style/g' temp.html

### get the alt text from file 
### currently this fails bc the file contains all plots and is not correctly formatted
sed -e 's/^/s|/; s/$/|g/' replacelist_edited.txt | sed -i -f - temp.html

### fix the SDG goals
sed -e 's/^/s|/; s/$/|g/' goals_replace.txt | sed -i -f - temp.html

# ### convoluted way to add the commands to get the right font in
head -12 temp.html >$file
echo "@import url("https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible:wght@400\;700\&display=swap");">>$file
echo "body {" >> $file
echo "font-family: "Atkinson Hyperlegible", sans-serif;"  >>$file
tail +14 temp.html >>$file 

### makes the case studies pretty
sed -i "s/blockquote {/.marginline { \n margin: 1em 0 1em 1.7em;\n    padding-left: 1em;\n   border-left: 4px solid green;\n   }\n blockquote {\n/" $file

# ### make our best practices pretty

rm temp.html
