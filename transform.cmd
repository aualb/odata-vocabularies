@echo off 
setlocal

@rem  This script uses Apache Xalan 2.7.1 as XSLT processor
@rem  For a description of Xalan command-line parameters see http://xalan.apache.org/old/xalan-j/commandline.html
@rem
@rem  Prerequisites
@rem  - Java SE 8 is installed and in the PATH - download from http://www.oracle.com/technetwork/java/javase/downloads/index.html 
@rem  - git is installed and in the PATH - download from https://git-for-windows.github.io/
@rem  - https://github.com/oasis-tcs/odata-vocabularies has been cloned next to this repository

if not exist ..\odata-vocabularies\tools\Vocab-to-MarkDown.xsl echo Please clone https://github.com/oasis-tcs/odata-vocabularies next to this folder && exit /b

set CLASSPATH=tools/xalan.jar;tools/serializer.jar
set done=false

set SCN=%2
if /I [%1] == [/scn] (
  set SCN=/scn
  shift /1
)

for /F "eol=# tokens=1" %%F in (%~n0.txt) do (
	if /I [%1] == [%%~nF] (
	    set done=true
		call :process %%F %SCN%
	) else if [%1]==[] (
	    set done=true
		call :process %%F %SCN%
	)
)

if %done%==false (
  if exist "%1" (
    call :process %1 %SCN%
  ) else (
    echo Don't know how to %~n0 %1
  )
)

endlocal
exit /b


:process
  set FILENAME=%~dpn1
  <nul (set/p _any=%~n1)

  java.exe org.apache.xalan.xslt.Process -XSL ..\odata-vocabularies\tools\Vocab-to-MarkDown.xsl -PARAM use-alias-as-filename YES -PARAM odata-vocabularies-url https://github.com/oasis-tcs/odata-vocabularies/blob/master/vocabularies/ -L -IN %1 -OUT %~n1.md
  git.exe --no-pager diff --color-words="[^[:space:]]|^(#L[0-9]+)" %~n1.md

  java.exe org.apache.xalan.xslt.Process -L -XSL ..\odata-vocabularies\tools\V4-CSDL-normalize-Target.xsl -IN %1 -OUT "%FILENAME%.normalized.xml"
  java.exe org.apache.xalan.xslt.Process -L -XSL ..\odata-vocabularies\tools\V4-CSDL-to-JSON.xsl -IN "%FILENAME%.normalized.xml" -OUT "%FILENAME%.tmp.json"
  json_reformat.exe < "%FILENAME%.tmp.json" > "%FILENAME%.json"
  if not errorlevel 1 (
    del "%FILENAME%.normalized.xml" "%FILENAME%.tmp.json"
    git.exe -C %~dp1 --no-pager diff "%FILENAME%.json"  2>nul
  )
  
  if /I [%2] == [/scn] (
    <nul (set/p _any=...)
    
    rem Generate MarkDown file without references to XML - only works in GitHub
    java.exe org.apache.xalan.xslt.Process -XSL ..\odata-vocabularies\tools\Vocab-to-MarkDown.xsl -PARAM use-alias-as-filename YES -PARAM odata-vocabularies-url https://github.com/oasis-tcs/odata-vocabularies/blob/master/vocabularies/ -IN %1 -OUT scn\%~n1.md

    tools\curl.exe -k -s --data-binary @scn\%~n1.md -H "Content-Type: text/plain" https://github.wdf.sap.corp/api/v3/markdown/raw -o scn\%~n1.html

    rem TODO: replace SED with almost-identity transformation
    tools\sed.exe ^
            -e "s/<a name=\"user-content-/^<a name=\"/g" ^
            -e "s/<span aria-hidden=\"true\" class=\"octicon octicon-link\"><\/span>//g" ^
            -e "s/<br>/<br\/>/g" ^
            -e "s/<a href=\"Org\.OData\./^<a href=\"https:\/\/github.com\/oasis-tcs\/odata-vocabularies\/blob\/master\/vocabularies\/Org\.OData\./g" ^
            -e "s/<a id=\"user-content-[[:alpha:]-]\+\" class=\"anchor\" href=\"#[[:alpha:]-]\+\" aria-hidden=\"true\"><\/a>//g" ^
            -e "s/\"Analytics\.xml\"/\"https:\/\/wiki.scn.sap.com\/wiki\/download\/attachments\/462030211\/Analytics.xml?api=v2\"/g" ^
            -e "s/\"CodeList\.xml\"/\"https:\/\/wiki.scn.sap.com\/wiki\/download\/attachments\/523995571\/CodeList.xml?api=v2\"/g" ^
            -e "s/\"Common\.xml\"/\"https:\/\/wiki.scn.sap.com\/wiki\/download\/attachments\/448470974\/Common.xml?api=v2\"/g" ^
            -e "s/\"Communication\.xml\"/\"https:\/\/wiki.scn.sap.com\/wiki\/download\/attachments\/448470971\/Communication.xml?api=v2\"/g" ^
            -e "s/\"PersonalData\.xml\"/\"https:\/\/wiki.scn.sap.com\/wiki\/download\/attachments\/496435637\/PersonalData.xml?api=v2\"/g" ^
            -e "s/\"Session\.xml\"/\"https:\/\/wiki.scn.sap.com\/wiki\/download\/attachments\/528121860\/Session.xml?api=v2\"/g" ^
            -e "s/\"UI\.xml\"/\"https:\/\/wiki.scn.sap.com\/wiki\/download\/attachments\/448470968\/UI.xml?api=v2\"/g" ^
            -e "s/com\.sap\.vocabularies\.\([^.]\+\)\.v1\.md#/https:\/\/wiki.scn.sap.com\/wiki\/display\/EmTech\/OData+4.0+Vocabularies+-+SAP+\1#/g" ^
            -e "s/\"Common\.md#/\"https:\/\/wiki.scn.sap.com\/wiki\/display\/EmTech\/OData+4.0+Vocabularies+-+SAP+Common#/g" ^
            -e "s/\"Communication\.md#/\"https:\/\/wiki.scn.sap.com\/wiki\/display\/EmTech\/OData+4.0+Vocabularies+-+SAP+Communication#/g" ^
            -e "s/\"UI\.md#/\"https:\/\/wiki.scn.sap.com\/wiki\/display\/EmTech\/OData+4.0+Vocabularies+-+SAP+UI#/g" ^
            scn\%~n1.html > scn\%~n1.scn 
    git.exe --no-pager diff scn\%~n1.scn
    del scn\%~n1.md scn\%~n1.html
  )
  echo:

exit /b