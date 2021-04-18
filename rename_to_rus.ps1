function removeServiceSubstring {
    param([string]$inString)

    $ServiceSubstring = @(
        "1080p",
        "720p",
        "\[720p\]",
        "x264",
        "hd720p",
        "divx",
        "xvid",
        "dvb",
        "bdrip",
        "iptvrip",
        "webrip",
        "webdlrip",
        "web-dlrip",
        "dvdrip",
        "hdtvrip_unknown",
        "hdtvrip_rutracker",
        "hdtvrip_mydimka",
        "tvrip",
        "satrip",
        "satrip_mdteam",
        "hdtv",
        "kb",
        "by",
        "lf",
        "and",
        "rus",
        "eng",
        "dub",
        "ws",
        "mvo",
        "dvo",
        "2xdvo"
    );   
    $arrOutStr = @(); 
    $arrInString = $inString -split '\.';
    foreach ($itemInString in $arrInString) {
        if ($itemInString -match "\d\d\d\d" -and ($itemInString -like "19*" -or $itemInString -like "20*")) {
            continue;
        }

        if ($ServiceSubstring -contains $itemInString) {
            continue;
        }

        if ($itemInString -match "S\d\dE\d\d") {
            $itemInString = $itemInString -replace "S", "Book "
            $itemInString = $itemInString -replace "E", " Episod "
        }

        $arrOutStr += SplitByUppercase($itemInString);
    }

    return $arrOutStr -join '.'
}

function simpleReplace {
    param([string]$inString)

    $ReplaceSubstring = @(
        "\.\(alexicus\)",
        "\.alexfilm",
        "\.lostlilm",
        "\.lostfilm",
        "\.RGzsRutracker",
        "\.ruuu",
        "\.vagon4eg",
        "\.nas",
        "\.alexicus",
        "\.suprug",
        "\.zhenya_hacker",
        "\.iolegv",
        "\.bigfangroup",
        "\.podolsk",
        "\.alexey724",
        "\.den1s",
        "\.hpotter",
        "\.riperam",
        "\.riper\.am",
        "\.bigfangroup",
        "\.androzzz",
        "\.youtor",
        "\.org",
        "\.novafilm",
        "\.shel",
        "\.pasha2008",
        "\.fenixclub",
        "\.generalfilm",
        "\.files-x",
        "\.Seryy1779",
        "\.AVC",
        "-kinozal\.tv",
        "\.perevod",
        "\.kuraj-bambey",
        "\.rip",
        "\.tahiy",
        "\.casstudio",
        "\.lizard",
        "\.\(qqss44\)",
        "\.\(1080p\)",
        "\.\[qqss44\]",
        "\.olegek70",
        "\.exkinoray",
        "\.subs-green",
        "\.subs",
        "\.\[hi10p\]",
        "\.web-dlrip",
        "\.web-dl",
        "\.nikolspup",
        "\.  files-x",
        "\.Сибиряк"
    );  
    foreach ($itemRepl in $ReplaceSubstring) {
        $inString = $inString -replace $itemRepl, ""; 
    }

    return $inString;
}

