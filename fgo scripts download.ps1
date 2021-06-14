$DefaultFormatEnumerationLimit = $FormatEnumerationLimit
$FormatEnumerationLimit = 2000
$DefaultErrorActionPreference = $ErrorActionPreference

if (test-path -path ./script-orig){
	} else {
	$war = Invoke-WebRequest -Method GET -Uri https://api.atlasacademy.io/nice/JP/war/308|ConvertFrom-Json|select -expand spots|select -expand quests|select id,phases
    $ErrorActionPreference = 'silentlycontinue'
	$quests = @()
	foreach($id in $war.id){
		foreach($phases in $war.phases) {
			$quest = "https://api.atlasacademy.io/nice/JP/quest/$id/$phases"
			$quests += New-Object psobject -Property @{
				questUrl = $quest
			}  
		}
	}
	$quests = $quests|Sort-Object -unique -property questUrl
    	
	$scripts = @()
	foreach($questUrl in $quests.questUrl){
		$scriptExtract = Invoke-WebRequest -Method GET -Uri  "$questUrl"|convertfrom-json|select -expand scripts|select script
		foreach($script in $scriptExtract.script) {
			$scripts += New-Object psobject -Property @{
				scriptUrl = $script
			}
		}  
	}
	$scripts = $scripts|Sort-Object -unique -property scriptUrl
	
	mkdir ./script-orig
	$scripts | ForEach-Object {
		Invoke-WebRequest $_.scriptUrl -OutFile ./script-orig/$(Split-Path $_.scriptUrl -Leaf)
	}
	$ErrorActionPreference = $DefaultErrorActionPreference
}

if (test-path -path ./fgo-scripts-parser-master){
	} else {
	$jsonParserUrl = "https://codeload.github.com/cipherallies/fgo-scripts-parser/zip/master"
	Start-BitsTransfer -Source $jsonParserUrl -Destination ./fgo-scripts-parser-master.zip
	Expand-Archive -LiteralPath ./fgo-scripts-parser-master.zip ./
}

if (test-path -path ./nodejs){
	} else {
	$nodejsInstallInput = "1`r`n`r`n`r`nexit`r`n"
    mkdir ./nodejs
    cd ./nodejs
    $nodejsUrl = "https://github.com/crazy-max/nodejs-portable/releases/download/2.10.0/nodejs-portable.exe"
	Start-BitsTransfer -Source $nodejsUrl -Destination $(Split-Path $nodejsUrl -Leaf)
    $nodejsInstallInput | ./nodejs-portable.exe
    $nodejsConfUrl = "https://github.com/sleeping-player/silver-eureka/raw/b31aceb4fce739bd379047a70e8b906c68ae70d8/nodejs-portable.conf"
    rm ./nodejs-portable.conf
    Start-BitsTransfer -Source $nodejsConfUrl -Destination $(Split-Path $nodejsConfUrl -Leaf) 
    cd ..
}

$jsonParserBuildInput = "npm cache clean -f`r`nnpm run build`r`nexit"
$jsonParserBuildInput | ./nodejs/nodejs-portable.exe

$FormatEnumerationLimit = $DefaultFormatEnumerationLimit
