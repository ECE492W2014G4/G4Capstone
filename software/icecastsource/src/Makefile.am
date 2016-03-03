## Process this file with automake to create Makefile.in

AUTOMAKE_OPTIONS = foreign

noinst_PROGRAMS = example

example_SOURCES = example.c
example_LDADD = $(top_builddir)/libshout-2.4.1/src/libshout.la -L/usr/local/lib -lvorbis -lssl -lcrypto

AM_CFLAGS = -Wall -ffast-math -fsigned-char -pthread  -I/usr/local/include 
AM_CPPFLAGS = -I$(top_builddir)/libshout-2.4.1/include
