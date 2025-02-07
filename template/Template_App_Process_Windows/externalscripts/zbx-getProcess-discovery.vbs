' ******************************************************************************
' zbx-getProcess-discovery
' Author:   Matthieu ACKERMANN <matthieu.ackermann@gmail.com>
' Date:     2019-11-15
' for:      IDS 
' Version:  1.0
' Description: Custom script created for Zabbix monitoring (monitoring of processes specified in a text file)
' Call this script with the following command : cscript /nologo zbx-getProcess-discovery.vbs

' Get all the processes on this computer
strComputer		= "."
Set objWMIService	= GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colProcess		= objWMIService.ExecQuery ("Select * from Win32_Process")

' Read the configuration file 
Set obj = CreateObject("Scripting.FileSystemObject")
Set dict = CreateObject("Scripting.Dictionary")
Const ForReading = 1      
Set file = obj.OpenTextFile("C:\zabbixIDS\scripts\processes_to_monitor.txt", ForReading) 

Do Until file.AtEndOfStream
  line = file.Readline
  dict.Add row, line
  row = row + 1
Loop
file.Close

' Browse of the dictionnary to build the WMI query
Dim strList 
For Each line in dict.Items
	strList = strList &" Name like '" & line &"%' OR"
Next
' Delete the last string "OR" 
Set regEx = New RegExp
regEx.Pattern = "(.*)(OR$)"
strList = regEx.Replace(strList, "$1")
'WScript.Echo strList 


' Check if the previous processes founded in the config file are running on the system
dim myprocesses 
Set myprocesses = CreateObject("System.Collections.ArrayList")
Set colProcess = objWMIService.ExecQuery ("Select * from Win32_Process where "& strList)

For Each objItem in colProcess
If not myprocesses.Contains(Replace(objItem.Name,".exe","")) Then
  myprocesses.Add Replace(objItem.Name,".exe","")
End If
Next

' Make the JSON output
For Each line in myprocesses
    jsonValue = jsonValue & "{""PROCESSNAME"":""" & MakeSJONCompatible(line) & """},"
Next

' function to make SJON compatible.
Function MakeSJONCompatible(value)
  ' first let check if the value is null
  nullValue = IsNull(value)
  If nullValue = false Then 
    value = Replace(value,"\","\\")    ' replace \ with \\
    value = Replace(value,"""","\""")  ' replace " with \"
  End if
  MakeSJONCompatible = value
End Function

'JSONBegin = "{""data"":["     ' JSON begin
'JSONEnd   = "]}"              ' JSON end.

JSONBegin = "["     ' JSON begin
JSONEnd   = "]"     ' JSON end.

createJSON = JSONBegin & jsonValue & JSONEnd
'createJSON = Replace(createJSON,",]}","]}")
createJSON = Replace(createJSON,",]","]")

JSONFinal = createJSON

' finally lets print the value.
wscript.echo JSONFinal
