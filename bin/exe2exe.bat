<# :
@echo off
setlocal
set "POWERSHELL_BAT_ARGS=%*"
if defined POWERSHELL_BAT_ARGS set "POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%"
endlocal & powershell -NoLogo -NoProfile -Command "$_ = $input; Invoke-Expression $( '$input = $_; $_ = \"\"; $args = @( &{ $args } %POWERSHELL_BAT_ARGS% );' + [String]::Join( [char]10, $( Get-Content \"%~f0\" ) ) )"
goto :EOF
#>

# =========================================================================

$ProgName = if ( $MyInvocation.MyCommand.Name ) { $MyInvocation.MyCommand.Name } else { "exe2exe" };

$Version = "0.3 Beta";

$Help = @"
$ProgName Version $Version
Create EXE-file call redirector

$ProgName [ -c ] [ -exe name ] command-line

-c    Chdir to wrapper directory
-exe  The name of the executable file
"@;

# =========================================================================

$chdir = $False;
$exename = "";
$cmdline = "";

$i = 0;

if ( $args[$i] -eq "-c" ) {
	$chdir = $True;
	$i++;
}

if ( $args[$i] -eq "-exe" ) {
	$exename = $args[$i + 1];
	$i += 2;
} else {
	$exename = $args[$i];
}

if ( ! $args ) {
	Write-Host $Help;
	exit;
}

$cmdline = [String]::Join( " ", $args[$i..$args.count] );

# =========================================================================

