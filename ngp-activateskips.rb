alias :ngpskips_old_getNGPData :getNGPData

def getNGPData
    $Unidata[:BadgeCount] = 3 if !$Unidata[:BadgeCount] || 3 > $Unidata[:BadgeCount]
    ngpskips_old_getNGPData
end
