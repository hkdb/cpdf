# Change Log

### JANUARY 21, 2026 - v2.0 Released

- Uses command list instead to avoid shell injection (Security)
- Updated install.sh for a smoother installation experience 
- Build binary and upload to release with Github Actions to alleviate pyprind dependency issues - [#6](https://github.com/hkdb/cpdf/issues/6)
- Added `install.bat` for Windows installation
- Streamlined installation with curl method


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


