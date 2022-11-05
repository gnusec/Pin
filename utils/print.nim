from unicode import alignLeft,Rune
proc PrintTitleByUnicode(title:string, len: Natural, padding = Rune(12288)):string =
    return unicode.alignLeft(title,len,padding)