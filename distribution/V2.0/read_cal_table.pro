
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro READ_CAL_TABLE--------------------------------------------------
;----------date: 23 - 07 - 2004------------------------------------------------


      PRO READ_CAL_TABLE

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LOAD_OBS.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


;----------Start READ_CAL_TABLE------------------------------------------------

       cal_table = $
        DIALOG_PICKFILE(/READ,FILTER='*',GET_PATH=cal_table_path)

       If cal_table EQ '' Then Begin

        cal_message = 'No calibration table selected'
        Widget_control , current_cal_table , Set_value = cal_message
        Goto, r100
        
       Endif

       dump = STRING(5)

       Get_lun , file_unit

       Openr , file_unit , cal_table

       Readf , file_unit , dump
       Readf , file_unit , dump


;----------Check if this file is a calibration file----------------------------

       dump_id = STRPOS(dump,'Calibration Table :')

       If dump_id LT 0 Then Begin

        cal_message = 'Selected file is not a NCDRT V2.0 calibration table'
        Widget_control , current_cal_table , Set_value = cal_message
        Goto, r100
        
       Endif
      
       For i = 1,13 Do Begin & Readf, file_unit, dump & Endfor

 
;----------Determine the number of existing points in the file-----------------

       n_cal_points = 0L

       If EOF(file_unit) Then Goto, r4
 

  r2:  Readf , file_unit , dump
       n_cal_points = n_cal_points + 1
       If NOT EOF(file_unit) Then Goto, r2

       n_cal_points = ROUND(n_cal_points / 7)

       Close, file_unit
       Free_lun , file_unit


       calibration_factors = FLTARR(n_cal_points,16)
       calibration_factors_error = FLTARR(n_cal_points,16)
       calibration_file_base = STRARR(n_cal_points)
       calibration_object = STRARR(n_cal_points)
       calibration_time = DBLARR(n_cal_points)

       Openr , file_unit , cal_table

       For i = 1,15 Do Begin & Readf, file_unit, dump & Endfor

       For i = 0,n_cal_points-1 Do Begin

        cal_time_in = DBLARR(1)
        cal_object_in = STRARR(1)
        cal_file_base_in = STRARR(1)
        Readf, file_unit, Format = '(A)' , cal_object_in
        Readf, file_unit, Format = '(A)' , cal_file_base_in
        Readf, file_unit, Format = '(1x,D25.16)' , cal_time_in
        Readf, file_unit, Format = '(1x,4(F9.4,1x,F9.5,2x))' , $
         cal_ch1_in , cal_ch1_error_in , $
         cal_ch2_in , cal_ch2_error_in , $
         cal_ch3_in , cal_ch3_error_in , $
         cal_ch4_in , cal_ch4_error_in

        Readf, file_unit, Format = '(1x,4(F9.4,1x,F9.5,2x))' , $
         cal_ch5_in , cal_ch5_error_in , $
         cal_ch6_in , cal_ch6_error_in , $
         cal_ch7_in , cal_ch7_error_in , $
         cal_ch8_in , cal_ch8_error_in

        Readf, file_unit, Format = '(1x,4(F9.4,1x,F9.5,2x))' , $
         cal_ch9_in , cal_ch9_error_in , $
         cal_ch10_in , cal_ch10_error_in , $
         cal_ch11_in , cal_ch11_error_in , $
         cal_ch12_in , cal_ch12_error_in

        Readf, file_unit, Format = '(1x,3(F9.4,1x,F9.5,2x))' , $
         cal_ch13_in , cal_ch13_error_in , $
         cal_ch14_in , cal_ch14_error_in , $
         cal_ch15_in , cal_ch15_error_in


         calibration_file_base(i) = cal_file_base_in
         calibration_object(i) = cal_object_in
         calibration_time(i) = cal_time_in

         calibration_factors(i,0) = cal_ch1_in
         calibration_factors(i,1) = cal_ch2_in
         calibration_factors(i,2) = cal_ch3_in
         calibration_factors(i,3) = cal_ch4_in
         calibration_factors(i,4) = cal_ch5_in
         calibration_factors(i,5) = cal_ch6_in
         calibration_factors(i,6) = cal_ch7_in
         calibration_factors(i,7) = cal_ch8_in
         calibration_factors(i,8) = cal_ch9_in
         calibration_factors(i,9) = cal_ch10_in
         calibration_factors(i,10) = cal_ch11_in
         calibration_factors(i,11) = cal_ch12_in
         calibration_factors(i,12) = cal_ch13_in
         calibration_factors(i,13) = cal_ch14_in
         calibration_factors(i,14) = cal_ch15_in

         calibration_factors_error(i,0) = cal_ch1_error_in
         calibration_factors_error(i,1) = cal_ch2_error_in
         calibration_factors_error(i,2) = cal_ch3_error_in
         calibration_factors_error(i,3) = cal_ch4_error_in
         calibration_factors_error(i,4) = cal_ch5_error_in
         calibration_factors_error(i,5) = cal_ch6_error_in
         calibration_factors_error(i,6) = cal_ch7_error_in
         calibration_factors_error(i,7) = cal_ch8_error_in
         calibration_factors_error(i,8) = cal_ch9_error_in
         calibration_factors_error(i,9) = cal_ch10_error_in
         calibration_factors_error(i,10) = cal_ch11_error_in
         calibration_factors_error(i,11) = cal_ch12_error_in
         calibration_factors_error(i,12) = cal_ch13_error_in
         calibration_factors_error(i,13) = cal_ch14_error_in
         calibration_factors_error(i,14) = cal_ch15_error_in

       Endfor

       Close , file_unit

       Free_lun , file_unit


;----------Write information on the current table to the information widget----

  r4:  If n_cal_points GT 0 Then Begin

        current_table = 'Current calibration table with ' + $
        STRCOMPRESS(STRING(n_cal_points)) + ' data points is '

        spanning_dates = 'Spanning reduced julian dates between : ' + $
         STRCOMPRESS(STRING(calibration_time(0))) + ' and ' + $
         STRCOMPRESS(STRING(calibration_time(n_cal_points-1)))

       Endif Else Begin

        n_cal_points = 0L

        current_table = 'Current calibration table with ' + $
        STRCOMPRESS(STRING(n_cal_points)) + ' data points is '

        spanning_dates = 'NO CALIBRATION DATA POINTS'

       Endelse

       cal_message = [current_table , cal_table , $
        spanning_dates]
       Widget_control, current_cal_table , Set_value = cal_message


 r100:
      End

;----------Pro READ_CAL_TABLE--------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------

