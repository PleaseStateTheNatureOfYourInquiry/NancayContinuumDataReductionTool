
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro NCDRT_DISPLAY_EVENT---------------------------------------------
;----------date: 23 - 07 - 2004------------------------------------------------

      Pro NCDRT_DISPLAY_EVENT , ev


;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @LOAD_OBS.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB

       Widget_control , ev.top , Get_uvalue = upper
       Widget_control , ev.id ,  Get_uvalue = uval


;----------Load a file from the directory--------------------------------------

       If uval EQ 'LOADOBS' Then Begin

        next_obs = 0
        LOAD_OBS

        If file_base EQ '' Then Goto, r100

;----------Open a plot Window to show the fits---------------------------------

        Window , 2 , xsize=450 , ysize=750 , $
         title = 'NCDRT - Results'

        Window , 3 , xsize=600 , ysize=200 , $
         title = 'NCDRT - Scissors'


;----------Apply the cut and the linear correction and show it-----------------

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0

        If cal_tool_active EQ 1 AND n_cal_points GT 0 Then $
         PLOT_CALIBRATION_DATA


 r100:
       Endif


;----------Switch between normal and detailed scissor mode---------------------

       If uval EQ 'SCISSORSWITCH' Then Begin

        If scissor EQ 0 Then Begin

         scissor = 1
         SHOW_LIN_CUT
  
        Endif Else Begin

         scissor = 0 
         SHOW_LIN_CUT

        Endelse

       Endif


;----------Read the next file in the list--------------------------------------

       If uval EQ 'NEXTOBS' Then Begin

        If n_scan_processed EQ 0 Then Begin

         next_obs = 0

        Endif Else Begin

         next_obs = 1

        Endelse
       
        LOAD_OBS

        If file_base EQ '' Then Goto, r200


;----------Open a plot Window to show the fits---------------------------------

        Window , 2 , xsize=450 , ysize=750 , $
         title = 'NCDRT - Results'

        Window , 3 , xsize=600 , ysize=200 , $
         title = 'NCDRT - Scissors'


;----------Apply the cut and the linear correction and show it-----------------

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0

        If cal_tool_active EQ 1 AND n_cal_points GT 0 Then $
         PLOT_CALIBRATION_DATA

 r200:
       Endif


;----------Read the next file in the list--------------------------------------

       If uval EQ 'PREVIOUSOBS' Then Begin

        If n_scan_processed EQ 0 Then Begin

         next_obs = 0

        Endif Else Begin

         next_obs = -1

        Endelse
       
        LOAD_OBS


        If file_base EQ '' Then Goto, r300

        Window , 2 , xsize=450 , ysize=750 , $
         title = 'NCDRT - Results'

        Window , 3 , xsize=600 , ysize=200 , $
         title = 'NCDRT - Scissors'


;----------Apply the cut and the linear correction and show it-----------------

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0

        If cal_tool_active EQ 1 AND n_cal_points GT 0 Then $
         PLOT_CALIBRATION_DATA

 r300:
       Endif


;----------Change in the low value of the offset: show the selected cut--------

       If uval EQ 'SLIDERCUTLOW' Then Begin


;----------Read the values from the offset slider------------------------------

        Widget_control , slider_offset_low , Get_value = t_offset_low
        Widget_control , slider_offset_high , Get_value = t_offset_high
        Widget_control , slider_peak_low , Get_value = t_peak_low
        Widget_control , slider_peak_high , Get_value = t_peak_high


;----------Apply the cut and the linear correction and show it-----------------

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0

       Endif


;----------Change in the high value of the offset: show the selected cut-------

       If uval EQ 'SLIDERCUTHIGH' Then Begin


;----------Read the values from the offset slider------------------------------

        Widget_control , slider_offset_low , Get_value = t_offset_low
        Widget_control , slider_offset_high , Get_value = t_offset_high
        Widget_control , slider_peak_low , Get_value = t_peak_low
        Widget_control , slider_peak_high , Get_value = t_peak_high


;----------Apply the cut and the linear correction and show it-----------------

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0

       Endif


;----------Change in the low value of the peak: show the selected cut----------

       If uval EQ 'SLIDERPEAKLOW' Then Begin


;----------Read the values from the offset slider------------------------------

        Widget_control , slider_offset_low , Get_value = t_offset_low
        Widget_control , slider_offset_high , Get_value = t_offset_high
        Widget_control , slider_peak_low , Get_value = t_peak_low
        Widget_control , slider_peak_high , Get_value = t_peak_high


;----------Apply the cut and the linear correction and show it-----------------

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0 

       Endif


;----------Change in the high value of the peak: show the selected cut---------

       If uval EQ 'SLIDERPEAKHIGH' Then Begin


;----------Read the values from the offset slider------------------------------

        Widget_control , slider_offset_low , Get_value = t_offset_low
        Widget_control , slider_offset_high , Get_value = t_offset_high
        Widget_control , slider_peak_low , Get_value = t_peak_low
        Widget_control , slider_peak_high , Get_value = t_peak_high


;----------Apply the cut and the linear correction and show it-----------------

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0 

       Endif


;----------Switch between averaging and not averaging--------------------------

       If uval EQ 'AVERAGINGSWITCH' Then Begin

        If n_scan_processed EQ 0 Then Begin

         message = 'No data file selected. Please do so.'
         Widget_control , process_info , Set_value = message

         Goto, r400

        Endif


        If ch_address EQ 0 Then Begin

         ch_address = 8
         n_channel = 7

         If average_done EQ 0 Then Begin

          Widget_control , channel_select , Get_value = channel_include_save
          average_done = 1

         Endif Else Begin

          channel_include = channel_include_save
          Widget_control , channel_select , Get_value = channel_include_save

         Endelse


