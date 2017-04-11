#!/bin/bash

Color_Text()
{
  echo -e " \e[0;$1m$2\e[0m"
}

Echo_Red()
{
    echo $(Color_Text "31" "$1")
}

Echo_Green()
{
    echo $(Color_Text "32" "$1")
}

Echo_Yellow()
{
    echo $(Color_Text "33" "$1")
}

Echo_Blue()
{
    echo $(Color_Text "34" "$1")
}

Echo_Carmine()
{
    echo $(Color_Text "35" "$1")
}

Echo_Cyan()
{
    echo $(Color_Text "36" "$1")
}





