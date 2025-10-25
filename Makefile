# ------------------------------------------------------------------
# This file is part of bzip2/libbzip2, a program and library for
# lossless, block-sorting data compression.
#
# bzip2/libbzip2 version 1.0.8 of 13 July 2019
# Copyright (C) 1996-2019 Julian Seward <jseward@acm.org>
#
# Please read the WARNING, DISCLAIMER and PATENTS sections in the 
# README file.
#
# This program is released under the terms of the license contained
# in the file LICENSE.
# ------------------------------------------------------------------

SHELL=/bin/sh

# To assist in cross-compiling
CC ?= gcc
AR ?= ar
RANLIB ?= ranlib
LDFLAGS ?=

BIGFILES = -D_FILE_OFFSET_BITS=64
CFLAGS = -Wall -Winline -O2 -g $(BIGFILES)

PREFIX ?= /usr/local
prefix ?= ${PREFIX}

srcdir ?= .

OBJS= blocksort.o  \
      huffman.o    \
      crctable.o   \
      randtable.o  \
      compress.o   \
      decompress.o \
      bzlib.o

all: libbz2.a bzip2 bzip2recover test

include configure.mk

bzip2: libbz2.a bzip2.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o bzip2 bzip2.o -L. -lbz2

bzip2recover: bzip2recover.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o bzip2recover bzip2recover.o

libbz2.a: $(OBJS)
	rm -f libbz2.a
	$(AR) cq libbz2.a $(OBJS)
	@if ( test -f $(RANLIB) -o -f /usr/bin/ranlib -o \
		-f /bin/ranlib -o -f /usr/ccs/bin/ranlib ) ; then \
		echo $(RANLIB) libbz2.a ; \
		$(RANLIB) libbz2.a ; \
	fi

check: test
test: bzip2
	@cat words1
	./bzip2 -1  < sample1.ref > sample1.rb2
	./bzip2 -2  < sample2.ref > sample2.rb2
	./bzip2 -3  < sample3.ref > sample3.rb2
	./bzip2 -d  < sample1.bz2 > sample1.tst
	./bzip2 -d  < sample2.bz2 > sample2.tst
	./bzip2 -ds < sample3.bz2 > sample3.tst
	cmp sample1.bz2 sample1.rb2 
	cmp sample2.bz2 sample2.rb2
	cmp sample3.bz2 sample3.rb2
	cmp sample1.tst sample1.ref
	cmp sample2.tst sample2.ref
	cmp sample3.tst sample3.ref
	@cat words3

