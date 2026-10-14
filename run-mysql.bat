@echo off
title Employee Time Management System - MySQL Production Mode
echo ===================================================================
echo Starting Employee Time Management System with MySQL 8.x
echo Ensure MySQL Server is running on port 3306!
echo ===================================================================
call mvnw.cmd spring-boot:run
pause
