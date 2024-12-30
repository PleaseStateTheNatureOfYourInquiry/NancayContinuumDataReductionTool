
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

        If cal_tool_active EQ 1 Then Begin

         message = ['No calibration table was loaded or created.' , $
                    'No action was taken.']

         Widget_control , cal_process_info , Set_value = message

        Endif Else Begin

         message = ['No calibration table was loaded or' , $
                    'created. No action was taken.']

         Widget_control , process_info , Set_value = message

        Endelse

        Goto, r100

       Endif


;---------If no calibration points exist, then skip this routine---------------

       If n_cal_points EQ 0 Then Begin

        message = ['Current calibration table has no data.' , $
                   'No action was taken.']

        If cal_tool_active EQ 1 Then Begin

         Widget_control , cal_process_info , Set_value = message

        Endif Else Begin

         Widget_control , process_info , Set_value = message

        Endelse


        Goto, r100

       Endif


;----------In case of calibrating a calibrator that exists in the calibration--
;----------table---------------------------------------------------------------

       cal_time = calibration_time

       For i = 0,14 Do Begin

        cal_time(*) = 0.

        cal_factors = calibration_factors(*,i)

        cal_factors_valid = WHERE(cal_factors GE 0,count_valid)

        If count_valid LE 0 Then Begin

         apply_factors(i) = 1.
         apply_factors_error(i) = 0.
         Goto, r10

        Endif

        cal_time(cal_factors_valid) = calibration_time(cal_factors_valid)

        dtime = ABS(cal_time - julian_obs)

        time_id = WHERE(dtime EQ MIN(dtime))

        apply_factors(i) = calibration_factors(time_id,i)
        apply_factors_error(i) = calibration_factors_error(time_id,i)

  r10:
       Endfor


 r200: 
       For i = 0,14 Do Begin

        channel_data(i,*) = channel_data_ori(i,*) * apply_factors(i)

       Endfor

       SHOW_LIN_CUT

       APPLY_LIN_CUT , 0

       calibration_applied = 1


;----------Write information on the current table to the information widget----

       If cal_tool_active EQ 1 Then Begin

        info_message = 'Calibration has been applied to current data.'
        Widget_control, cal_process_info , Set_value = info_message

       Endif Else Begin

        info_message = ['Calibration has been applied to current','data.']
        Widget_control , process_info , Set_value = info_message

       Endelse



 r100:     

      End

;----------Pro APPLY_CALIBRATION-----------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------
