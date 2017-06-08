# hello-world
how to create repo
checking how branch and commit works
********************************************************
Ping Test using Excel(select and test)
********************************************************

Sub ping_test()

  Dim rngArea As Range

Application.ScreenUpdating = True

For Each rngArea In Selection
With rngArea

strcomputer = rngArea.Value

If Ping(strcomputer) = True Then

 rngArea.Offset(0, 1).Interior.Color = RGB(0, 255, 0)
 rngArea.Offset(0, 1).Value = "ONLINE"
 rngArea.Offset(0, 2).Value = Now()
 
 Else
  rngArea.Offset(0, 1).Interior.Color = RGB(255, 0, 0)
  rngArea.Offset(0, 1).Value = "OFFLINE"
  rngArea.Offset(0, 2).Value = Now()
  End If
End With

Next rngArea

MsgBox "Script Completed"

End Sub


Function Ping(strcomputer)

Dim objshell, boolcode

Set objshell = CreateObject("wscript.shell")

boolcode = objshell.Run("ping -n 2 -w 1000 " & strcomputer, 0, True)

If boolcode = 0 Then

Ping = True

Else

Ping = False

End If

End Function

Sub Clear_Status()

For Each rngArea In Selection

With rngArea

rngArea.Offset(0, 1).Interior.Color = RGB(255, 255, 255)
rngArea.Offset(0, 1).Cells.ClearContents
rngArea.Offset(0, 2).Cells.ClearContents

End With

Next rngArea
End Sub

********************************************************


********************************************************
Ping Test using Excel(servers in 1st coloum)
********************************************************

Sub check_status()

Dim strcomputer As String

Application.ScreenUpdating = True

For introw = 2 To ActiveSheet.Cells(65536, 1).End(xlUp).Row

strcomputer = ActiveSheet.Cells(introw, 1).Value

'———Call ping function and post the output in the adjacent cell——-

If Ping(strcomputer) = True Then

    

ActiveSheet.Cells(introw, 2).Value = "Online"
ActiveSheet.Cells(introw, 2).Interior.Color = RGB(0, 128, 0)
ActiveSheet.Cells(introw, 3).Value = Now()

Else

ActiveSheet.Cells(introw, 2).Interior.Color = RGB(200, 0, 0)

ActiveSheet.Cells(introw, 2).Value = "Offline"
ActiveSheet.Cells(introw, 3).Value = Now()

End If

Next

MsgBox "Script Completed"

End Sub


Function Ping(strcomputer)

Dim objshell, boolcode

Set objshell = CreateObject("wscript.shell")

boolcode = objshell.Run("ping -n 2 -w 1000 " & strcomputer, 0, True)

If boolcode = 0 Then

Ping = True

Else

Ping = False

End If

End Function

Sub clear_status()

Range("B2:B1000").Cells.ClearContents
Range("B2:B1000").Interior.Color = RGB(255, 255, 255)
Range("C2:B1000").Cells.ClearContents

End Sub


