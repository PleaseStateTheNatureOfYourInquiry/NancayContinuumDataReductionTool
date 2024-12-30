
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro READ_RES--------------------------------------------------------
;----------date: 17 - 08 - 2004------------------------------------------------


      PRO READ_RES , check

;----------The common blocks used in this procedure----------------------------

       @CHANNEL.CB
       @CUT_SETTING.CB
       @SKY_CUT_SETTING.CB
       @LOAD_OBS.CB


;----------Start READ_RES------------------------------------------------------

       Get_lun , res_file
       
       dump = STRING(4)
       dump1 = FLTARR(1)
       cal_table_current_data = STRARR(1)
       sky_file_previous = STRARR(1)

       Openr , res_file , check

       For i = 1,16 Do Begin & Readf , res_file , dump & Endfor
       Readf , res_file , Format = '(36x,I3,2x,I3)' , $
        t_offset_low , t_offset_high

       For i = 1,3 Do Begin & Readf , res_file , dump & Endfor

       Readf , res_file , Format = '(12x,A)' , cal_table_current_data
       cal_table_current_data = STRCOMPRESS(cal_table_current_data,/remove_all)

       For i = 1,17 Do Begin & Readf , res_file , dump & Endfor

;----------Afterall, I considered it better not to read the calibration factors
;----------from the .res_cal files---------------------------------------------

;       For i = 1,2 Do Begin & Readf , res_file , dump & Endfor

;       For i = 0,11 Do Begin

;        Readf , res_file , $
;         Format = '(12x,2x,2(E10.3,2x),2x,2(F7.4,4x,F7.5))', $
;         dump1 , dump1 , apply_factors_in , apply_factors_error_in

;         apply_factors(i) = apply_factors_in
;         apply_factors_error(i) = apply_factors_error_in

;       Endfor


       For i = 1,2 Do Begin & Readf , res_file , dump & Endfor

       Readf , res_file , Format = '(34x,I3,2x,I3)' , t_peak_low , t_peak_high

       For i = 1,6 Do Begin & Readf , res_file , dump & Endfor


       Readf , res_file , Format = '(14x,A)' , sky_file_previous

       If sky_file_previous(0) EQ 'nothing subtracted' OR $
          sky_file_previous(0) EQ '' Then Begin

        For i = 1,2 Do Begin & Readf , res_file , dump & Endfor

       Endif Else Begin

        Readf , res_file , Format = '(48x,I3,2x,I3,2x,I3)' , $
         sky_t_offset_low_res , sky_t_offset_high_res , sky_shift
        Readf , res_file , dump 

       Endelse


       Readf , res_file , Format = '(11x,A)' , read_comment

       For i = 1,6 Do Begin & Readf , res_file , dump & Endfor


       channel_include = ''
       For i = 1,8 Do Begin

       Readf , res_file , ch , value

        If value LT 0 Then Begin

         channel_include = channel_include + ' 0'

        Endif Else Begin

         channel_include = channel_include + ' 1'

        Endelse
      
       Endfor

       Close , res_file
       Free_lun , res_file

      End


;----------Pro READ_RES--------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------


