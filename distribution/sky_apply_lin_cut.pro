
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro SKY_APPLY_LIN_CUT-----------------------------------------------
;----------date: 16 - 08 - 2004------------------------------------------------


      PRO SKY_APPLY_LIN_CUT

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @SKY_CALIBRATION.CB
       @SKY_CHANNEL.CB
       @SKY_CUT_SETTING.CB
       @SKY_LOAD_OBS.CB
       @SKY_SUBTRACT.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_SKY.CB


;----------Start SKY_APPLY_LIN_CUT---------------------------------------------

;----------Check if the sky offset values are within the limits. If not--------
;----------set them to the limits----------------------------------------------

       If sky_t_offset_low EQ 0 Then sky_t_offset_low = 1

       If sky_t_offset_low GT (n_points-3-1) Then Begin

        If sky_t_offset_low GT sky_t_offset_high Then $
         sky_t_offset_low = sky_t_offset_high

       Endif
       
       If sky_t_offset_high GE (n_points-3-1) Then $
        sky_t_offset_high = n_points-3-1 - 1
        
       If sky_t_offset_high LT sky_t_offset_low Then $
        sky_t_offset_high = sky_t_offset_low
        
       If sky_t_offset_low GT sky_t_offset_high Then $
        sky_t_offset_low = sky_t_offset_high

       Widget_control , sky_slider_offset_high , Set_value = sky_t_offset_high
       Widget_control , sky_slider_offset_low , Set_value = sky_t_offset_low


;----------Determine the linear fit through the offset part of the observation-
;----------and subtract it from the whole observation. The observation used is-
;----------channel 1 or the average of 1+3 by definition-----------------------

       sky_apply_factors = FLTARR(16)
       sky_apply_factors(*) = 1.0
       sky_apply_factors_error = FLTARR(16)
       sky_apply_factors_error(*) = 0.0

       If calibration_applied EQ 1 Then SKY_APPLY_CALIBRATION
        
       offset_coefs = FLTARR(16,3)
       x_drift = FINDGEN(n_points-3)
       sky_drift_corrected = FLTARR(16,n_points-3)
       sky_drift_corrected(*,*) = 0.

       x_drift_offset = WHERE((x_drift LE sky_t_offset_low) OR $
                              (x_drift GE sky_t_offset_high)) 

       For i = 0,14 Do Begin

        y_drift = sky_channel_data(i,*) * sky_apply_factors(i)

        lin_coef = REGRESS(x_drift(x_drift_offset),y_drift(x_drift_offset),$
                           const=lin_const)
        offset_coefs(i,0) = lin_const(0)
        offset_coefs(i,1) = lin_coef(0)
        offset_coefs(i,2) = 0.

        y_drift_offset = lin_coef(0) * x_drift + lin_const(0)

        If sky_shift LT 0 Then Begin

         sky_drift_corrected(i,0:n_points-3-1+sky_shift) = $
          y_drift(-sky_shift:n_points-3-1) - $
          y_drift_offset(-sky_shift:n_points-3-1)

        Endif Else Begin

         sky_drift_corrected(i,sky_shift:n_points-3-1) = $
          y_drift(0:n_points-3-1-sky_shift) - $
          y_drift_offset(0:n_points-3-1-sky_shift)

        Endelse

       Endfor


       Wset , 5
       !p.multi = [0,2,4] 

       For i = 0,n_channel-1 Do Begin

        Plot,x_drift,sky_drift_corrected(i+ch_address,*),$
         xtitle='drift-time (s)',ytitle='Flux (Jy)',$
         title=channel_print(i+ch_address),charsize=1.3
        Plots,[0,n_points-3],[0,0],lines=1
     
        If i EQ 0 Then Begin

         y_max = MAX(sky_drift_corrected(i+ch_address,*))
         y_min = MIN(sky_drift_corrected(i+ch_address,*))

         Plots,[sky_t_offset_low+sky_shift,sky_t_offset_low+sky_shift],$
          [y_min,y_max],lines=1
         Plots,[sky_t_offset_high+sky_shift,sky_t_offset_high+sky_shift],$
          [y_min,y_max],lines=1

        Endif


       Endfor

       !p.multi=0

      End

;----------Pro SKY_APPLY_LIN_CUT-----------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------