;----------USER: AVERAGING-----------------------------------------------------
;----------Here the channel select string for the averaging mode is determined-
;----------Only those averages which have all channels selected can set to 1.--
;----------If the averaging channels are changed in  load_obs.pro  then this---
;----------must also be adapted.-----------------------------------------------

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

         channel_include = ''

         If (channels(0) EQ 0) OR (channels(2) EQ 0) Then Begin 

          channel_include = channel_include + ' 0'

         Endif Else Begin

          channel_include = channel_include + ' 1'

         Endelse


         If (channels(1) EQ 0) OR (channels(3) EQ 0) Then Begin 

          channel_include = channel_include + ' 0'

         Endif Else Begin

          channel_include = channel_include + ' 1'

         Endelse


         If (channels(4) EQ 0) OR (channels(6) EQ 0) Then Begin 

          channel_include = channel_include + ' 0'

         Endif Else Begin

          channel_include = channel_include + ' 1'

         Endelse


         If (channels(5) EQ 0) OR (channels(7) EQ 0) Then Begin 

          channel_include = channel_include + ' 0'

         Endif Else Begin

          channel_include = channel_include + ' 1'

         Endelse


         If (channels(0) EQ 0) OR (channels(1) EQ 0) OR $
            (channels(2) EQ 0) OR (channels(3) EQ 0) Then Begin 

          channel_include = channel_include + ' 0'

         Endif Else Begin

          channel_include = channel_include + ' 1'

         Endelse


         If (channels(4) EQ 0) OR (channels(5) EQ 0) OR $
            (channels(6) EQ 0) OR (channels(7) EQ 0) Then Begin 

          channel_include = channel_include + ' 0'

         Endif Else Begin

          channel_include = channel_include + ' 1'

         Endelse


         If (channels(0) EQ 0) OR (channels(1) EQ 0) OR $
            (channels(2) EQ 0) OR (channels(3) EQ 0) OR $
            (channels(4) EQ 0) OR (channels(5) EQ 0) OR $
            (channels(6) EQ 0) OR (channels(7) EQ 0) Then Begin 

          channel_include = channel_include + ' 0'

         Endif Else Begin

          channel_include = channel_include + ' 1'

         Endelse

         channel_include = channel_include + ' 0'



        Endif Else Begin

         ch_address = 0
         n_channel = 8

         If average_done EQ 0 Then Begin

          Widget_control , channel_select , Get_value = channel_include_save
          channel_include = ' 1 1 1 1 1 1 1 1'
          average_done = 1

         Endif Else Begin

          channel_include = channel_include_save
          Widget_control , channel_select , Get_value = channel_include_save

         Endelse

        Endelse

        Widget_control , channel_select , Set_value = channel_include

        Wset,2
        Erase

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0 

 r400:

       Endif
     

;----------Launch the calibration tool-----------------------------------------

       If uval EQ 'CALIBRATIONTOOL' Then Begin

        If cal_tool_active EQ 1 Then Goto,r500

        If n_scan_processed GT 0 Then Begin

         CALIBRATION_DISPLAY
   
        Endif Else Begin

         message = 'No data file selected. Please do so.'
         Widget_control , process_info , Set_value = message

        Endelse
 
 r500:

       Endif


;----------Apply the calibration with the present calibration table------------

       If uval EQ 'APPLYCALIBRATIONSHORTCUT' Then Begin

        If n_scan_processed GT 0 Then Begin

         APPLY_CALIBRATION
   
        Endif Else Begin

         message = 'No data file selected. Please do so.'
         Widget_control , process_info , Set_value = message

        Endelse

       Endif


;----------Write the result to a postscript file with standard name------------

       If uval EQ 'WRITERESULT2PS' Then Begin

        If n_scan_processed EQ 0 Then Begin

         message = 'No data file selected. Please do so.'
         Widget_control , process_info , Set_value = message

         Goto, r600

        Endif

        choose_name = 0
        WRITE_RESULT_2_PS , choose_name

 r600:

      Endif


;----------Write the result to a postscript file with choice of file name------

       If uval EQ 'WRITERESULT2PSNAME' Then Begin

        If n_scan_processed EQ 0 Then Begin

         message = 'No data file selected. Please do so.'
         Widget_control , process_info , Set_value = message

         Goto, r700

        Endif

        choose_name = 1
        WRITE_RESULT_2_PS , choose_name

 r700:

      Endif





;----------Write the results to a file-----------------------------------------

       If uval EQ 'SAVERES' Then Begin

        If n_scan_processed GT 0 Then Begin

         SAVE_RES

        Endif Else Begin

         message = 'No data file selected. Please do so.'
         Widget_control , process_info , Set_value = message

        Endelse

       Endif


;----------Stop the viewing and delete the widgets-----------------------------

       If uval EQ 'QUIT' Then Begin

        If n_scan_processed NE 0 Then Begin

         Wdelete , 2
         Wdelete , 3
      
        Endif

        If (cal_tool_active EQ 1) AND (n_cal_points GT 0) Then Wdelete , 4

        Widget_control , ev.top , /Destroy

       Endif



    End

;----------Pro NCDRT_DISPLAY_EVENT--------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------
