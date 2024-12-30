 
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro WRITE_RESULT_2_PS-----------------------------------------------
;----------date: 29 - 07 - 2004------------------------------------------------


      PRO WRITE_RESULT_2_PS , choose_name

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @LOAD_OBS.CB
       @LONGITUDE.CB
       @WIDGET_IDS.CB


;----------Start WRITE_RESULT_2_PS---------------------------------------------

       If choose_name EQ 0 Then Begin

        If (ch_address EQ 0) AND (calibration_applied EQ 0) Then $
         plot_file = scan_number + '.res.ps'

        If (ch_address EQ 8) AND (calibration_applied EQ 0) Then $
         plot_file = scan_number + '.res_av.ps'

        If (ch_address EQ 0) AND (calibration_applied EQ 1) Then $
         plot_file = scan_number + '.res_cal.ps'

        If (ch_address EQ 8) AND (calibration_applied EQ 1) Then $
         plot_file = scan_number + '.res_av_cal.ps'
       
       Endif Else Begin

        plot_file = $
         DIALOG_PICKFILE(/WRITE,FILTER='*.ps')

        If plot_file EQ '' Then Begin

         message = 'No file name selected'
         Widget_control , process_info , Set_value = message
         Goto, r100
        
        Endif

       Endelse
        

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

       peak_y = FLTARR(8)
       min_y = FLTARR(8)
       peak_y(*) = -1000.
       min_y(*) = 1000.

       For i = 0,n_channel-1 Do Begin

        If channels(i) EQ 1 Then Begin

         peak_y(i) = MAX(y_drift_corrected(i+ch_address,*))
         min_y(i) = MIN(y_drift_corrected(i+ch_address,*))

        Endif

       Endfor


       peak_valid = WHERE(peak_y GT 0,count_peak_valid)

       If count_peak_valid EQ 0 Then Begin

        message = 'No channels selected'
        Widget_control , process_info , Set_value = message
        Goto, r100

       Endif

       If count_peak_valid EQ 1 Then Begin

        Set_plot,'ps'
        Device,filename=plot_file,/landscape
        char_size = 1.5

       Endif

       If (count_peak_valid GE 2 AND count_peak_valid LE 4) Then Begin

        !p.multi=[0,1,2]
        Set_plot,'ps'
        Device,filename=plot_file,/portrait,xsize=19,ysize=24,$
         xoffset=0,yoffset=0.25
        char_size = 1.25

       Endif

       If count_peak_valid GE 5 Then Begin

        !p.multi=[0,2,2]
        Set_plot,'ps'
        Device,filename=plot_file,/landscape
        char_size = 0.9

       Endif

 r200:

       i_longitude = WHERE(scan_number EQ scan_list, count_longitude)

       peak_flux_max = MAX(peak_y(peak_valid))
       min_y_min = MIN(min_y(peak_valid))
       
       y_range = ( peak_flux_max + ABS(min_y_min) ) / 0.65
       y_range_min = min_y_min - y_range * 0.25
       y_range_max = peak_flux_max + y_range * 0.1


       For i = 0,n_channel-1 Do Begin

        If channels(i) EQ 0 Then Goto,r300

        If calibration_applied EQ 1 Then Begin

         peak_value = 'Peak flux = ' + $
          STRCOMPRESS(STRING(ROUND(100*peak_flux(i+ch_address))/100.)) + $
          ' !M+ ' + $
          STRCOMPRESS(STRING(ROUND(1000*noise_level_total(i+ch_address))/1000.))$
          + ' Jy (cal)'

        Endif Else Begin

         peak_value = 'Peak flux = ' + $
          STRCOMPRESS(STRING(ROUND(100*peak_flux(i+ch_address))/100.)) + $
          ' !M+ ' + $
          STRCOMPRESS(STRING(ROUND(1000*noise_level_total(i+ch_address))/1000.))$
          + ' Jy (not cal)'

        Endelse

        title_text =  channel_print(i+ch_address) + ' of ' + scan_number

        Plot,x_drift,y_drift_corrected(i+ch_address,*),$
         yrange=[y_range_min,y_range_max],ys=1,$
         xtitle='drift-time (s)',$
         ytitle='Flux (Jy)',title=title_text,charsize=char_size
        Oplot,x_object,y_peak_fit(i+ch_address,*),lines=2


        Plots,[0,n_points-3],[0,0],lines=1

        min_y_2 = y_range_min + 0.20 * y_range
        min_y_3 = y_range_min + 0.18 * y_range
        min_y_4 = y_range_min + 0.16 * y_range

        Plots,[0,t_offset_low],[min_y_3,min_y_3],lines=1
        Plots,[t_offset_low,t_offset_low],[min_y_2,min_y_4]

        Plots,[t_offset_high,n_points-3],[min_y_3,min_y_3],lines=1
        Plots,[t_offset_high,t_offset_high],[min_y_2,min_y_4]

        Plots,[t_peak_low,t_peak_high],[min_y_3,min_y_3],lines=2
        Plots,[t_peak_low,t_peak_low],[min_y_2,min_y_4]
        Plots,[t_peak_high,t_peak_high],[min_y_2,min_y_4]

        write_x = FIX(0.04*(n_points-3))

        peak_y =  y_range_min + 0.92 * y_range
        Xyouts,write_x,peak_y,peak_value,charsize=char_size

        peak_y =  y_range_min + 0.86 * y_range
        info = STRCOMPRESS(STRING(central_freq)) + ' MHz'
        Xyouts,write_x,peak_y,info,charsize=char_size


;----------Print the object's name and its Central Meridian Longitude, if any--

        If planet_longitude EQ 0 Then Begin

         info = object

        Endif Else Begin

         If count_longitude EQ 0 Then Begin

          info = object

         Endif Else Begin

          info = object + 'CML : ' + $
           STRCOMPRESS(STRING(scan_longitude(i_longitude)))

         Endelse
       
        Endelse
        
        peak_y = y_range_min + 0.1 * y_range
        Xyouts,write_x,peak_y,info,charsize=char_size


        info = $
         STRCOMPRESS(STRING(FIX(time_start(2)))) + ' ' + $
         STRCOMPRESS(STRING(FIX(time_start(1)))) + ' ' + $
         STRCOMPRESS(STRING(FIX(time_start(0)))) + ' @ ' + $
         STRCOMPRESS(STRING(FIX(time_start(3)))) + 'h' + $
         STRCOMPRESS(STRING(FIX(time_start(4)))) + 'm' + $
         STRCOMPRESS(STRING(FIX(time_start(5)))) + 's UT'


        peak_y = y_range_min + 0.04 * y_range
        Xyouts,write_x,peak_y,info,charsize=char_size

 r300:
       Endfor


       !p.multi=0

       Device,/close
       Set_plot,'x'

 r100:
      End

;----------Pro WRITE_RESULT_2_PS-----------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------



