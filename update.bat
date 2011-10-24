wget --no-check-certificate https://github.com/ASCTech/cmap-eval/zipball/master -Ocmap-eval.zip

"%ProgramFiles(x86)%\7-Zip\7z" x cmap-eval.zip

rmdir /s /q cmap-eval
move ASCTech-cmap-eval* cmap-eval
