
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro CALIBRATION_DISPLAY_EVENT---------------------------------------
;----------date: 28 - 07 - 2004------------------------------------------------


      PRO CALIBRATION_DISPLAY_EVENT , cal_ev

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @SKY_LOAD_OBS.CB
       @SKY_SUBTRACT.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


;----------Start CALIBRATION_DISPLAY_EVENT-------------------------------------

       Widget_control , cal_ev.top , Get_uvalue = cal_upper
       Widget_control , cal_ev.id ,  Get_uvalue = cal_uval


;---------Read an existing calibration table-----------------------------------

       If cal_uval EQ 'READCALTABLE' Then Begin

        READ_CAL_TABLE

        If n_cal_points GT 0 Then Begin

         Window , 4 , xsize=450 , ysize=750 , $
         title = 'NCDRT - Calibration Data'

         PLOT_CALIBRATION_DATA
        
        Endif

       Endif

;---------Create a new calibration table---------------------------------------

       If cal_uval EQ 'CREATECALTABLE' Then Begin

        If n_cal_points GT 0 Then cal_table_before = cal_table

        cal_table = $
         DIALOG_PICKFILE(/WRITE,FILTER='*',GET_PATH=cal_table_path)

        If cal_table EQ '' Then Begin

         If n_cal_points GT 0 Then Begin

          cal_table = cal_table_before

         Endif Else Begin

          cal_message = 'No calibration table selected'
          Widget_control , current_cal_table , Set_value = cal_message

         Endelse

         Goto, r100
        
        Endif

        Get_lun , file_unit

        Openw , file_unit , cal_table

        Printf , file_unit , ' '
        Printf , file_unit , ' Calibration Table : ' + cal_table
        Printf , file_unit , ' '
        Printf , file_unit , ' Nancay Continuum Data Reduction Tool V2.1 (August 2004)'
        Printf , file_unit , ' '
        Printf , file_unit , Format = '(" Central Frequency : ",F7.2," MHz ")' $
        , central_freq

        Printf, file_unit , ' '
        Printf, file_unit , ' object name'
        Printf, file_unit , ' object file'
        Printf, file_unit , ' observation mid time (reduced julian date)'
        Printf, file_unit , '  ch1   d_ch1     ch2   d_ch2     ch3   d_ch3     ch4   d_ch4'
        Printf, file_unit , '  ch5   d_ch5     ch6   d_ch6     ch7   d_ch7     ch8   d_ch8'
        Printf, file_unit , '  ch1+3 d_ch1+3   ch2+4 d_ch2+4   ch5+7 d_ch5+7   ch6+8 d_ch6+8'
        Printf, file_unit , '  ch4-8 d_ch4-8   ch5-8 d_ch5-8   ch1-8 d_ch1-8'
        Printf , file_unit , 'C_END'

        Close , file_unit


        If n_cal_points GT 0 Then Begin

         Wdelete , 4
         n_cal_points = 0

        Endif

        current_table = 'Current calibration table with ' + $
         STRCOMPRESS(STRING(n_cal_points)) + ' data points is '

        cal_message = [current_table , cal_table]
        Widget_control, current_cal_table , Set_value = cal_message

        cal_table_present = 1


 r100:
       Endif


;----------Write new entry to calibration table--------------------------------

       If cal_uval EQ 'WRITE2CALTABLE' Then Begin

        WRITE_2_CAL_TABLE

        If n_cal_points EQ 1 AND cal_table NE '' Then Begin

         Window , 4 , xsize=450 , ysize=750 , $
         title = 'NCDRT - Calibration Data'
        
        Endif

        If n_cal_points GT 0 AND cal_table NE '' Then PLOT_CALIBRATION_DATA

       Endif


;----------Delete entry from calibration table---------------------------------

       If cal_uval EQ 'DELETEFROMCALTABLE' Then DELETE_FROM_CAL_TABLE


;----------Create a postscript file of the calibration data--------------------

       If cal_uval EQ 'PLOTCALIBRATIONDATAPS' Then PLOT_CALIBRATION_DATA_PS


;----------Apply calibration---------------------------------------------------

       If cal_uval EQ 'APPLYCALIBRATION' Then APPLY_CALIBRATION


;----------De-Apply calibration------------------------------------------------

       If cal_uval EQ 'DEAPPLYCALIBRATION' Then Begin

        channel_data = channel_data_ori
        apply_factors(*) = 1.0
        apply_factors_error(*) = 0.0

        calibration_applied = 0

        If (sky_subtract_tool_active EQ 1) AND (sky_file_base NE '') $
         Then SKY_APPLY_LIN_CUT

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0
        
        info1 = 'Calibration has been de-applied to current data.'

        info_message = [info1]

        Widget_control, cal_process_info , Set_value = info_message

      Endif


;----------Dismiss the calibration tool widget---------------------------------

       If cal_uval EQ 'DISMISSCALTOOL' Then Begin

        If (n_cal_points GT 0) Then Wdelete , 4

        Widget_control , cal_ev.top , /Destroy

        cal_tool_active = 0

       Endif

     
      End

;----------Pro CALIBRATION_DISPLAY_EVENT---------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------