function inFilenameMask {
    param([string]$inString)

    $maskedSymbols = @(
        '(',
        ')',
        '[',
        ']',
        '{',
        '}',
        '+',
        '?'
    )
    $outChars = "";
    foreach ($c in $inString.ToCharArray()) {
        if ($maskedSymbols -contains $c ) 
        { $outChars += "\" + $c }
        else
        { $outChars += $c }
    }
    return $outChars;
}

function PostProcessing {
    param([string]$inString)
    $PostReplace = New-Object system.collections.hashtable
    $PostReplace["випйск"] = "выпуск";
    $PostReplace["Лассие"] = "Лэсси";
    $PostReplace["Лесси"] = "Лэсси";
    $PostReplace["Нев"] = "Новые приключения";
    $PostReplace["Восмидесйатё"] = "Восьмидесятые";
    $PostReplace["Восймидесйатие"] = "Восьмидесятые";
    $PostReplace["80е"] = "Восьмидесятые";
    $PostReplace["80-е"] = "Восьмидесятые";
    $PostReplace["Епизод"] = "Эпизод";
    $PostReplace["серийа"] = "серия";
    $PostReplace["Куxнйа"] = "Кухня";
    $PostReplace["Куhня"] = "Кухня";
    $PostReplace["Марпле"] = "Марпл";
    $PostReplace["филм"] = "фильм";
    $PostReplace["П Д "] = "Папины дочки ";
    $PostReplace["сериа"] = " серия";
    $PostReplace["могикиан"] = "Магикян";
    $PostReplace["шерлоцк"] = "Шерлок";
    $PostReplace["Йонес"] = "Джонс";
    $PostReplace["Маша.и. Медвед"] = "Маша и Медведь";

    foreach ($rpl in $PostReplace.Keys) {
        $inString = $inString -creplace $rpl, $PostReplace[$rpl];
    }

    return $inString;
}

function PreProcessing {
    param([string]$inString)
    $PreReplace = New-Object system.collections.hashtable
    $PreReplace["house_md"] = "Доктор Хаус";
    $PreReplace["House M.D"] = "Доктор Хаус";
    $PreReplace["NewYear"] = "Новый год";
    $PreReplace["1nterny"] = "Интерны";

    $PreReplace["The\.Big\.Bang\.Theory"] = "Теория большого взрыва";
    $PreReplace["TBBT"] = "Теория большого взрыва";

    $PreReplace["\[Korra-Avatar\]_"] = "";
    $PreReplace["\[Korra-Avatar_&_Pokemon-Alliance\]_"] = "";

    foreach ($rpl in $PreReplace.Keys) {
        $inString = $inString -creplace $rpl, $PreReplace[$rpl];
    }

    return $inString;
}

function TranslitRU2LAT {
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
        [char]'w' = "в"; [char]'W' = " В";
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
        [char]'h' = "х"; [char]'H' = " Х";
        [char]'c' = "ц"; [char]'C' = " Ц";
        [char]'y' = "ы"; [char]'Y' = " Ы";
        #[char]'y' = "й"; [char]'Y' = " Й";
    }

    $TranslitPost1 = New-Object system.collections.hashtable;
    $TranslitPost1['_ '] = " ";
    $TranslitPost1[' _'] = " ";
    $TranslitPost1['_ '] = " ";

    $TranslitPost2 = New-Object system.collections.hashtable;
    $TranslitPost2['_'] = " ";

    $outChars = ""
    foreach ($trs in $TranslitTree.Keys) {
        $inString = $inString -creplace $trs, $TranslitTree[$trs];
    }
    foreach ($trs in $TranslitTwo.Keys) {
        $inString = $inString -creplace $trs, $TranslitTwo[$trs];
    }
    foreach ($c in $inChars = $inString.ToCharArray()) {
        if ($Null -cne $TranslitOne[$c] ) 
        { $outChars += $TranslitOne[$c] }
        else
        { $outChars += $c }
    }
    foreach ($trs in $TranslitPost1.Keys) {
        $outChars = $outChars -creplace $trs, $TranslitPost1[$trs];
    }
    foreach ($trs in $TranslitPost2.Keys) {
        $outChars = $outChars -creplace $trs, $TranslitPost2[$trs];
    }
    return $outChars
}

function SplitByUppercase {
    param([string]$inString)
    $arrConstUppercase = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЭЮЯ".ToCharArray();
    
    $InArrChars = $inString.ToCharArray();

    $outChars = "";
    $hasSpace = $true;
    $isFirst = $true;
    foreach ($chr in $InArrChars) {
        if ($arrConstUppercase -ccontains $chr) {
            $outChars += (-not $hasSpace ? " " : "") + ($isFirst ? $chr : $chr.ToString().ToLower());
        }
        else {
            $outChars += $chr;
        }
        $isFirst = $false;
        $hasSpace = ($chr -eq ' ');
    }

    return $outChars;
}

Clear-Host


$path = $args[0]
if ($null -eq $path) {
    $path = "\\NAS\Video\Сериалы\Ивановы Ивановы\Сезон 3\Ivanovy.Ivanovy.S.03.(01.seriya).WEB-DL.(1080p).mkv";
}
Write-Host $path;
Pause

$doTranslit = $false;

foreach ($file in Get-ChildItem -LiteralPath $path -Recurse -File) {
    $newPath = $file;
    $OldName = [io.path]::GetFileNameWithoutExtension($file)
    $maskedOldName = inFilenameMask($OldName)
    $TransName0 = PreProcessing($OldName)
    $TransName1 = simpleReplace($TransName0)
    $TransName2 = removeServiceSubstring($TransName1)
    $TransName3 = TranslitRU2LAT($TransName2)
    $TransName4 = $doTranslit ? $TransName3.trim() : $TransName2.trim();
    $NewName = PostProcessing($TransName4);
    $newPath = $newPath -creplace $maskedOldName, $NewName;
    if ($newPath -ne $file) {
        Write-Host $file.FullName [$newPath]
        Rename-Item -LiteralPath $file.FullName -NewName $newPath 
    }
} 
Pause
