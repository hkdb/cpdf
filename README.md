# cpdf v1.0
**maintained by:** hkdb \<<hkdb@3df.io>\><br />

## Description

A Python script that simplifies compressing pdf files with gs.

## Change Log
MAY 11th, 2018 - v1.0 Released

## Usage Example

Check file size of test.pdf:

```
hkdb@machine:~/test$ ll
total 31M
drwxrwxr-x  2 hkdb hkdb 4.0K May  1 14:59 .
drwxr-xr-x 94 hkdb hkdb 4.0K Apr 30 21:45 ..
-rw-rw-r--  1 hkdb hkdb  31M Apr 29 23:32 test.pdf
```

Help:

```
hkdb@machine:~/test$ cpdf help
This is a script to compress a pdf file with the convention of: cpdf [type: screen, ebook, printer, prepress, or default] [input file name] [output file name] . To learn more about the different types, use the "types" flag (ie. cpdf types)
```

List the preset types of compression settings:

```
hkdb@machine:~/test$ cpdf types
screen - selects low-resolution output similar to the Acrobat Distiller "Screen Optimized" setting.
ebook - selects medium-resolution output similar to the Acrobat Distiller "eBook" setting.
printer - selects output similar to the Acrobat Distiller "Print Optimized" setting.
prepress - selects output similar to Acrobat Distiller "Prepress Optimized" setting.
default - selects output intended to be useful across a wide variety of uses, possibly at the expense of a larger output file.
```

Compress:

```
hkdb@machine:~/test$ cpdf ebook test.pdf compressed.pdf
hkdb@machine:~/test$ ll
total 35M
drwxrwxr-x  2 hkdb hkdb 4.0K May  1 15:00 .
drwxr-xr-x 94 hkdb hkdb 4.0K Apr 30 21:45 ..
-rw-rw-r--  1 hkdb hkdb 4.0M May  1 15:02 compressed.pdf
-rw-rw-r--  1 hkdb hkdb  31M Apr 29 23:32 test.pdf
hkdb@machine:~/test$
```
Notice that compressed.pdf is 4M; the results from compressing a 31M pdf? I then opened up compressed.pdf and it still looked great!

## Installation

To make this script behave more like a command, move it to a bin directory of choice that's defined in your env.

This way, you can be in any directory and run this script to compress any pdf file without specifying the full path.

## Recognition

Many thanks to Dr. Haggen So for sharing the following link that inspired me to write this script:

https://www.tjansson.dk/2012/04/compressing-pdfs-using-ghostscript-under-linux/
