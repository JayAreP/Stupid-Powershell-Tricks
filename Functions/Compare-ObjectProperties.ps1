Function Compare-ObjectProperties {
    Param(
        [parameter(mandatory)]
        [PSObject]$ReferenceObject,
        [parameter(mandatory)]
        [PSObject]$DifferenceObject 
    )
    <#
    .SYNOPSIS

    Compares two PSObjects and displays the properties side-by-side

    .EXAMPLE

    $filearray = Get-ChildItem | Where-Object {!$_.PSIsContainer}
    
    Compare-ObjectProperties -ReferenceObject $filearray[1] -DifferenceObject $filearray[2]

    #>
    $refObj = $ReferenceObject | Get-Member -MemberType Property,NoteProperty | Foreach-Object Name
    $refObj += $DifferenceObject | Get-Member -MemberType Property,NoteProperty | Foreach-Object Name
    $refObj = $refObj | Sort-Object | Select-Object -Unique
    $diffs = @()
    foreach ($objprop in $refObj) {
        $diff = Compare-Object $ReferenceObject $DifferenceObject -Property $objprop
        if ($diff) {            
            $diffprops = @{
                PropertyName=$objprop
                RefValue=($diff | Where-Object {$_.SideIndicator -eq '<='} | Foreach-Object $($objprop))
                DiffValue=($diff | Where-Object {$_.SideIndicator -eq '=>'} | Foreach-Object $($objprop))
            }
            $diffs += New-Object PSObject -Property $diffprops
        }        
    }
    if ($diffs) {
        return ($diffs | Select-Object PropertyName,RefValue,DiffValue)
    }     
}