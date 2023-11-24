***************************************************************************
* Cross-border Effects: Tracing U.S. Fentanyl's Effect on Rural Colombian Income

* This version: November 24, 2023

* Authors: Biasiucci, Giovanni - Geraldo-Correa, Gabriel - Herrera-Sarmiento, Juan Felipe - Hofer, Silvan Michael & Olivetta Mariasole

***************************************************************************
* This file sets the master file
***************************************************************************
clear all
cls
* Install packages
ssc install reghdfe
ssc install coefplot
ssc install estout


* Define paths
global data "C:\Users\juanf\OneDrive\Documentos\GitHub\2023_FSS_Group_Project_Colombia\Data_processing"

global data_clean "C:\Users\juanf\OneDrive\Documentos\GitHub\2023_FSS_Group_Project_Colombia\data_clean"

global tabfolder "C:\Users\juanf\OneDrive\Documentos\GitHub\2023_FSS_Group_Project_Colombia\Tables"

global figfolder "C:\Users\juanf\OneDrive\Documentos\GitHub\2023_FSS_Group_Project_Colombia\Figures"

global folder "C:\Users\juanf\OneDrive\Documentos\GitHub\2023_FSS_Group_Project_Colombia\"

*Run files

* 1. Data processing file
do "$folder/1_Data_processing"
* 2. Analysis file
do "$folder/2_Analysis"