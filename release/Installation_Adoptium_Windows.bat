# Script bash pour l'installation de eclipse adoptium pour exécution de TabGo
# Installe la version 21 si celle-ci n'est pas déja présente sur la machine

@echo off
cls

winget install EclipseAdoptium.Temurin.21.JDK
pause