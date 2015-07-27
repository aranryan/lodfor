series{
  title = "y"
  file = "C:\Users\Aran\AppData\Local\Temp\RtmpGuKqhf/x13/data.dta"
  format = "datevalue"
  period = 4
}

transform{
  function = auto
  print = aictransform
}

outlier{

}

automdl{
  print = bestfivemdl
}

regression{
  variables = (const easter[8])
}

identify{
  diff = (0 1)
  sdiff = (0 1)
}

forecast{
  maxlead = 30
  save = fct
}

x11{
  appendfcst = yes
  save = (d10 d11 d12 d13 d16 e18)
}

estimate{
  save = (model estimates lkstats residuals)
}

spectrum{
  print = qs
}
