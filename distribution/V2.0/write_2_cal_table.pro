
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro WRITE_2_CAL_TABLE-----------------------------------------------
;----------date: 23 - 07 - 2004------------------------------------------------


      PRO WRITE_2_CAL_TABLE

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @LOAD_OBS.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


;----------Start WRITE_2_CAL_TABLE---------------------------------------------

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

        If count GT 0 Then Begin

         message = ['This calibrator is already present.' , $
                    'Nothing was written to calibration table.']
         Widget_control , cal_process_info , Set_value = message
         Goto, r100

        Endif

       Endif


       know_calibrator = 0

       If central_freq EQ 1413.5 Then Begin

        freq1 = 1410 
        freq_c = 1413
        freq2 = 1416

       Endif


       If central_freq EQ 2690 Then Begin

        freq1 = 2689
        freq_c = 2692
        freq2 = 2695

       Endif


       calibrator = '3C123 0433+29       '
       If object EQ calibrator Then Begin

        know_calibrator = 1
        message = '3C123 is a known calibrator'
        Widget_control , cal_process_info , Set_value = message

        a = 2.525 & b = 0.246 & c = -0.1638

        cal_central_freq = radio_flux(freq_c,a,b,c)
        cal_central_freq_low = radio_flux(freq1,a,b,c)
        cal_central_freq_up = radio_flux(freq2,a,b,c)

       Endif

      
       calibrator = '3C161 0624-05       '
       If object EQ calibrator Then Begin

        know_calibrator = 1
        message = '3C161 is a known calibrator'
        Widget_control , cal_process_info , Set_value = message

        a = 1.250 & b = 0.726 & c = -0.2286

        cal_central_freq = radio_flux(freq_c,a,b,c)
        cal_central_freq_low = radio_flux(freq1,a,b,c)
        cal_central_freq_up = radio_flux(freq2,a,b,c)

       Endif

 
       calibrator = '3C295 1409+52       '
       If object EQ calibrator Then Begin

        know_calibrator = 1
        message = '3C295 is a known calibrator'
        Widget_control , cal_process_info , Set_value = message

        a = 1.490 & b = 0.756 & c = -0.2545

        cal_central_freq = radio_flux(freq_c,a,b,c)
        cal_central_freq_low = radio_flux(freq1,a,b,c)
        cal_central_freq_up = radio_flux(freq2,a,b,c)

       Endif

                   
       calibrator = '4C55.16 0831+55     ' 
       If object EQ calibrator Then Begin

        know_calibrator = 1
        message = '4C55.16 is a known calibrator'
        Widget_control , cal_process_info , Set_value = message


;----------Average of the calibration applied to ------------------------------
;----------map1/calib/4C55.16/ 053285 and 053477 with map1/calib/map1_cal.table
;----------map2/calib/4C55.16/ 053286 and 053478 with map2/calib/map2_cal.table
;----------taking into account the 3 channels (1-4), (5-8) and (1-8) in each---
;----------case (total of 12 values).------------------------------------------

        If central_freq EQ 1413.5 Then Begin

         cal_central_freq = 8.81
         cal_central_freq_low = 8.81
         cal_central_freq_up = 8.81

        Endif


;----------Average of the calibration applied to ------------------------------
;----------map35/calib/4C55.16/ 053287 and 053479 with map35/calib/map35_cal.table
;----------map46/calib/4C55.16/ 053288 and 053480 with map46/calib/map46_cal.table
;----------taking into account the 3 channels (1-4), (5-8) and (1-8) in each---
;----------case (total of 12 values).------------------------------------------

        If central_freq EQ 2690 Then Begin

         cal_central_freq = 8.54
         cal_central_freq_low = 8.54
         cal_central_freq_up = 8.54

        Endif

       Endif



       If know_calibrator EQ 0 Then Begin

        message = [object + ' is not a known calibrator' , $
                   'Nothing is written to the calibration table']
        Widget_control , cal_process_info , Set_value = message
        Goto, r100

       Endif
        

       If ch_address EQ 0 Then Begin

        ch_address = 8 & n_channel = 7
        APPLY_LIN_CUT , 1
        ch_address = 0 & n_channel = 8


       Endif Else Begin

        message = ['In averaging mode. Please go to All Channel mode' , $
                   'and select usable channels. Nothing was writting.']
        Widget_control , cal_process_info , Set_value = message
        Goto, r100

       Endelse


       cal_factor = FLTARR(16)
       cal_factor_error = FLTARR(16)

       cal_factor(0) = cal_central_freq_low / peak_flux(0)
       cal_factor(1) = cal_central_freq_low / peak_flux(1)
       cal_factor(2) = cal_central_freq_up / peak_flux(2)
       cal_factor(3) = cal_central_freq_up / peak_flux(3)
       cal_factor(4) = cal_central_freq_low / peak_flux(4)
       cal_factor(5) = cal_central_freq_low / peak_flux(5)
       cal_factor(6) = cal_central_freq_up / peak_flux(6)
       cal_factor(7) = cal_central_freq_up / peak_flux(7)

       cal_factor(8) = cal_central_freq / peak_flux(8)
       cal_factor(9) = cal_central_freq / peak_flux(9)
       cal_factor(10) = cal_central_freq / peak_flux(10)
       cal_factor(11) = cal_central_freq / peak_flux(11)
       cal_factor(12) = cal_central_freq / peak_flux(12)
       cal_factor(13) = cal_central_freq / peak_flux(13)
       cal_factor(14) = cal_central_freq / peak_flux(14)

       For i = 0,14 Do Begin

        cal_factor_error(i) = cal_factor(i) * $
        noise_level_total(i) / peak_flux(i)

       Endfor


