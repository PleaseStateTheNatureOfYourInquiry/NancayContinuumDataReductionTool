
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro PLOT_CALIBRATION_DATA_PS----------------------------------------
;----------date: 29 - 07 - 2004------------------------------------------------


      PRO PLOT_CALIBRATION_DATA_PS

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


;----------Start PLOT_CALIBRATION_DATA-----------------------------------------

       plot_file = cal_table + '.ps'

       Set_plot,'ps'
       Device,filename=plot_file,/portrait,xoffset=1,yoffset=1.5,$
        xsize=19,ysize=25


       !p.multi = [0,2,4]

       dtime = 0.1 * (calibration_time(n_cal_points-1) - calibration_time(0))
       time_low = -dtime
       time_high = 11 * dtime
       xtitle_string = 'Julian obs. time - ' + $
        STRCOMPRESS(STRING(calibration_time(0)))

       If n_cal_points EQ 1 Then Begin

        time_low = -1
        time_high = 1
        time_low_det = -1
        time_high_det = 1

       Endif



;----------First six channels--------------------------------------------------

       For i = 0,6 Do Begin

        A = FINDGEN(16) * (!pi*2/16.)
        usersym , 0.3*COS(A) , 0.3*SIN(A)

        plot_cal_factor = calibration_factors(*,i)
        j = WHERE(plot_cal_factor GT 0,count_j)
        k = WHERE(plot_cal_factor LT 0,count_k)
        title_plot = '(full) ' + channel_print(i) + $
                     '(dash) ' + channel_print(i+8)

        If count_j GT 0 Then Begin

         Plot,calibration_time(j)-calibration_time(0),$
          calibration_factors(j,i),$
          xrange=[time_low,time_high],xs=1,yrange=[0.7,1.3],ys=1,$
          xtitle=xtitle_string,$
          ytitle='flux lit. / obs.',$
          title=title_plot,charsize=1.3

         Oplot,calibration_time(j)-calibration_time(0),$
          calibration_factors(j,i),psym=8
         Errplot,calibration_time(j)-calibration_time(0),$
          calibration_factors(j,i)-calibration_factors_error(j,i),$
          calibration_factors(j,i)+calibration_factors_error(j,i)

        Endif Else Begin

         y = FLTARR(count_k)
         y(*) = 0.7
         Plot,calibration_time(k)-calibration_time(0),y,$
          xrange=[time_low,time_high],xs=1,yrange=[0.7,1.3],ys=1,$
          xtitle=xtitle_string,$
          ytitle='flux lit. / obs.',$
          title=title_plot,charsize=1.3

        Endelse


;----------Plot symbols where the calibration factor was not taken into account
;----------(i.e. its value is -1.0)-------------------------------------------

        If count_k GT 0 Then Begin

         y = FLTARR(count_k)
         y(*) = 0.75
         Oplot,calibration_time(k)-calibration_time(0),y,psym=7

        Endif


;----------Over plot the values for the averaging channels in the first four---
;----------windows-------------------------------------------------------------

        A = FINDGEN(16) * (!pi*2/16.)
        usersym , 0.3*COS(A) , 0.3*SIN(A) , /fill

        plot_cal_factor = calibration_factors(*,i+8)
        j = WHERE(plot_cal_factor GT 0,count_j)
        k = WHERE(plot_cal_factor LT 0,count_k)

        If count_j GT 0 Then Begin

         Oplot,calibration_time(j)-calibration_time(0),$
          calibration_factors(j,i+8),lines=2

         Oplot,calibration_time(j)-calibration_time(0),$
          calibration_factors(j,i+8),psym=8
         Errplot,calibration_time(j)-calibration_time(0),$
          calibration_factors(j,i+8)-calibration_factors_error(j,i+8),$
          calibration_factors(j,i+8)+calibration_factors_error(j,i+8)

        Endif

        If count_k GT 0 Then Begin

         y = FLTARR(count_k)
         y(*) = 0.75
         Oplot,calibration_time(k)-calibration_time(0),y,psym=7

        Endif

       Endfor


;----------Last channels-------------------------------------------------------

       A = FINDGEN(16) * (!pi*2/16.)
       usersym , 0.3*COS(A) , 0.3*SIN(A)

       For i = 7,7 Do Begin

        plot_cal_factor = calibration_factors(*,i)
        j = WHERE(plot_cal_factor GT 0,count_j)
        k = WHERE(plot_cal_factor LT 0,count_k)

        If count_j GT 0 Then Begin

         Plot,calibration_time(j)-calibration_time(0),$
          calibration_factors(j,i),$
          xrange=[time_low,time_high],xs=1,yrange=[0.7,1.3],ys=1,$
          xtitle=xtitle_string,$
          ytitle='flux lit. / obs.',$
          title=channel_print(i),charsize=1.3

         Oplot,calibration_time(j)-calibration_time(0),$
          calibration_factors(j,i),psym=8
         Errplot,calibration_time(j)-calibration_time(0),$
          calibration_factors(j,i)-calibration_factors_error(j,i),$
          calibration_factors(j,i)+calibration_factors_error(j,i)

        Endif Else Begin

         y = FLTARR(count_k)
         y(*) = 0.7
         Plot,calibration_time(k)-calibration_time(0),y,$
         xrange=[time_low,time_high],xs=1,yrange=[0.7,1.3],ys=1,$
          xtitle=xtitle_string,$
          ytitle='flux lit. / obs.',$
          title=channel_print(i),charsize=1.3

        Endelse

;----------Plot symbols where the calibration factor was not taken into account
;----------(i.e. its value is -1.0)--------------------------------------------

        If count_k GT 0 Then Begin

         y = FLTARR(count_k)
         y(*) = 0.75
         Oplot,calibration_time(k)-calibration_time(0),y,psym=7

        Endif

       Endfor


       !p.multi = 0

       Device,/close
       Set_plot,'x'


      End

;----------Pro PLOT_CALIBRATION_DATA_PS----------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------
