function TranslitRU2LAT
{
    param([string]$inString)
    $TranslitTree = New-Object system.collections.hashtable
    $TranslitTree["sch"] = 'щ';
    $TranslitTree["Sch"] = ' Щ';

    $TranslitTwo = New-Object system.collections.hashtable
    $TranslitTwo["ye"] = 'ё';
    $TranslitTwo["Ye"] = ' Ё';
    $TranslitTwo["zh"] = 'ж';
    $TranslitTwo["Zh"] = ' Ж';
    $TranslitTwo["kh"] = 'х';
    $TranslitTwo["Kh"] = ' Х';
    $TranslitTwo["ts"] = 'ц';
    $TranslitTwo["Ts"] = ' Ц';
    $TranslitTwo["ch"] = 'ч';
    $TranslitTwo["Ch"] = ' Ч';
    $TranslitTwo["sh"] = 'ш';
    $TranslitTwo["Sh"] = ' Ш';
    $TranslitTwo["yu"] = 'ю';
    $TranslitTwo["Yu"] = ' Ю';
    $TranslitTwo["ya"] = 'я';
    $TranslitTwo["Ya"] = ' Я';
    $TranslitTwo["ju"] = 'ю';
    $TranslitTwo["Ju"] = ' Ю';

    $TranslitOne = @{ 
        [char]'a' = "а"; [char]'A' = " А";
        [char]'b' = "б"; [char]'B' = " Б";
        [char]'v' = "в"; [char]'V' = " В";
        [char]'g' = "г"; [char]'G' = " Г";
        [char]'d' = "д"; [char]'D' = " Д";
        [char]'e' = "е"; [char]'E' = " Е";
        [char]'z' = "з"; [char]'Z' = " З";
        [char]'i' = "и"; [char]'I' = " И";
        [char]'j' = "й"; [char]'J' = " Й";
        [char]'k' = "к"; [char]'K' = " К";
        [char]'l' = "л"; [char]'L' = " Л";
        [char]'m' = "м"; [char]'M' = " М";
        [char]'n' = "н"; [char]'N' = " Н";
        [char]'o' = "о"; [char]'O' = " О";
        [char]'p' = "п"; [char]'P' = " П";
        [char]'r' = "р"; [char]'R' = " Р";
        [char]'s' = "с"; [char]'S' = " С";
        [char]'t' = "т"; [char]'T' = " Т";
        [char]'u' = "у"; [char]'U' = " У";
        [char]'f' = "ф"; [char]'F' = " Ф";
        [char]'c' = "ц"; [char]'C' = " Ц";
        #[char]'y' = "ы"; [char]'Y' = " Ы";
        [char]'y' = "й"; [char]'Y' = " Й";
    }

    $TranslitPost1 = New-Object system.collections.hashtable;
    $TranslitPost1['_ '] = " ";
    $TranslitPost1[' _'] = " ";
    $TranslitPost1['_ '] = " ";

    $TranslitPost2 = New-Object system.collections.hashtable;
    $TranslitPost2['_'] = " ";

    $outChars = ""
    foreach ($trs in $TranslitTree.Keys)
    {
        $inString = $inString -creplace $trs, $TranslitTree[$trs];
    }
    foreach ($trs in $TranslitTwo.Keys)
    {
        $inString = $inString -creplace $trs, $TranslitTwo[$trs];
    }
    foreach ($c in $inChars = $inString.ToCharArray())
    {
        if ($Null -cne $TranslitOne[$c] ) 
        { $outChars += $TranslitOne[$c] }
        else
        { $outChars += $c }
    }
    foreach ($trs in $TranslitPost1.Keys)
    {
        $outChars = $outChars -creplace $trs, $TranslitPost1[$trs];
    }
    foreach ($trs in $TranslitPost2.Keys)
    {
        $outChars = $outChars -creplace $trs, $TranslitPost2[$trs];
    }
    return $outChars
}
Clear-Host

<# 
$file = "015_IscheznovenieMisteraDevenkhayma"
$NewName = TranslitRU2LAT($file)
Write-Host $NewName 
 #>
$path = 'Z:\Series\Каменская'
 
foreach ($file in Get-ChildItem -Path $path -Recurse -File)
{
    $newPath = $file;
    $OldName = [io.path]::GetFileNameWithoutExtension($file)
    $NewName = TranslitRU2LAT($OldName)
    $newPath = $newPath -creplace $OldName, $NewName;
    if ($newPath -ne $file)
    {
        Write-Host $file.FullName [$newPath] -ForegroundColor Yellow
        Rename-Item -LiteralPath $file.FullName -NewName $newPath 
    }
} 