;----------USER: AVERAGING-----------------------------------------------------
;----------In this part of the routine only the selected channels from the-----
;----------selected channel string  channel_select_string are written to the---
;----------file. The calibration factor of an average channels that includes a-
;----------non selected channel is set to 1.000--------------------------------
;----------If the averaging channels are changed in  load_obs.pro  then this---
;----------must also be adapted.-----------------------------------------------

       Widget_control , channel_select , Get_value = channel_select_string
       READS , channel_select_string, $
        ch1 , ch2 , ch3 , ch4 , ch5 , ch6 , ch7 , ch8

       channels = fltarr(8)
       channels(0) = ch1
       channels(1) = ch2
       channels(2) = ch3
       channels(3) = ch4
       channels(4) = ch5
       channels(5) = ch6
       channels(6) = ch7
       channels(7) = ch8

       For i = 0,7 Do Begin

        If channels(i) EQ 0 Then Begin

         cal_factor(i) = -1.
         cal_factor_error(i) = 0.

         cal_factor(14) = -1.0
         cal_factor_error(14) = 0.

         If i EQ 0 OR i EQ 2 Then Begin

          cal_factor(8) = -1.
          cal_factor_error(8) = 0.

         Endif

         If i EQ 1 OR i EQ 3 Then Begin

          cal_factor(9) = -1.
          cal_factor_error(9) = 0.

         Endif

         If i EQ 4 OR i EQ 6 Then Begin

          cal_factor(10) = -1.
          cal_factor_error(10) = 0.

         Endif

         If i EQ 5 OR i EQ 7 Then Begin

          cal_factor(11) = -1.
          cal_factor_error(11) = 0.

         Endif

         If (i EQ 0 OR i EQ 1 OR i EQ 2 OR i EQ 3) Then Begin

          cal_factor(12) = -1.
          cal_factor_error(12) = 0.

         Endif

         If (i EQ 4 OR i EQ 5 OR i EQ 6 OR i EQ 7) Then Begin

          cal_factor(13) = -1.
          cal_factor_error(13) = 0.

         Endif


        Endif

       Endfor


;----------Copy the current set of factor temporarily in other parameters------

       If n_cal_points GT 0 Then Begin

        factors_dump = calibration_factors
        factors_error_dump = calibration_factors_error
        file_base_dump = calibration_file_base
        object_dump = calibration_object
        time_dump = calibration_time

       Endif


;----------Increase the number of calibration points by one--------------------

       n_cal_points = n_cal_points + 1


;----------Redefine the calibration parameters with the new size---------------

       calibration_factors = FLTARR(n_cal_points,16)
       calibration_factors_error = FLTARR(n_cal_points,16)
       calibration_file_base = STRARR(n_cal_points)
       calibration_object = STRARR(n_cal_points)
       calibration_time = DBLARR(n_cal_points)


;----------Copy the previous calibration data to the new parameters and add the
;----------new calibration parameter-------------------------------------------

       If n_cal_points GT 1 Then Begin

        calibration_factors(0:n_cal_points-2,*) = factors_dump
        calibration_factors_error(0:n_cal_points-2,*) = factors_error_dump
        calibration_file_base(0:n_cal_points-2) = file_base_dump
        calibration_object(0:n_cal_points-2) = object_dump
        calibration_time(0:n_cal_points-2) = time_dump

       Endif

       calibration_factors(n_cal_points-1,*) = cal_factor
       calibration_factors_error(n_cal_points-1,*) = cal_factor_error
       calibration_file_base(n_cal_points-1) = file_base
       calibration_object(n_cal_points-1) = object
       calibration_time(n_cal_points-1) = julian_obs

       time_sort = SORT(calibration_time)

       calibration_file_base = calibration_file_base(time_sort)
       calibration_time = calibration_time(time_sort)
       calibration_object = calibration_object(time_sort)


       For i = 0,14 Do Begin

        calibration_factors(*,i) = calibration_factors(time_sort,i)
        calibration_factors_error(*,i) = calibration_factors_error(time_sort,i)

       Endfor


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

       Spawn , cal_table_temp_rm
       

       For i = 0,n_cal_points-1 Do Begin 

        Printf, file_write, Format = '(A20)' , calibration_object(i)
        Printf, file_write, calibration_file_base(i)
        Printf, file_write, Format = '(1x,D25.16)' , calibration_time(i)
        Printf, file_write, Format = '(1x,4(F9.4,1x,F9.5,2x))' , $
         calibration_factors(i,0) , calibration_factors_error(i,0) , $
         calibration_factors(i,1) , calibration_factors_error(i,1) , $
         calibration_factors(i,2) , calibration_factors_error(i,2) , $
         calibration_factors(i,3) , calibration_factors_error(i,3)

        Printf, file_write, Format = '(1x,4(F9.4,1x,F9.5,2x))' , $
         calibration_factors(i,4) , calibration_factors_error(i,4) , $
         calibration_factors(i,5) , calibration_factors_error(i,5) , $
         calibration_factors(i,6) , calibration_factors_error(i,6) , $
         calibration_factors(i,7) , calibration_factors_error(i,7)

        Printf, file_write, Format = '(1x,4(F9.4,1x,F9.5,2x))' , $
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

;----------Pro WRITE_2_CAL_TABLE-----------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------