$exewrapper = @"
TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAsAAAAA4fug4AtAnNIbgBTM0hVGhpcyBwcm9ncmFtIGNhbm5vdCBiZSBydW4gaW4gRE9TIG1v
ZGUuDQ0KJAAAAAAAAABdFx3bGXZziBl2c4gZdnOIGXZziAx2c4jlVmGIGHZziFJpY2gZdnOIAAAA
AAAAAABQRQAATAEDALPSFD4AAAAAAAAAAOAADwELAQUMAAQAAAAKAAAAAAAA7xAAAAAQAAAAIAAA
AABAAAAQAAAAAgAABAAAAAAAAAAEAAAAAAAAAABAAAAABAAAAAAAAAMAAAAAABAAABAAAAAAEAAA
EAAAAAAAABAAAAAAAAAAAAAAAEggAAA8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAASAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC50ZXh0AAAAvAMAAAAQAAAABAAAAAQAAAAAAAAAAAAA
AAAAACAAAGAucmRhdGEAABgCAAAAIAAAAAQAAAAIAAAAAAAAAAAAAAAAAABAAABALmRhdGEAAAB8
BAAAADAAAAAGAAAADAAAAAAAAAAAAAAAAAAAQAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFWL
7GCLfQiAPwB0A0fr+ItNECtNCFH/dQxX6JcDAABhycIMAFWL7IHEAOD//2Bo/w8AAP91CI2FAPD/
/1DodAMAAI29APD//+sIgD8AdQLrVEeAPz1184B//yt1N8ZH/wBo/w8AAI2FAOD//1CNhQDw//9Q
6A0DAABHaP8PAABXjYUA4P//UOh0////jb0A4P//6wTGBwBHV42FAPD//1DoBQMAAGHJwgQAVYvs
U1FSVleLdQi4AAAAALkKAAAAD7Y+g/8tdQFGD7YegPswcg+A+zl3CoDrMPfhA8NG6+mD/y11AvfY
X15aWVvJwgQAagDoqAIAAKMgNEAA6HoCAACjJDRAAPzo7wAAAFDoXQIAAFWL7GCLTQxn4xiLfQgD
+U+AP190B4A/IHQC6wbGBwBP4u5hycIIAFWL7GCLNSQ0QACAPiJ1E0aAPiJ0BYA+AHX1gD4AdBBG
6w3rAUaAPiB0BYA+AHX16wFGgD4gdPr/dQxW/3UI6DsCAABhycIIAFWL7IPE/OgHAgAAi8hqAGoA
jUX8UGgABAAAUWoAaAATAADozQEAAItF/MnDYL5zMkAA6zyL/usBR4H/pzNAAHMKgD8KdAWAPw11
7YvPK85RVug7////gD4AdAZW6EP+///rAUeAPwp0+oA/DXT1i/eB/qczQAByvGHDVYvsgcT86///
aAAEAACNhQD8//9QagDoggEAAI2F/Pv//1CNhfzv//9QaAAEAACNhQD8//9Q6FcBAACLhfz7///G
QP8AgD1fMkAAIHQaaAAEAACNhfzv//9QjYX86///UOhWAQAA6xGNhfzr//9QaAAEAADoDQEAAOg0
////aA4BAABoMTFAAOiK/v//aAAEAACNhfzz//9Q6KD+//+Nhfzz//9QaDExQABoGjRAAI2F/Pf/
/1DopwAAAIPEEI2F/O///1Do4AAAAL84NEAAuUQAAAAzwPOqxwU4NEAARAAAAGgoNEAAaDg0QACN
hfzr//9QagBqIGoBagBqAI2F/Pf//1BqAOhjAAAAC8B1P+hy/v//i8hRjYX89///UGgHNEAAjYUA
/P//UOgzAAAAg8QQajBoADRAAI2FAPz//1BqAOghAAAAuAAAAADJw2r//zUoNEAA6FsAAAC4AAAA
AMnD/yVAIEAA/yU8IEAA/yUIIEAA/yUMIEAA/yUQIEAA/yUUIEAA/yUYIEAA/yUEIEAA/yUAIEAA
/yUgIEAA/yUkIEAA/yUoIEAA/yUsIEAA/yUwIEAA/yU0IEAA/yUcIEAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABoIQAA
TiEAAPIgAAAEIQAAEiEAACQhAAA2IQAA/iEAAHwhAACMIQAAoiEAALYhAADOIQAA6CEAAAAAAADY
IAAAzCAAAAAAAADAIAAAAAAAAAAAAADmIAAAPCAAAIQgAAAAAAAAAAAAAAoiAAAAIAAAAAAAAAAA
AAAAAAAAAAAAAAAAAABoIQAATiEAAPIgAAAEIQAAEiEAACQhAAA2IQAA/iEAAHwhAACMIQAAoiEA
ALYhAADOIQAA6CEAAAAAAADYIAAAzCAAAAAAAAClAndzcHJpbnRmQQC7AU1lc3NhZ2VCb3hBAFVT
RVIzMi5kbGwAAEIAQ3JlYXRlUHJvY2Vzc0EAAHUARXhpdFByb2Nlc3MAnQBGb3JtYXRNZXNzYWdl
QQAAtgBHZXRDb21tYW5kTGluZUEA4QBHZXRDdXJyZW50RGlyZWN0b3J5QQAA9QBHZXRFbnZpcm9u
bWVudFZhcmlhYmxlQQABAUdldEZ1bGxQYXRoTmFtZUEAAAUBR2V0TGFzdEVycm9yAAAPAUdldE1v
ZHVsZUZpbGVOYW1lQQAAEQFHZXRNb2R1bGVIYW5kbGVBAAA+AlNldEN1cnJlbnREaXJlY3RvcnlB
AABDAlNldEVudmlyb25tZW50VmFyaWFibGVBAKgCV2FpdEZvclNpbmdsZU9iamVjdADfAmxzdHJj
cHluQQBLRVJORUwzMi5kbGwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADQoNCg0K
IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMj
IyMjIyMjIyMjIyMjIyMjIyMjIyMjDQpFWEUtZmlsZSBjYWxsIHJlZGlyZWN0b3IgYnkgRG1pdHJ5
IEtvdGVyb2ZmIChka0Bka2xhYi5ydSkuDQpZb3UgbWF5IGVkaXQgZXhlY3V0YWJsZSBmaWxlIHdp
dGggYW55IGJpbmFyeSBlZGl0b3IgdG8gbGluayB0bw0KeW91ciBjdXN0b20gcHJvZ3JhbS4gRE8g
Tk9UIGluc2VydCBjaGFyYWN0ZXJzIC0gb25seSByZXBsYWNlIQANCg0KRVhFIG5hbWU6ICAgICAg
ICAgICAgICAgICAgIFtfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19d
DQpDaGRpciB0byB3cmFwcGVyIGRpcmVjdG9yeT8gWyBdDQpFbnZpcm9ubWVudDogWw0KX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18NCl9fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXw0KX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fDQpdDQoNCiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMj
IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIw0KDQoNCkVycm9yIQBD
YW5ub3QgcnVuICVzOg0KJXMAJXMgJXMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
"@;

# =========================================================================

$exewrapper = [System.Convert]::FromBase64String($exewrapper);
$exewrapper = [System.Text.Encoding]::Default.GetString($exewrapper);

if ( $chdir ) {
	$exewrapper = $exewrapper -replace "\[ \]", "[x]";
}

$pattern = "_" * 270;
$padding = "_" * ( 270 - $cmdline.length );

$exewrapper = $exewrapper -replace $pattern, ( $cmdline + $padding );
$exewrapper = [System.Text.Encoding]::Default.GetBytes($exewrapper);

[IO.File]::WriteAllBytes($exename, $exewrapper);

# =========================================================================

# EOF
