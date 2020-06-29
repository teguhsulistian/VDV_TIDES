# VDV_TIDES

-------------------------------------------------------------------------------
VDV_TIDES README FILE:
-------------------------------------------------------------------------------
Version: 1.0
-------------------------------------------------------------------------------

The copyright and licensing terms are contained in the file "LICENSE".
The Compatible for running program in MATLAB Version R2013 or above.
The Program Directory contain VDV_TIDES.m, README and LICENSE

-------------------------------------------------------------------------------
VDV_TIDES DESCRIPTION:
VDV_TIDES use for the validation, pre-processing and display of valeport tide data from
one file or many file input.
Beside that VDV_TIDES can provide t_tide input for advanced tidal analysis

-------------------------------------------------------------------------------
How to Use:
1. Copy VDV_TIDES.m file to the same directory of your valeport data
2. Open script on your MATLAB Software
3. Running the script
4. Please enter your location of tidal observation (ex Jakarta) and output file name in .xlsx 
   format on the command window (interactive input)
5. Select your folder (with GUI)
6. Wait program until finish

*note for MATLAB VERSION R2013 below you can use script directly, but for MATLAB VERSION R2013 Above
you must edit some script for datenum function at line 43 to 58, you can see remark on the script

-------------------------------------------------------------------------------
Output Of Program :
1. Plot_Your Location.jpeg (Figure of tidal observation data)
2. Location.xlsx (Observation Data datetime and depth)
3. Location_input_ttides.xlsx (Input Data for t_tide script, format datenum and depth)
4. Location_report.dat (Report of validation and pre_processing)


-------------------------------------------------------------------------------
Enjoy and hope that helps you .
