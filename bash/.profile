export PS1="Speak 'Friend' and Enter: "
home="/Users/patrickheenan/utilities/bash/"
# where the profile is 
base="$home"
profile=".profile"
identikey="pahe3165"
# supposedly makes it infinite
export HISTSIZE="GOTCHA"

GOOD_RET=0
BAS_RET=1

alias python='python2.7'
# use very strict compilationg for c/c++
flags="-Wall -Wpedantic -Wextra"
alias gcc='gcc ${flags}'
alias g++='g++ ${flags}'

ARCHFLAGS="-arch x86_64" # Ensure user-installed binaries take precedence expor 
PATH=/usr/local/bin:/usr/local/mysql/bin/:$PATH # Load .bashrc/mysql if it exists
utilDir="/Users/patrickheenan/utilities/"

bootcamp()
{
    cd /Users/patrickheenan/Documents/education/boulder_files/administrative/bootcamp_2015/code/IqBioBootcamp2015/
}

extra()
{
    cd /Users/patrickheenan/Documents/education/boulder_files/3_summer_2014/prep_physics
}

latexsty()
{
    cd /Users/patrickheenan/Library/texmf/tex/latex
}

fun()
{
    cd ~/Documents/fun/code/
}

pyNb()
{
    ipython notebook $@

}

pInit()
{
    hg init .
    cp "${utilDir}hg/.hgignore" ./.hgignore
}

viz()
{
    edu
    cd csci_7000_sci_viz/assignments/
}

protein()
{
    edu
    cd ..
    cd 1_fall_2014/csci_5415_mol_bio_alg/group_csci_5314/repo/csci5314_2014_conformation
}

mach()
{
    edu
    cd csci_5622_machine_learning/hw/ml-hw
}

matnu()
{
    cp "${utilDir}mathematica/config.nb" ./$1.nb
}

pynu()
{
    # copy the configuration files with the appropriate imports
    cp "${utilDir}python/config.py" ./$1.py
}

igornu()
{
    cp "${utilDir}igor/_config.ipf" ./$1.ipf
}

bashnu()
{
    cp "${utilDir}bash/config.sh" $1.sh
}

mkcd()
{
    mkdir $1
    cd $1
}

emnu()
{
    cp "${utilDir}/latex/template.tex" ./${1}.tex
}

edu()
{
    cd /Users/patrickheenan/Documents/education/boulder_files/4_fall_2015
}

euler()
{
    cd /Users/patrickheenan/Documents/qtWorkspace/algStudying/projectEuler/
}


gui()
{
   open -a Finder .
}

res()
{
    cd ~/Documents/education/boulder_files/rotations_year_1/3_perkins/
}

p.()
{
    open -a Preview $@.pdf
}

pcomp()
{
    set -x
    pandoc -V geometry:margin=1in  $1.md -o $1.pdf
}

pdfl()
{
    ERROR="Too few arguments : no file name specified"
    [[ $# -eq 0 ]] && echo $ERROR && return # no args? ... print error and exit

    # check that the file exists
    if [ -f $1.tex ] 
    then
	# if it exists then latex it twice, dvips, then ps2pdf, then remove all the unneeded files
	pdflatex $1.tex
	bibtex $1.aux
	pdflatex $1.tex
	pdflatex $1.tex
	dvips $1.dvi -o $1.ps
	pstopdf $1.ps

	# these lines can be appended to delete other files, such as *.out
	rm *.blg
	rm *-blx.bib
	rm *.bbl
	rm *.run.xml
	rm *.aux
	rm *.log
	rm *.ps
	rm *.dvi
	rm *.toc
	rm *.lof
    else
	# otherwise give this output line with a list of available tex files
	echo 'the file doesnt exist butthead! Choose one of these:'
	ls *.tex
    fi

}



# Vieques address
#vieques=${identikey}@vieques.colorado.edu
clusterAddr=${identikey}@login.rc.colorado.edu
clusterHome="Users/pahe3165"

# XXX remove, for debugging below
# copying the code to the cluster (poor man's clone, wont copy files...)


getData()
{
    mat
    outputDir="computeOutput"
    rm -rf ${outputDir}
    mkdir ${outputDir}
    scp -r "${clusterAddr}:/${clusterHome}/logs/" ${outputDir}
    scp -r "${clusterAddr}:/${clusterBase}/output*" ${outputDir}
}

cPush()
{
    # essentially, a 'backwards' way to clone, using m localhost as 'remote'
    # must do 'hg clone repo ssh://xxxx' first: 
    #see:  http://stackoverflow.com/questions/2963040/how-to-clone-repository-to-a-remote-server-repository-with-mercurial
    hg push ssh://$clusterAddr/${clusterRepoRelative}
}

jila()
{
    server="jilau1.colorado.edu"
    addr=${identikey}@${server}
    ssh $@ ${addr}
}

compute()
{
    # ssh with the options...
    ssh $@ ${clusterAddr}
}

ref()
{
    source $base/$profile
}

ed()
{
    open -a emacs $@;
}

nu()
{
	ed $base/$profile	
	ref
}

# added by Anaconda3 2.1.0 installer
export PATH="//anaconda/bin:$PATH"

# added by Anaconda 2.1.0 installer
export PATH="//anaconda/bin:$PATH"
