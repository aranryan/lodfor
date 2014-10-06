series{
  title = "temp_seasonal_a"
  file = "C:\Users\Aran\AppData\Local\Temp\RtmpYvifJh/x13/data.dta"
  format = "datevalue"
  period = 12
}

transform{
  function = log
}

outlier{

}

automdl{
  print = bestfivemdl
}

regression{
  variables = (const easter[8] thank[5])
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
