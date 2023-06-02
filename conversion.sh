#!/bin/bash
### This script should work to transform our .tex file into a html webpage 
### run it in the same folder where the .tex file is. 
### a lot of things are done via sed in pre and post processing steps
### only problem to do by hand are the recommendation boxes.
### search for mdframed environments and then insert the line 
###   <p><h3>Recommendations - Impelling Positive Change </h3></p> 
### with the suitable headline added

file="SustHecap.html"
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
### and change center environment for figures to get numbering
for f in *.tex
do
    echo $f
    sed -i "s/\.pdf}/\.png}/g" "$f"
    sed -i "s/{center}/{figure}/g" "$f"
    sed -i "s/\subfloat/ /g" "$f"
done

### images in casestudies are partly put into center environment (section 6, technology in particular) this needs to be fixed by hand, otherwise the images are not converted with captions etc.

cd ../
pwd
### 
### --filter=pandoc-crossref does give figure numbers, at least for figures that are in figure environments
pandoc -s SustainableHEP.tex   --filter=pandoc-crossref --number-sections  --bibliography=SustainableHEP.bib --citeproc --csl ieee.csl --metadata title="Environmental sustainability in basic research" --standalone --listings --toc --toc-depth 2 -o temp.html -t html5 --mathjax  #--embed-resources

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

### makes the case studies and the recommendations pretty
sed -i "s/blockquote {/.marginline { \n margin: 1em 0 1em 1.7em;\n    padding-left: 1em;\n   border-left: 4px solid green;\n   }\n    .mdframed{\n     border-width:4px; border-style:solid; border-color:green; padding: 1em; \n } \n blockquote {\n/" $file

### adding section titles for references and footnotes 

sed -i 's|class="references csl-bib-body" role="list">|class="references csl-bib-body" role="list"><h1 class="unnumbered" id="sec:Bibliography">References</h1>|' $file

sed -i 's|role="doc-endnotes">|role="doc-endnotes"> <h1 class="unnumbered" id="footnotes">Footnotes</h1>|' $file

sed -i 's|<p><strong>Environmental sustainability in basic research</strong><br />| |' $file

sed -i 's|An HTML version of this document|The original PDF version of this document|' $file

sed -i 's|This document has been typeset in LaTeX using Atkinson Hyperlegible|This document has been converted from LaTeX using Pandoc. The font used is Atkinson Hyperlegible|' $file

### ugly but it works
sed -i "s|</style>|  .sidebar { \n    margin: 0;\n    margin-top: -50px;\n   margin-left:-400px;\n  padding: 0px; \n  width: 300px;\n  background-color: #f1f1f1;\n  position: fixed;\n  height: 100%;\n  overflow: auto;\n}\n\n/* Sidebar links */\n.sidebar a {\n  display: block;\n  color: black;\n  padding: 16px;\n  text-decoration: none;\n}\n\n/* Active/current link */\n .sidebar a.active {\n  background-color: #04AA6D;\n  color: white;\n}\n\n/* Links on mouse-over */\n .sidebar a:hover:not(.active) {\n  background-color: #555;\n  color: white;\n}\n</style>|" $file

sed -i 's|<header id="title-block-header">| |' $file
sed -i 's|<h1 class="title">Environmental sustainability in basic research</h1>| |' $file
sed -i 's|</header>|<div class="sidebar">|' $file 

sed -i 's|<div class="titlepage">|</div>\n<header id="title-block-header">\n<h1 class="title">Environmental sustainability in basic research</h1>\n</header>\n<div class="titlepage">|' $file


### adding bibliography and footnotes into the toc

sed -i 's|<li><a href="#endorsers" id="toc-endorsers">Endorsers</a></li>|<li><a href="#endorsers" id="toc-endorsers">Endorsers</a></li> \n <li><a href="#refs" id="toc-references">Bibliography</a></li>\n <li><a href="#footnotes" id="toc-endorsers">Footnotes</a></li>\n|' $file

# ### make our best practices pretty

rm temp.html