install: bzip2 bzip2recover
	if ( test ! -d ${DESTDIR}${prefix}/bin ) ; then mkdir -p ${DESTDIR}${prefix}/bin ; fi
	if ( test ! -d ${DESTDIR}${prefix}/lib ) ; then mkdir -p ${DESTDIR}${prefix}/lib ; fi
	if ( test ! -d ${DESTDIR}${prefix}/man ) ; then mkdir -p ${DESTDIR}${prefix}/man ; fi
	if ( test ! -d ${DESTDIR}${prefix}/man/man1 ) ; then mkdir -p ${DESTDIR}${prefix}/man/man1 ; fi
	if ( test ! -d ${DESTDIR}${prefix}/include ) ; then mkdir -p ${DESTDIR}${prefix}/include ; fi
	cp -f bzip2 ${DESTDIR}${prefix}/bin/bzip2
	cp -f bzip2 ${DESTDIR}${prefix}/bin/bunzip2
	cp -f bzip2 ${DESTDIR}${prefix}/bin/bzcat
	cp -f bzip2recover ${DESTDIR}${prefix}/bin/bzip2recover
	chmod a+x ${DESTDIR}${prefix}/bin/bzip2
	chmod a+x ${DESTDIR}${prefix}/bin/bunzip2
	chmod a+x ${DESTDIR}${prefix}/bin/bzcat
	chmod a+x ${DESTDIR}${prefix}/bin/bzip2recover
	cp -f bzip2.1 ${DESTDIR}${prefix}/man/man1
	chmod a+r ${DESTDIR}${prefix}/man/man1/bzip2.1
	cp -f bzlib.h ${DESTDIR}${prefix}/include
	chmod a+r ${DESTDIR}${prefix}/include/bzlib.h
	cp -f libbz2.a ${DESTDIR}${prefix}/lib
	chmod a+r ${DESTDIR}${prefix}/lib/libbz2.a
	cp -f bzgrep ${DESTDIR}${prefix}/bin/bzgrep
	ln -s -f ${DESTDIR}${prefix}/bin/bzgrep ${DESTDIR}${prefix}/bin/bzegrep
	ln -s -f ${DESTDIR}${prefix}/bin/bzgrep ${DESTDIR}${prefix}/bin/bzfgrep
	chmod a+x ${DESTDIR}${prefix}/bin/bzgrep
	cp -f bzmore ${DESTDIR}${prefix}/bin/bzmore
	ln -s -f ${DESTDIR}${prefix}/bin/bzmore ${DESTDIR}${prefix}/bin/bzless
	chmod a+x ${DESTDIR}${prefix}/bin/bzmore
	cp -f bzdiff ${DESTDIR}${prefix}/bin/bzdiff
	ln -s -f ${DESTDIR}${prefix}/bin/bzdiff ${DESTDIR}${prefix}/bin/bzcmp
	chmod a+x ${DESTDIR}${prefix}/bin/bzdiff
	cp -f bzgrep.1 bzmore.1 bzdiff.1 ${DESTDIR}${prefix}/man/man1
	chmod a+r ${DESTDIR}${prefix}/man/man1/bzgrep.1
	chmod a+r ${DESTDIR}${prefix}/man/man1/bzmore.1
	chmod a+r ${DESTDIR}${prefix}/man/man1/bzdiff.1
	echo ".so man1/bzgrep.1" > ${DESTDIR}${prefix}/man/man1/bzegrep.1
	echo ".so man1/bzgrep.1" > ${DESTDIR}${prefix}/man/man1/bzfgrep.1
	echo ".so man1/bzmore.1" > ${DESTDIR}${prefix}/man/man1/bzless.1
	echo ".so man1/bzdiff.1" > ${DESTDIR}${prefix}/man/man1/bzcmp.1

clean: 
	rm -f *.o libbz2.a bzip2 bzip2recover \
	sample1.rb2 sample2.rb2 sample3.rb2 \
	sample1.tst sample2.tst sample3.tst

blocksort.o: ${srcdir}/blocksort.c
	@cat words0
	$(CC) $(CFLAGS) -c ${srcdir}/blocksort.c
huffman.o: ${srcdir}/huffman.c
	$(CC) $(CFLAGS) -c ${srcdir}/huffman.c
crctable.o: ${srcdir}/crctable.c
	$(CC) $(CFLAGS) -c ${srcdir}/crctable.c
randtable.o: ${srcdir}/randtable.c
	$(CC) $(CFLAGS) -c ${srcdir}/randtable.c
compress.o: ${srcdir}/compress.c
	$(CC) $(CFLAGS) -c ${srcdir}/compress.c
decompress.o: ${srcdir}/decompress.c
	$(CC) $(CFLAGS) -c ${srcdir}/decompress.c
bzlib.o: ${srcdir}/bzlib.c
	$(CC) $(CFLAGS) -c ${srcdir}/bzlib.c
bzip2.o: ${srcdir}/bzip2.c
	$(CC) $(CFLAGS) -c ${srcdir}/bzip2.c
bzip2recover.o: ${srcdir}/bzip2recover.c
	$(CC) $(CFLAGS) -c ${srcdir}/bzip2recover.c


distclean: clean
	rm -f manual.ps manual.html manual.pdf bzip2.txt bzip2.1.preformatted

