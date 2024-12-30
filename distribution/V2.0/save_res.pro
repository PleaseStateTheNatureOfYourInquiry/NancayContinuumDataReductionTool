
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro SAVE_RES--------------------------------------------------------
;----------date: 23 - 07 - 2004------------------------------------------------


      PRO SAVE_RES

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @LOAD_OBS.CB
       @LONGITUDE.CB
       @WIDGET_IDS.CB


;----------Start SAVE_OBS------------------------------------------------------

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


       If (ch_address EQ 0) AND (calibration_applied EQ 0) Then $
        result_file = scan_number + '.res'

       If (ch_address EQ 8) AND (calibration_applied EQ 0) Then $
        result_file = scan_number + '.res_av'

       If (ch_address EQ 0) AND (calibration_applied EQ 1) Then $
        result_file = scan_number + '.res_cal'

       If (ch_address EQ 8) AND (calibration_applied EQ 1) Then $
        result_file = scan_number + '.res_av_cal'


       Get_lun , file_unit

       Openw , file_unit , result_file

       Printf , file_unit , ' '
       Printf , file_unit , ' File : ' + result_file
       Printf , file_unit , ' '
       Printf , file_unit , ' Nancay Continuum Data Reduction Tool V2.0 (July 2004)'
       Printf , file_unit , ' '
       Printf , file_unit , ' Object : ' + object
       Printf , file_unit , ' '
       Printf , file_unit , Format = '(" Central Frequency : ",F7.2," MHz ")' $
        , central_freq

       Printf , file_unit , ' '
       Printf , file_unit , $
        Format='(" Start time : ",I2,1x,I2,1x,I4,"  at ",I2,"h ",I2,"m ",I2,"s  UT")' , $
        time_start(2) , time_start(1) , time_start(0) , $
        time_start(3) , time_start(4) , time_start(5)
       Printf , file_unit , $
        Format='(" End time   : ",I2,1x,I2,1x,I4,"  at ",I2,"h ",I2,"m ",I2,"s  UT")' , $
        time_end(2) , time_end(1) , time_end(0) , $
        time_end(3) , time_end(4) , time_end(5)

       Printf , file_unit , Format = '(" Mid time (julian date) : ",D25.16)' , $ 
        julian_obs

       Printf , file_unit , ' '

       Printf , file_unit , ' Drifts: first 3 points (noise tube) not considered'
       Printf , file_unit , ' Number of points without noise tube : ' , n_points-3
       Printf , file_unit , ' '
       Printf , file_unit , $
        Format = '(" Offset cutting (IDL coordinates) ",2x,I3,2x,I3)' , $
        t_offset_low , t_offset_high 
       Printf , file_unit , ' '


       Printf , file_unit , ' Offset linear fitting y_offset = a * t + b'
       Printf , file_unit , ' '

       If calibration_applied EQ 1 Then Begin
 
        Printf , file_unit , ' Cal. file : ' , cal_table

       Endif Else Begin

        Printf , file_unit , ' Cal. file : No calibration applied to this data'

       Endelse
       Printf , file_unit , ' '

       Printf , file_unit , '                    a           b       c.factor  d_c.factor '


       If ch_address EQ 0 Then Begin

        For i = 0,n_channel-1 Do Begin

         j = i + ch_address

         If channels(i) EQ 1 Then Begin

          Printf , file_unit , $
           Format = '(A12,2x,2(E10.3,2x),2x,2(F7.4,4x,F7.5))', $
           channel_print(j) , offset_coefs(j,1) , offset_coefs(j,0) , $
           apply_factors(j) , apply_factors_error(j)

         Endif Else Begin

          Printf , file_unit , $
           Format = '(A12,2x,2(E10.3,2x),2x,2(F7.4,4x,F7.5))', $
           channel_print(j) , offset_coefs(j,1) , offset_coefs(j,0) , $
            1.0 , 0.0
        
         Endelse 
 
        Endfor

        For j = 8,14 Do Begin

          Printf , file_unit , $
           Format = '(A12,2x,2(E10.3,2x),2x,2(F7.4,4x,F7.5))', $
           channel_print(j) , 0.0 , 0.0 , 1.0 , 0.0
        
        Endfor


       Endif Else Begin


        For j = 0,7 Do Begin

          Printf , file_unit , $
           Format = '(A12,2x,2(E10.3,2x),2x,2(F7.4,4x,F7.5))', $
           channel_print(j) , 0.0 , 0.0 , 1.0 , 0.0
        
        Endfor

        For i = 0,n_channel-1 Do Begin

         j = i + ch_address

         If channels(i) EQ 1 Then Begin

          Printf , file_unit , $
           Format = '(A12,2x,2(E10.3,2x),2x,2(F7.4,4x,F7.5))', $
           channel_print(j) , offset_coefs(j,1) , offset_coefs(j,0) , $
           apply_factors(j) , apply_factors_error(j)

         Endif Else Begin

          Printf , file_unit , $
           Format = '(A12,2x,2(E10.3,2x),2x,2(F7.4,4x,F7.5))', $
           channel_print(j) , offset_coefs(j,1) , offset_coefs(j,0) , $
            1.0 , 0.0
        
         Endelse 
 
        Endfor

       Endelse
        
       Printf , file_unit , ' '
       Printf , file_unit , ' '
       Printf , file_unit , $
        Format = '(" Peak cutting (IDL coordinates) ",2x,I3,2x,I3)' , $
        t_peak_low , t_peak_high 
       Printf , file_unit , ' '
       Printf , file_unit , ' Fit to the peaks is Gaussian:'
       Printf , file_unit , '  a = height, t0 = center, w = width and c = constant level'
       Printf , file_unit , '  Peak flux = a + c'

       Printf , file_unit , ' ' 
       Printf , file_unit , ' ' 
       Printf , file_unit , ' Subtracted : '
       Printf , file_unit , ' ' 
       Printf , file_unit , ' ' 

       Widget_control , comment_string , Get_value = comment
       Printf, file_unit , ' Comment : ' + comment

       i_longitude = WHERE(scan_number EQ scan_list, count_longitude)

       If planet_longitude EQ 0 Then Begin

        Printf , file_unit , ' ' 


       Endif Else Begin

        If count_longitude EQ 0 Then Begin

         Printf , file_unit , ' '
         message = ['observation not in planet.longitude file.']
         Widget_control , process_info , Set_value = message

        Endif Else Begin

         Printf , file_unit , $
          Format='(" (CM,sub_lat,D) : (",F7.2,",",F6.2,",",F8.5,")")' , $ 
          scan_longitude(i_longitude) , scan_sublatitude(i_longitude) , $
          scan_distance(i_longitude)
          message = ['observation in planet.longitude file.',$
                     'information written to result file.']
          Widget_control , process_info , Set_value = message

        Endelse
       
       Endelse

       Printf , file_unit , ' ' 


       Printf , file_unit , ' ch.    Flux   Noise    Noise    Noise       a        t0         w        c '
       Printf , file_unit , '               (peak)  (offset) (total)'
       Printf , file_unit , '        (Jy)    (Jy)     (Jy)     (Jy)'

       Printf , file_unit , 'C_END'


       For i = 0,n_channel-1 Do Begin

        j = i + ch_address

        If (channels(i) EQ 1) AND (peak_flux(j) GE 0) AND $
         (peak_flux(j) LT 999.99999) Then Begin

         Printf , file_unit , $
          Format = '(1x,I1,1x,F9.5,1x,3(F8.5,1x),4(E10.3))' , i+1 , $
          peak_flux(j) , noise_level_peak(j) , noise_level_offset(j) , $
          noise_level_total(j) , gauss_parm(j,0) , gauss_parm(j,1) , $
          gauss_parm(j,2) , gauss_parm(j,3)

        Endif Else Begin

         Printf , file_unit , Format = '(1x,I1,2x,4(F8.5,1x),4(E10.3))' ,$
          i+1 , $
          -1.0 , -1.0 , -1.0 , -1.0 , -1.0 , -1.0 , -1.0 , -1.0

        Endelse

       Endfor

       Close , file_unit

       Free_lun , file_unit


      End

;----------Pro SAVE_OBS--------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------

 