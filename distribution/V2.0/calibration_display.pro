
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro CALIBRATION_DISPLAY---------------------------------------------
;----------date: 27 - 07 - 2004------------------------------------------------


      PRO CALIBRATION_DISPLAY

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


;----------Start CALIBRATION_DISPLAY-------------------------------------------

       cal_base = $
        Widget_base(group_leader=base,$
         title='NCDRT V2.0 Calibration Tool' , column=1 )


;----------Create a new calibration table--------------------------------------

       create_cal_table = $
        Widget_button(cal_base, value='Create New Calibration Table' , $
                                uvalue = 'CREATECALTABLE')


;---------Read an existing calibration table-----------------------------------

       read_cal_table = $
        Widget_button(cal_base, value='Read Existing Calibration Table' , $
                                uvalue = 'READCALTABLE')


;---------Information about current calibration table--------------------------

       current_cal_table = Widget_text(cal_base , xsize=80 , ysize=3)


;---------Write to calibration table-------------------------------------------

       write_2_cal_table = $
        Widget_button(cal_base, value='Write To Calibration Table' , $
                                uvalue = 'WRITE2CALTABLE')

;---------Delete from calibration table----------------------------------------

       delete_from_cal_table = $
        Widget_button(cal_base, value='Delete From Calibration Table' , $
                                uvalue = 'DELETEFROMCALTABLE')


;---------Create .ps file of the current calibration data----------------------

       plot_calibration_data_ps = $
        Widget_button(cal_base, value='Create .ps Of Calibration Data' , $
                                uvalue = 'PLOTCALIBRATIONDATAPS')


;----------Messages------------------------------------------------------------

       cal_process_info = Widget_text(cal_base , xsize=80 , ysize=2)


;----------Apply the calibration to the current data---------------------------
     
       apply_calibrate = $
        Widget_button(cal_base, value='Apply Current Calibration' , $
                                uvalue = 'APPLYCALIBRATION')


;----------De-Apply the calibration to the current data------------------------
     
       de_apply_calibrate = $
        Widget_button(cal_base, value='De-Apply Current Calibration' , $
                                uvalue = 'DEAPPLYCALIBRATION')


;----------Dismiss the calibration tool----------------------------------------

       dismiss_cal_tool = Widget_button(cal_base, value='Dismiss Tool' , $
                                uvalue = 'DISMISSCALTOOL')


;---------Realize the widgets--------------------------------------------------

       Widget_control , cal_base , /realize

       Xmanager, 'CALIBRATION_DISPLAY', cal_base , /NO_BLOCK


       If cal_table EQ '' Then Begin

        current_table = 'No calibration table has been loaded'

        spanning_dates = ''

        Goto, r100

       Endif


       If n_cal_points GT 0 Then Begin

        current_table = 'Current calibration table with ' + $
        STRCOMPRESS(STRING(n_cal_points)) + ' data points is '

        spanning_dates = 'Spanning reduced julian dates between : ' + $
         STRCOMPRESS(STRING(calibration_time(0))) + ' and ' + $
         STRCOMPRESS(STRING(calibration_time(n_cal_points-1)))

        Window , 4 , xsize=450 , ysize=750 , $
        title = 'NCDRT - Calibration Data'

        PLOT_CALIBRATION_DATA

       Endif Else Begin

        current_table = 'Current calibration table with ' + $
        STRCOMPRESS(STRING(n_cal_points)) + ' data points is '

        spanning_dates = 'NO CALIBRATION DATA POINTS'

       Endelse


 r100:
       cal_message = [current_table , cal_table , $
        spanning_dates]
       Widget_control, current_cal_table , Set_value = cal_message

       cal_tool_active = 1

     
      End

;----------Pro CALIBRATION_DISPLAY---------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------
