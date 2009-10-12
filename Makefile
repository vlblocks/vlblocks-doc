# file: Makefile
# author: Brian Fulkerson
# description: Makefile to build the documentation

.PHONY : all

.PHONY: doc, docsrc/toolbox

all: doc-toolbox doc-web

VER=0.1
BLOCKS=~/research/blocks
VLFEAT=~/vltest
MDOC=$(VLFEAT)/docsrc/mdoc.py
WEBDOC=$(VLFEAT)/docsrc/webdoc.py

html_src := $(wildcard docsrc/*.html)

doc-toolbox: docsrc/toolbox/mdoc.html


VERSION:
	echo "$(VER)" > VERSION

docsrc/version.html: Makefile
	echo "<code>$(VER)</code>" > docsrc/version.html


doc-web: doc/index.html

doc/index.html: \
	docsrc/web.xml \
	docsrc/web.css \
	docsrc/toolbox/mdoc.html \
	docsrc/version.html \
	$(html_src) $(WEBDOC) 
	$(PYTHON) $(WEBDOC) --outdir=doc \
	     docsrc/web.xml --verbose
	rsync -arv docsrc/images doc
	rsync -arv docsrc/js doc
	rsync -arv docsrc/web.css doc
	rsync -arv docsrc/robots.txt doc
	rsync -arv docsrc/favicon.ico doc

#
# Use mdoc.py to create the toolbox documentation that will be
# embedded in the website.
#

docsrc/toolbox/mdoc.html : $(m_src) $(MDOC)
	$(PYTHON) $(MDOC) $(BLOCKS) docsrc/toolbox \
	          --format=web \
	          --exclude='.*experiments.*' \
	          --verbose

doc-distclean:
	rm -rf docsrc/toolbox
	rm -rf doc

post-web: doc-web
	rsync -aP doc/ vision.ucla.edu:/var/www/vlblocks.org/ \
				--exclude='downloads' \
				--delete

post-doc: doc-web
	rsync -aP --delete doc $(BLOCKS)

