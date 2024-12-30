
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro DELETE_FROM_CAL_TABLE-------------------------------------------
;----------date: 26 - 07 - 2004------------------------------------------------


      PRO DELETE_FROM_CAL_TABLE

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @LOAD_OBS.CB
       @WIDGET_IDS_CAL.CB


;----------Start DELETE_FROM_CAL_TABLE-----------------------------------------

;----------The a,b,c coefficients are from Table 5 in Ott et al. 1994----------
;----------(A&A 284 p.331-339). No coefficients for 4C55.16--------------------


;----------If there is no calibration table, than skip this routine------------

       If cal_table EQ '' Then Begin

        message = ['No calibration table was loaded or created.' , $
                   'No action was taken.']
        Widget_control , cal_process_info , Set_value = message
        Goto, r100

       Endif


;---------Check if the data already exists for this calibrator in the current--
;---------calibration table----------------------------------------------------

       If n_cal_points GT 0 Then Begin

        check = WHERE(julian_obs EQ calibration_time,count)

        If count LE 0 Then Begin

         message = ['This calibrator is not present in calibration table.' , $
                    'Nothing was deleted from calibration table.']
         Widget_control , cal_process_info , Set_value = message
         Goto, r100

        Endif

       Endif Else Begin

        message = ['This calibrator is not present in calibration table.' , $
                   'Nothing was deleted from calibration table.']
        Widget_control , cal_process_info , Set_value = message
        Goto, r100

       Endelse


       n_cal_points = n_cal_points - 1


;----------USER: RM and CP commands--------------------------------------------

       cal_table_temp = cal_table + 'temp'
       cal_table_temp_cp = '/bin/cp ' + cal_table + ' ' + cal_table_temp
       cal_table_temp_rm = '/bin/rm ' + cal_table_temp

       Spawn , cal_table_temp_cp

       Get_lun , file_write
       Openw , file_write , cal_table

       Get_lun , file_read
       Openr , file_read , cal_table_temp

       dump = STRARR(1)

       For i = 1,15 Do Begin 

        Readf , file_read , dump
        Printf , file_write , dump

       Endfor

       Close , file_read
       Free_lun , file_read

;       Spawn , cal_table_temp_rm


       If n_cal_points EQ 0 Then Begin

        current_table = 'Current calibration table with ' + $
         STRCOMPRESS(STRING(n_cal_points)) + ' data points is '

        cal_message = [current_table , cal_table]
        Widget_control, current_cal_table , Set_value = cal_message

        Wdelete , 4
        Close , file_write
        Free_lun , file_write

        Goto, r100

       Endif

       cp_data = WHERE(julian_obs NE calibration_time,count)

       factors_dump = calibration_factors
       factors_error_dump = calibration_factors_error
       file_base_dump = calibration_file_base
       object_dump = calibration_object
       time_dump = calibration_time

       calibration_factors = FLTARR(n_cal_points,16)
       calibration_factors_error = FLTARR(n_cal_points,16)
       calibration_file_base = STRARR(n_cal_points)
       calibration_object = STRARR(n_cal_points)
       calibration_time = DBLARR(n_cal_points)

       calibration_factors(0:n_cal_points-1,*) = factors_dump(cp_data,*)
       calibration_factors_error(0:n_cal_points-1,*) = $
        factors_error_dump(cp_data,*)
       calibration_file_base(0:n_cal_points-1) = file_base_dump(cp_data)
       calibration_object(0:n_cal_points-1) = object_dump(cp_data)
       calibration_time(0:n_cal_points-1) = time_dump(cp_data)
       

       For i = 0,n_cal_points-1 Do Begin 

        Printf, file_write, Format = '(A20)' , calibration_object(i)
        Printf, file_write, calibration_file_base(i)
        Printf, file_write, Format = '(1x,D25.16)' , calibration_time(i)
        Printf, file_write, Format = '(1x,4(F7.4,1x,F7.5,2x))' , $
         calibration_factors(i,0) , calibration_factors_error(i,0) , $
         calibration_factors(i,1) , calibration_factors_error(i,1) , $
         calibration_factors(i,2) , calibration_factors_error(i,2) , $
         calibration_factors(i,3) , calibration_factors_error(i,3)

        Printf, file_write, Format = '(1x,4(F7.4,1x,F7.5,2x))' , $
         calibration_factors(i,4) , calibration_factors_error(i,4) , $
         calibration_factors(i,5) , calibration_factors_error(i,5) , $
         calibration_factors(i,6) , calibration_factors_error(i,6) , $
         calibration_factors(i,7) , calibration_factors_error(i,7)

        Printf, file_write, Format = '(1x,4(F7.4,1x,F7.5,2x))' , $
         calibration_factors(i,8) , calibration_factors_error(i,8) , $
         calibration_factors(i,9) , calibration_factors_error(i,9) , $
         calibration_factors(i,10) , calibration_factors_error(i,10) , $
         calibration_factors(i,11) , calibration_factors_error(i,11)

        Printf, file_write, Format = '(1x,3(F9.4,1x,F9.5,2x))' , $
         calibration_factors(i,12) , calibration_factors_error(i,12) , $
         calibration_factors(i,13) , calibration_factors_error(i,13) , $
         calibration_factors(i,14) , calibration_factors_error(i,14)

       Endfor
     
       Close , file_write
       Free_lun , file_write


;----------Write information on the current table to the information widget----

       current_table = 'Current calibration table with ' + $
        STRCOMPRESS(STRING(n_cal_points)) + ' data points is '

       spanning_dates = 'Spanning reduced julian dates between : ' + $
        STRCOMPRESS(STRING(calibration_time(0))) + ' and ' + $
        STRCOMPRESS(STRING(calibration_time(n_cal_points-1)))

       cal_message = [current_table , cal_table , $
        spanning_dates]
       Widget_control, current_cal_table , Set_value = cal_message

       PLOT_CALIBRATION_DATA


 r100: 
      End

;----------Pro DELETE_FROM_CAL_TABLE-------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------
