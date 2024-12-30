
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro SHOW_LIN_CUT----------------------------------------------------
;----------date: 16 - 08 - 2004------------------------------------------------


      PRO SHOW_LIN_CUT

;----------The common blocks used in this procedure----------------------------

       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @LOAD_OBS.CB
       @SKY_CUT_SETTING.CB
       @SKY_SUBTRACT.CB
       @WIDGET_IDS.CB


;----------Start SHOW_LIN_CUT--------------------------------------------------

;----------Check if the offset and peak values are within the limits. If not---
;----------set them to the limits----------------------------------------------

       If t_offset_low EQ 0 Then t_offset_low = 1

       If t_offset_low GT (n_points-3-1) Then Begin

        If t_offset_low GT t_offset_high Then t_offset_low = t_offset_high

       Endif
       
       If t_offset_high GE (n_points-3-1) Then t_offset_high = n_points-3-1 - 1
        
       If t_offset_high LT t_offset_low Then t_offset_high = t_offset_low
        
       If t_offset_low GT t_offset_high Then t_offset_low = t_offset_high

       Widget_control , slider_offset_high , Set_value = t_offset_high
       Widget_control , slider_offset_low , Set_value = t_offset_low



       If t_peak_high GT (n_points-3-1) Then t_peak_high = n_points-3-1

       t_peak_diff = t_peak_high - t_peak_low

       If t_peak_diff LT 4 Then Begin

        t_peak_high = t_peak_low + 4

        If t_peak_high GT (n_points-3-1) Then Begin

         t_peak_high = n_points-3-1
         t_peak_low = t_peak_high - 4

         Endif

       Endif

       Widget_control , slider_peak_high , Set_value = t_peak_high
       Widget_control , slider_peak_low , Set_value = t_peak_low


;----------Determine the linear fit through the offset part of the observation-
;----------and subtract it from the whole observation. The observation used is-
;----------channel 1 or the average of 1+3 by definition-----------------------


       offset_coefs = FLTARR(16,3)
       x_drift = FINDGEN(n_points-3)
       y_drift_corrected = FLTARR(16,n_points-3)

       x_drift_offset = WHERE((x_drift LE t_offset_low) OR $
                              (x_drift GE t_offset_high)) 

       y_drift = channel_data(0+ch_address,*)

       lin_coef = REGRESS(x_drift(x_drift_offset),y_drift(x_drift_offset),$
                          const=lin_const)

       offset_coefs(0,0) = lin_const(0)
       offset_coefs(0,1) = lin_coef(0)
       offset_coefs(0,2) = 0.

       y_drift_offset = lin_coef(0) * x_drift + lin_const(0)
       y_drift_corrected(0+ch_address,*) = y_drift - y_drift_offset

       If sky_subtract_apply EQ 1 Then $
        y_drift_corrected(0+ch_address,*) = $
         y_drift_corrected(0+ch_address,*) - $
         sky_drift_corrected(0+ch_address,*) 



;----------Plot the results in the designated plotting window------------------

       Wset , 3

       title_info = 'F = ' + STRCOMPRESS(STRING(lin_coef(0))) + ' * t + ' + $
                             STRCOMPRESS(STRING(lin_const(0)))


;----------Change to detailed scissor mode if requested------------------------

       If scissor EQ 1 Then Begin

        !p.multi=[0,3,1]

        Plot,x_drift,y_drift_corrected(0+ch_address,*),$
         xtitle='drift-time (s)',ytitle='Flux (Jy)',$
         xrange=[0,t_offset_low+2],xs=1,chars=1.6
        Plots,[t_offset_low,t_offset_low],[-100,100],lines=1
        Plots,[0,t_offset_low+2],[0,0],lines=3

        Plot,x_drift,y_drift_corrected(0+ch_address,*),$
         xtitle='drift-time (s)',ytitle='Flux (Jy)',$
         xrange=[t_offset_low-2,t_offset_high+2],xs=1,chars=1.6
        Plots,[t_offset_low,t_offset_low],[-100,100],lines=1
        Plots,[t_offset_high,t_offset_high],[-100,100],lines=1
        Plots,[t_peak_low,t_peak_low],[-100,100],lines=2
        Plots,[t_peak_high,t_peak_high],[-100,100],lines=2
        Plots,[t_offset_low-2,t_offset_high+2],[0,0],lines=3

        Plot,x_drift,y_drift_corrected(0+ch_address,*),$
         xtitle='drift-time (s)',ytitle='Flux (Jy)',$
         xrange=[t_offset_high-2,n_points-3],xs=1,chars=1.6
        Plots,[t_offset_high,t_offset_high],[-100,100],lines=1
        Plots,[t_offset_high-2,n_points-3],[0,0],lines=3

       Endif Else Begin

        Plot,x_drift,y_drift_corrected(0+ch_address,*),$
         xtitle='drift-time (s)',ytitle='Flux (Jy)',$
         xrange=[0,n_points-2],xs=1
        Plots,[t_offset_low,t_offset_low],[-100,100],lines=1
        Plots,[t_offset_high,t_offset_high],[-100,100],lines=1
        Plots,[t_peak_low,t_peak_low],[-100,100],lines=2
        Plots,[t_peak_high,t_peak_high],[-100,100],lines=2
        Plots,[0,n_points-3],[0,0],lines=3

       Endelse

       !p.multi=0


      End

;----------Pro SHOW_LIN_CUT----------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------


