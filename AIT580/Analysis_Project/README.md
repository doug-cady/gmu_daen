# AIT 580 - Analysis Project

Welcome to my git repo for the GMU DAEN masters program for the AIT 580 'Big Data' course.

Here you can find all of my code and input datasets and graphics, along with the report itself.

Directory structure:
- graphics - contains folders for each question answered in the report and its associated graphic(s) - plots and charts
- guide - analysis project guide, explains what to do for this project
- input - contains all data got from API calls through OpenDota API; individual files in _dota2_exp_get_ are aggregated into a single file using the Python program _compile_api.py_
- output - contains all clean, prepared data for use in R analyses and visualizations; data was parsed from json files using the Python program _extr_player_data.py_
- python - all Python code resides here; Python was used to collect (make API calls) data and aggregate to a single json file, then parsed for needed information and finally output as a TSV file
- R - all R code is here; R was used to create all analyses and visualizations
- report - written project report and submitted pdf file

Doug

[GMU DAEN Masters git repo]
