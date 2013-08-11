Rem

	Backup Software - August 10th 2013
	Author: James Laderoute
	
	
	User provides an input list of the source folders.
		Comment lines can be provided using the # at the beginning of the line
		All files under the folder (including sub-folders etc) are backed up

	User provides a destination directory to copy the files and folders too.
		The user's choice is stored in a .jjlbackup file that resides in the
		same directory as the executable program does.
	
	
EndRem
Strict ' This prevents us from using misspelled variables by accident, very helpful


Local filename$ = "to_be_backed_up.txt"
If (FileSize(filename$) = -1) Then
	Notify("Please create your text file of folder names that you wish to be backed up. " + CurrentDir() + "/" + filename$)
	End
EndIf


Local destination_folder$ = CurrentDir()
If (FileSize(".jjlbackup") <> -1 ) Then
	Local deffile:TStream = OpenFile(".jjlbackup")
	destination_folder$ = ReadLine(deffile)
	CloseStream(deffile)
EndIf

destination_folder$=RequestDir("Choose your destination folder if not " + destination_folder$, destination_folder$)

If ( destination_folder$ = "" ) Then
 Notify "No backup was done because you pressed the CANCEL button" 
 End
EndIf

Local outf:TStream = WriteFile(".jjlbackup")
WriteLine(outf, destination_folder$)
CloseStream(outf)


Local srcdirs:TList = New TList



' Read In the backup text file - save the list
' of directories to a LIST
Local alldirs$ = ""

Local file:TStream =OpenFile( filename$ )
If Not file RuntimeError "could not open file " + filename$
While Not Eof(file)
	Local line$ = ReadLine(file)
	If ( line$[..1] = "#" ) Then
		' this is a comment - ignore
		Continue
	EndIf
	
	If ( line$ = destination_folder$ ) Then
		Notify("You can't copy from source folder to the source folder !", True)
		Continue
	EndIf
	
	alldirs$ = alldirs$ + " " + line$
	
	srcdirs.AddLast(line$)
Wend
CloseStream file


' We now copy the SOURCE files to the destination directory
Local result = Proceed("Proceed to Copy files to " + destination_folder$ )
If ( Not result ) Then 
	Notify("Copy Operation was cancelled by you.")
	End
EndIf


For Local src$=EachIn srcdirs
	Local folderName$ = StripAll( src$ )' last name in src$ path
	'Print "strip to " + destination_folder$ + "/" + folderName$
	'End
    Local result = CopyDir( src$, destination_folder$  + "/" + folderName$)
	If ( Not result ) Then
		Notify( "Unable to copy " + src$ + " to " + destination_folder$ )
	EndIf
	
Next


If ( alldirs$ <> "") Then Notify("Folders have been copied to " + destination_folder$)