DISTNAME = bzip2-1.0.8
dist: check manual
	rm -f $(DISTNAME)
	ln -s -f . $(DISTNAME)
	tar cvf $(DISTNAME).tar \
	   $(DISTNAME)/blocksort.c \
	   $(DISTNAME)/huffman.c \
	   $(DISTNAME)/crctable.c \
	   $(DISTNAME)/randtable.c \
	   $(DISTNAME)/compress.c \
	   $(DISTNAME)/decompress.c \
	   $(DISTNAME)/bzlib.c \
	   $(DISTNAME)/bzip2.c \
	   $(DISTNAME)/bzip2recover.c \
	   $(DISTNAME)/bzlib.h \
	   $(DISTNAME)/bzlib_private.h \
	   $(DISTNAME)/Makefile \
	   $(DISTNAME)/LICENSE \
	   $(DISTNAME)/bzip2.1 \
	   $(DISTNAME)/bzip2.1.preformatted \
	   $(DISTNAME)/bzip2.txt \
	   $(DISTNAME)/words0 \
	   $(DISTNAME)/words1 \
	   $(DISTNAME)/words2 \
	   $(DISTNAME)/words3 \
	   $(DISTNAME)/sample1.ref \
	   $(DISTNAME)/sample2.ref \
	   $(DISTNAME)/sample3.ref \
	   $(DISTNAME)/sample1.bz2 \
	   $(DISTNAME)/sample2.bz2 \
	   $(DISTNAME)/sample3.bz2 \
	   $(DISTNAME)/dlltest.c \
	   $(DISTNAME)/manual.html \
	   $(DISTNAME)/manual.pdf \
	   $(DISTNAME)/manual.ps \
	   $(DISTNAME)/README \
	   $(DISTNAME)/README.COMPILATION.PROBLEMS \
	   $(DISTNAME)/README.XML.STUFF \
	   $(DISTNAME)/CHANGES \
	   $(DISTNAME)/libbz2.def \
	   $(DISTNAME)/libbz2.dsp \
	   $(DISTNAME)/dlltest.dsp \
	   $(DISTNAME)/makefile.msc \
	   $(DISTNAME)/unzcrash.c \
	   $(DISTNAME)/spewG.c \
	   $(DISTNAME)/mk251.c \
	   $(DISTNAME)/bzdiff \
	   $(DISTNAME)/bzdiff.1 \
	   $(DISTNAME)/bzmore \
	   $(DISTNAME)/bzmore.1 \
	   $(DISTNAME)/bzgrep \
	   $(DISTNAME)/bzgrep.1 \
	   $(DISTNAME)/Makefile-libbz2_so \
	   $(DISTNAME)/bz-common.xsl \
	   $(DISTNAME)/bz-fo.xsl \
	   $(DISTNAME)/bz-html.xsl \
	   $(DISTNAME)/bzip.css \
	   $(DISTNAME)/entities.xml \
	   $(DISTNAME)/manual.xml \
	   $(DISTNAME)/format.pl \
	   $(DISTNAME)/xmlproc.sh
	gzip -v $(DISTNAME).tar

# For rebuilding the manual from sources on my SuSE 9.1 box

MANUAL_SRCS= 	bz-common.xsl bz-fo.xsl bz-html.xsl bzip.css \
		entities.xml manual.xml 

bzip2.txt: bzip2.1
	MANWIDTH=67 man --ascii ./$^ > $@

bzip2.1.preformatted: bzip2.1
	MAN_KEEP_FORMATTING=1 MANWIDTH=67 man -E UTF-8 ./$^ > $@

manual: manual.html manual.ps manual.pdf bzip2.txt bzip2.1.preformatted

manual.ps: $(MANUAL_SRCS)
	./xmlproc.sh -ps manual.xml

manual.pdf: $(MANUAL_SRCS)
	./xmlproc.sh -pdf manual.xml

manual.html: $(MANUAL_SRCS)
	./xmlproc.sh -html manual.xml
