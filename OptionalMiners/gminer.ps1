if (!(IsLoaded(".\Includes\include.ps1"))) { . .\Includes\include.ps1; RegisterLoaded(".\Includes\include.ps1") }
$Path = ".\Bin\NVIDIA-Gminer196\miner.exe"
$Uri = "https://github.com/develsoftware/GMinerRelease/releases/download/1.96/gminer_1_96_windows64.zip"
$Commands = [PSCustomObject]@{ 
    #"beamv2"           = " --devices $($Config.SelGPUDSTM) -a BeamHashII" #Equihash150 (NiceHash)
    #"equihash125"      = " --devices $($Config.SelGPUDSTM) -a 125_4" #Equihash125
    #"equihash144"      = " --devices $($Config.SelGPUDSTM) -a 144_5 --pers auto" #Equihash144
    "equihash96"       = " --devices $($Config.SelGPUDSTM) -a 96_5 --pers auto" #Equihash144
    #"zhash"            = " --devices $($Config.SelGPUDSTM) -a 144_5 --pers auto" #Zhash
    #"equihash192"      = " --devices $($Config.SelGPUDSTM) -a 192_7 --pers auto" #Equihash192
    #"equihash-btg"     = " --devices $($Config.SelGPUDSTM) -a 144_5 --pers BgoldPoW " # Equihash-btg MPH
    "grincuckaroo29"   = " --devices $($Config.SelGPUDSTM) --algo cuckaroo29 --pers auto" #Grincuckaroo29
    "grincuckarood29"  = " --devices $($Config.SelGPUDSTM) --algo cuckarood29 --pers auto" #Grincuckarood29
    "cuckoocycle"      = " --devices $($Config.SelGPUDSTM) --algo aeternity --pers auto" #Aeternity 
    #"grincuckatoo31"   = " --devices $($Config.SelGPUDSTM) --algo grin31 --pers auto" #Grincuckatoo31(8gb cards work win7,8, 8.1 & Linux. Win10 requires 10gb+vram)
    #"ethash"           = " --devices $($Config.SelGPUDSTM) --algo ethash --proto stratum" #Ethash
    "eaglesong"        = " --devices $($Config.SelGPUDSTM) --algo eaglesong" #Eaglesong 
    "cuckaroom"        = " --devices $($Config.SelGPUDSTM) --algo grin29" #Cuckaroom 
    "ethash+eaglesong" = " --devices $($Config.SelGPUDSTM) --algo eth+ckb --proto stratum --dproto stratum --dual_intensity 0" #Ethash + Eaglesong
}
$Name = "$(Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName)"
$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object { $Algo = Get-Algorithm ($_ -split '\+' | Select-Object -Index 0); $Algo2 = Get-Algorithm ($_ -split '\+' | Select-Object -Index 1); $_ } | Where-Object { $Pools.$Algo.Host } | ForEach-Object { 
    switch ($_) { 
        "ethash" { $Fee = 0.0065 }
        "cuckaroom" { $Fee = 0.03 }
        "ethash+eaglesong" { $Fee = 0.03 }
        default { $Fee = 0.02 }
    }

    $HashRates = [PSCustomObject]@{ $Algo = $Stats."$($Name)_$(@(($Algo + $Algo2) | Select-Object) -Join '-')_HashRate".Day * (1 - $Fee) } # substract devfee
    if ($Algo2) { $HashRates | Add-Member "$Algo2" ($Stats."$($Name)_$((@($Algo + $Algo2) | Select-Object) -Join '-')_HashRate".Day * (1 - $Fee) ) } # substract devfee

    [PSCustomObject]@{ 
        Type      = "NVIDIA"
        Path      = $Path
        Arguments = "--watchdog 0 --pec 0 --nvml 0 --api $($Variables.NVIDIAMinerAPITCPPort) --server $($Pools.$Algo.Host) --port $($Pools.$Algo.Port) --user $($Pools.$Algo.User) --pass $($Pools.$Algo.Pass)$(if ($Algo2) { " --dserver $($Pools.$Algo2.Host) --dport $($Pools.$Algo2.Port) --duser $($Pools.$Algo2.User) --dpass $($Pools.$Algo2.Pass)" } )$($Commands.$_)"
        HashRates = $HashRates
        API       = "gminer"
        Port      = $Variables.NVIDIAMinerAPITCPPort
        Wrap      = $false
        URI       = $Uri
    }
}
