
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro APPLY_LIN_CUT---------------------------------------------------
;----------date: 23 - 07 - 2004------------------------------------------------


      PRO APPLY_LIN_CUT , silence

;----------The common blocks used in this procedure----------------------------

       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @LOAD_OBS.CB
       @SKY_SUBTRACT.CB
       @SKY_CUT_SETTING.CB
       @WIDGET_IDS.CB


;----------Start APPLY_LIN_CUT-------------------------------------------------

;----------If the  silence  parameter is set to zero, all the parameters will--
;----------be defined anew. If it is set to 1, the parameters will not be reset
;----------This feature is used in the calibration routine write_2_cal_table,--
;----------where all 15 channels need to be calculated (channels 1-8 and the 7-
;----------averaging channels) to write to the table. In this case, the plots--
;----------and results widgets are not renewed---------------------------------


       x_object_index = WHERE((x_drift GE t_peak_low) AND $
                              (x_drift LE t_peak_high),count_object)

       x_object = x_drift(x_object_index)


       If silence EQ 0 Then Begin

        y_peak_fit = FLTARR(16,count_object)

        gauss_parm = fltarr(16,4)
        noise_level_offset = FLTARR(16)
        noise_level_peak = FLTARR(16)
        noise_level_total = FLTARR(16)
        peak_flux = FLTARR(16)

       Endif

       channel_info = STRARR(16)
       guess = fltarr(4)

       Wset , 2

       !p.multi = [0,2,4] 

       For i = 0,n_channel-1 Do Begin

        y_drift = channel_data(i+ch_address,*)

        lin_coef = REGRESS(x_drift(x_drift_offset),y_drift(x_drift_offset),$
                           const=lin_const)
        offset_coefs(i+ch_address,0) = lin_const(0)
        offset_coefs(i+ch_address,1) = lin_coef(0)
        offset_coefs(i+ch_address,2) = 0.

        y_drift_offset = lin_coef(0) * x_drift + lin_const(0)

        y_drift_corrected_i = y_drift - y_drift_offset

        If sky_subtract_apply EQ 1 Then $
         y_drift_corrected_i = y_drift_corrected_i - $
          sky_drift_corrected(i+ch_address,*)

        y_object = y_drift_corrected_i(x_object_index)


        guess(0) = MAX(y_object)
        guess(1) = (t_peak_high + t_peak_low) / 2
        guess(2) = (t_peak_high - t_peak_low) / 2
        guess(3) = 0.

        y_peak_fit_i = $
         GAUSSFIT(x_object,y_object,a,estimates=guess,nterms=4)

        gauss_parm(i+ch_address,0) = a(0)
        gauss_parm(i+ch_address,1) = a(1)
        gauss_parm(i+ch_address,2) = a(2)
        gauss_parm(i+ch_address,3) = a(3)

        peak_flux(i+ch_address) = a(0) + a(3)


;----------The Noise level estimates-------------------------------------------

        noise_dump = MOMENT(y_drift_corrected_i(x_drift_offset))
        noise_level_offset(i+ch_address) = SQRT(noise_dump(1))

        noise_dump = MOMENT((y_object - y_peak_fit_i))
        noise_level_peak(i+ch_address) = SQRT(noise_dump(1))

        n_peak = SIZE(x_object_index)
        n_peak = n_peak(1)
        n_offset = SIZE(x_drift_offset)
        n_offset = n_offset(1)

        noise_dump = FLTARR(n_offset+n_peak)
        noise_dump(0:n_offset-1) = y_drift_corrected_i(x_drift_offset)
        noise_dump(n_offset:(n_offset+n_peak-1)) = y_object - y_peak_fit_i

        noise_dump = MOMENT(noise_dump)
        noise_level_total(i+ch_address) = SQRT(noise_dump(1))

        channel_info(i+ch_address) = $
         STRCOMPRESS(STRING(i+ch_address+1))+ '. ' + $
         STRCOMPRESS(STRING(peak_flux(i+ch_address)))+ ' , ' + $
         STRCOMPRESS(STRING(noise_level_peak(i+ch_address)))+ ' , ' + $
         STRCOMPRESS(STRING(noise_level_offset(i+ch_address)))+ ' , ' + $
         STRCOMPRESS(STRING(noise_level_total(i+ch_address)))

        If silence EQ 0 Then Begin
    
         Plot,x_drift,y_drift_corrected_i,xtitle='drift-time (s)',$
              ytitle='Flux (Jy)',title=channel_print(i+ch_address),charsize=1.3
         Oplot,x_object,y_peak_fit_i,lines=2
         Plots,[0,n_points-3],[0,0],lines=1

        Endif

        y_drift_corrected(i+ch_address,*) = y_drift_corrected_i
        y_peak_fit(i+ch_address,*) = y_peak_fit_i

       Endfor


       !p.multi=0

       If silence EQ 0 Then Begin

        current_res_title1 = ' Ch.   Flux      Noise       Noise       Noise '
        current_res_title2 = '      Object     Peak        Offset     Combined
        current_res_title3 = '       (Jy)       (Jy)        (Jy)        (Jy)'


        If ch_address EQ 0 Then Begin

         current_res_text = $
         [current_res_title1 , current_res_title2 , current_res_title3 , $
          channel_info(0) , $
          channel_info(1) , $
          channel_info(2) , $
          channel_info(3) , $
          channel_info(4) , $
          channel_info(5) , $
          channel_info(6) , $
          channel_info(7)]

        Endif Else Begin

         current_res_text = $
         [current_res_title1 , current_res_title2 , $
          channel_info(8) , $
          channel_info(9) , $
          channel_info(10) , $
          channel_info(11) , $
          channel_info(12) , $
          channel_info(13) , $
          channel_info(14)]

        Endelse

        Widget_control , current_res , Set_value = current_res_text

       Endif

      End

;----------Pro APPLY_LIN_CUT---------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------
