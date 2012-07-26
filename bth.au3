#include <String.au3>
$oldT = 0
$blockSize = 64
$strBin = ''
$filename = FileOpenDialog('Open', '', 'Dat (*.dat)|Hex (*.hex)|All (*.*)')
$errStatus = @error
If $errStatus Then
	ConsoleWrite('log: file not selected' & @CRLF)
	Exit
EndIf
ConsoleWrite('log: $filename = ' & $filename & @CRLF)
$file = FileOpen($filename)
If $file = -1 Then
	ConsoleWrite('log: FileOpen error' & @CRLF)
	Exit
EndIf
$fileSize = FileGetSize($filename)
$allBytes = $fileSize
$maxk = Floor($allBytes / $blockSize)
$beg = TimerInit()
For $k = 0 To $maxk
	$bs = $blockSize
	If $allBytes - $k * $blockSize < 64 Then $bs = $allBytes - $k * $blockSize
	If $bs = 0 Then ExitLoop
	$adr = $k * $blockSize
	FileSetPos($file, $adr, 0)
	$dd = FileRead($file, $bs)
	;ConsoleWrite('log: $dd = ' & $dd & @CRLF)
	$strBin &= _HexToString($dd)
	$timerD = TimerDiff($beg)
	If Int($timerD / 1000) <> $oldT Then
		$oldT = Int($timerD / 1000)
		ConsoleWrite('log: ' & $k * $blockSize + $bs & ' bytes done, ' & Int($timerD) & ' msec' & @CRLF)
	EndIf
Next
ConsoleWrite('log: read done in '& Int($timerD) & ' msec' & @CRLF)
FileClose($file)


$filename = FileSaveDialog('Save as', '', 'Binary (*.bin)|All (*.*)', 16)
$errStatus = @error
If $errStatus Then
	ConsoleWrite('log: file not selected' & @CRLF)
	Exit
EndIf
If StringRight($filename, 4) <> '.bin' Then
	$filename &= '.bin'
EndIf
ConsoleWrite('log: $filename = ' & $filename & @CRLF)
$file = FileOpen($filename, 2)
If $file = -1 Then
	ConsoleWrite('log: FileOpen error' & @CRLF)
	Exit
EndIf
$beg = TimerInit()
$oldT = 0
$allBytes = $allBytes / 2
$maxk = Floor($allBytes / $blockSize)
For $k = 0 To $maxk
	$bs = $blockSize
	If $allBytes - $k * $blockSize < 64 Then $bs = $allBytes - $k * $blockSize
	If $bs = 0 Then ExitLoop
	$adr = $k * $blockSize
	FileWrite($file, StringMid($strBin, $adr, $blockSize))
	$timerD = TimerDiff($beg)
	If Int($timerD / 1000) <> $oldT Then
		$oldT = Int($timerD / 1000)
	ConsoleWrite('log: ' & $k * $blockSize + $bs & ' bytes done, ' & Int($timerD) & ' msec' & @CRLF)
	EndIf
Next
ConsoleWrite('log: write done in '& Int($timerD) & ' msec' & @CRLF)
FileClose($file)