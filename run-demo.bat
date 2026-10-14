@echo off
title Employee Time Management System - Instant Demo Mode
echo ===================================================================
echo Starting Employee Time Management System (Demo Profile with H2)
echo No MySQL installation required!
echo ===================================================================
call mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=demo
pause
