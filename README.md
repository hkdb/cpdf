# cPDF
**maintained by:** hkdb \<<hkdb@3df.io>\><br />

## Description

A Python script that simplifies compressing pdf files with gs.

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

You can also specify input and output files with full path:

```
hkdb@machine:~/test$ cpdf ebook /home/hkdb/test.pdf /home/hkdb/Downloads/test-compressed.pdf
```

Version Checker:

```
hkdb@machine:~/test$ cpdf version

cPDF v1.3

hkdb@machine:~/test$
```

As of v1.1, color coding certain output text has been added to improve readability:

![colorcode](https://osi.3df.io/wp-content/uploads/2018/05/coloroutput.png "Color Coding")

## Under the Hood

It essentially takes your arguments and turns it into the following Ghostscript command:

```
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.6 -dPDFSETTINGS=/ebook
-dNOPAUSE -dQUIET -dBATCH -sOutputFile=[compressed.pdf]
"[input.pdf]"
```
## Error Handling

Currently, if any of the below conditions are met, the script will print an error/warning message and exit. This is designed to prevent any dangerous execution of Ghostscript and to remind users in case they forget to input the command with the right convention. For the ones that are questionable, it will warn the user and provide a chance to cancel or confirm.

Convention:

- Less than 3 arguments given
- Invalid compression type argument

Ghostscript:

- Input File Does Not End with .pdf
- Input File and Output File are the same
- Input File Name Contains Unsupported Characters(| ; ` > < } { # *)
- Output File Name Contains Unsupported Characters(| ; ` > < } { # *)

Questionable Conditions that the application will verify with User via A Dialog Message:

- Output File does not End with .pdf, Verify with User That's Really What They Want
- Output File Name Matches a File in the Output Directory

## Installation

To make this script behave more like a command, copy cpdf to a bin directory of choice that's defined in your $PATH.

This way, you can be in any directory and run this script to compress any pdf file without specifying the full path.

If you are on Linux, *BSD, or Mac, you can also run the install script:

```
git clone https://github.com/hkdb/cpdf.git
cd cpdf
./install.sh
```
You will still have to manually ensure ~/.local/bin is in $PATH


## Change Log

### JUNE 24th, 2024 - v1.3 Released - Bee

- Use /usr/bin/env python3 header instead for better compatibility
- Added a check for whether or not the input file exists
- Allow for full path to be specified for both input and output file
- Adjusted illegal characters
- Adjusted help output to be more readable
- Added install script for Linux, *BSD, macos

 
### MAY 10th, 2020 - v1.2 Released - Dragonfly

Enhancements:

  - Use Python3 instead
  - Progress Bar:

    ```
    ./cpdf ebook ~/Test/AppUserFlow_20180315.pdf ~/Test/compressed.pdf

    WARNING: "/home/hkdb/Test/compressed.pdf" already exists. Are you sure you want to overwrite it? (y/n) y

    Compressing...
    0% [##############################] 100% | ETA: 00:00:00
    Total time elapsed: 00:01:36
    Title: Compressing...
      Started: 07/29/2018 20:45:50
      Finished: 07/29/2018 20:47:26
      Total time elapsed: 00:01:36

    Compressed!

    AppUserFlow_20180315.pdf is 30MB in size.
    compressed.pdf is 4.0MB after compression.
    ```

### MAY 15th, 2018 - v1.1.2 Released - Butterfly - Hotfix 2

Bug Fixes:

- Did not bump version number in version check function of v1.1.1

Enhancement:

- Added version number in header comment of code

### MAY 14th, 2018 - v1.1.1 Released - Butterfly - Hotfix

Bug Fixes:

- Did not include command building step for situations with no WARNINGS.

### MAY 14th, 2018 - v1.1 Released - Butterfly

Features:

- Bolded and colored formating of output text to make it more readable
- Added new lines bewteen each output to make it more readable
- Added Error Handling (WARNING): Output file does not end with .pdf, verify with user that's really what they want
- Added Error Handling (WARNING): Output file name matches a file in the output directory
- Added Error Handling (ERROR): Unsafe input & output file names
- Added a version check argument

### MAY 11th, 2018 - v1.0 Released - Birth

- The birth of cPDF!

## Disclaimer

This application is maintained by volunteers and in no way do the maintainers make any guarantees. Please use at your own risk!

## Recognition

Many thanks to Dr. Haggen So for sharing the following link that inspired me to write this script:

https://www.tjansson.dk/2012/04/compressing-pdfs-using-ghostscript-under-linux/

This is an Open Source utility sponsored by 3DF Limited's Open Source Initiative:

https://osi.3df.io
https://www.3df.com.hk

## Want a graphical alternative instead?

Check out [Densify](https://github.com/hkdb/densify), a GTK+ GUI Application written in Python that simplifies compressing PDF files with Ghostscript
