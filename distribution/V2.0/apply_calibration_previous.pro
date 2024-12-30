
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro APPLY_CALIBRATION-----------------------------------------------
;----------date: 28 - 07 - 2004------------------------------------------------


      PRO APPLY_CALIBRATION

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


;----------Start APPLY_CALIBRATION---------------------------------------------


;----------If there is no calibration table, than skip this routine------------

       If cal_table EQ '' Then Begin

        message = ['No calibration table was loaded or created.' , $
                   'No action was taken.']
        Widget_control , cal_process_info , Set_value = message
        Goto, r100

       Endif


;---------If no calibration points exist, then skip this routine---------------

       If n_cal_points EQ 0 Then Begin

        message = ['Current calibration table has no data.' , $
                   'No action was taken.']
        Widget_control , cal_process_info , Set_value = message
        Goto, r100

       Endif


;----------In case of calibrating a calibrator that exists in the calibration--
;----------table---------------------------------------------------------------

       time_eq = WHERE(julian_obs EQ calibration_time,count_time_eq)

       If count_time_eq GT 0 Then Begin

        apply_factors = calibration_factors(time_eq,*)
        apply_factors_error = calibration_factors_error(time_eq,*)
        Goto, r200

       Endif


       time_gt = WHERE(julian_obs GE calibration_time,count_time_gt)

       If count_time_gt LE 0 Then Begin

        apply_factors = calibration_factors(0,*)
        apply_factors_error = calibration_factors_error(0,*)

       Endif

       If count_time_gt GT 0 Then Begin

        n_time_gt = SIZE(time_gt)
        time_id = time_gt(n_time_gt(1)-1)

        If julian_obs GT calibration_time(n_cal_points-1) Then Begin 

         apply_factors = calibration_factors(n_cal_points-1,*)
         apply_factors_error = calibration_factors_error(n_cal_points-1,*)

        Endif Else Begin

         For i = 0,11 Do Begin

          time_id_low = time_id
  r10:    If calibration_factors(time_id_low,i) GE 0 Then Goto, r30
          time_id_low  = time_id_low - 1
          If time_id_low LT 0 Then Goto, r20  
          Goto, r10
  r20:    time_id_low = -1.
  r30:    

          time_id_high = time_id+1
  r40:    If calibration_factors(time_id_high,i) GE 0 Then Goto, r60
          time_id_low  = time_id_low - 1
          If time_id_low LT 0 Then Goto, r50  
          Goto, r10
  r50:    time_id_low = -1.
  r60:    
        
         


         apply_factors = 0.5 * $
          (calibration_factors(time_id,*) + calibration_factors(time_id+1,*))

         df1 = calibration_factors_error(time_id,*) / $
          calibration_factors(time_id,*)
         df2 = calibration_factors_error(time_id+1,*) / $
          calibration_factors(time_id+1,*)

         apply_factors_error = apply_factors * SQRT(df1*df1 + df2*df2)

        Endelse
 
       Endif


 r200: print,apply_factors

       For i = 0,11 Do Begin

        channel_data(i,*) = channel_data_ori(i,*) * apply_factors(i)

       Endfor

       SHOW_LIN_CUT

       APPLY_LIN_CUT , 0

       calibration_applied = 1


;----------Write information on the current table to the information widget----

       info1 = 'Calibration has been applied to current data.'

       info_message = [info1]

       Widget_control, cal_process_info , Set_value = info_message

 r100:     

      End

;----------Pro APPLY_CALIBRATION-----------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------
