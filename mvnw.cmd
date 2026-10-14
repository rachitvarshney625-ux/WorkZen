@echo off
setlocal
set "MAVEN_HOME=C:\Users\Rachit Varshney\AppData\Local\Programs\Maven\apache-maven-3.9.9"
if exist "%MAVEN_HOME%\bin\mvn.cmd" (
    "%MAVEN_HOME%\bin\mvn.cmd" %*
) else (
    mvn %*
)
