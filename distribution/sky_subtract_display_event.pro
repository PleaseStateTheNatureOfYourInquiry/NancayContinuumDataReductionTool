
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro SKY_SUBTRACT_DISPLAY_EVENT--------------------------------------
;----------date: 16 - 08 - 2004------------------------------------------------

      Pro SKY_SUBTRACT_DISPLAY_EVENT , sky_ev


;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CUT_SETTING.CB
       @SKY_CUT_SETTING.CB
       @SKY_LOAD_OBS.CB
       @SKY_SUBTRACT.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB
       @WIDGET_IDS_SKY.CB

       Widget_control , sky_ev.top , Get_uvalue = sky_upper
       Widget_control , sky_ev.id ,  Get_uvalue = sky_uval


;----------Load a file from the directory--------------------------------------

       If sky_uval EQ 'SKYLOADOBS' Then Begin

        SKY_LOAD_OBS

        If sky_file_base EQ '' Then Goto, r100


;----------Open a plot Window to show the fits---------------------------------

        Window , 5 , xsize=450 , ysize=750 , $
         title = 'NCDRT - Sky'


;----------Apply the cut and the linear correction and show it-----------------

        SKY_APPLY_LIN_CUT

 r100:
       Endif


;----------Change in the sky low value of the offset: show the selected cut----

       If sky_uval EQ 'SKYSLIDERCUTLOW' Then Begin

        If sky_file_base EQ '' Then Begin

         message = 'No sky file selected. Please do so.'
         Widget_control , sky_process_info , Set_value = message

         Goto, r160

        Endif


        If main_slider_track EQ 1 Then Begin

         sky_t_offset_low = t_offset_low
         Widget_control , sky_slider_offset_low , Set_value = sky_t_offset_low
         Goto, r150

        Endif


;----------Read the values from the sky offset slider--------------------------

        Widget_control , sky_slider_offset_low , Get_value = sky_t_offset_low
        Widget_control , sky_slider_offset_high , Get_value = sky_t_offset_high
        Widget_control , sky_slider_shift , Get_value = sky_shift


;----------Apply the cut and the linear correction and show it-----------------

        SKY_APPLY_LIN_CUT

 r150:
        If sky_subtract_apply EQ 1 Then Begin

         SHOW_LIN_CUT
         APPLY_LIN_CUT , 0

        Endif

 r160:
       Endif


;----------Change in the sky high value of the offset: show the selected cut---

       If sky_uval EQ 'SKYSLIDERCUTHIGH' Then Begin

        If sky_file_base EQ '' Then Begin

         message = 'No sky file selected. Please do so.'
         Widget_control , sky_process_info , Set_value = message

         Goto, r180

        Endif

        If main_slider_track EQ 1 Then Begin

         sky_t_offset_high = t_offset_high
         Widget_control , sky_slider_offset_high , $
          Set_value = sky_t_offset_high
         Goto, r170

        Endif


;----------Read the values from the offset slider------------------------------

        Widget_control , sky_slider_offset_low , Get_value = sky_t_offset_low
        Widget_control , sky_slider_offset_high , Get_value = sky_t_offset_high
        Widget_control , sky_slider_shift , Get_value = sky_shift


;----------Apply the cut and the linear correction and show it-----------------

        SKY_APPLY_LIN_CUT

 r170:
        If sky_subtract_apply EQ 1 Then Begin

         SHOW_LIN_CUT
         APPLY_LIN_CUT , 0

        Endif

 r180:
       Endif



;----------Change in the sky shift value: show the selected cut----------------

       If sky_uval EQ 'SKYSLIDERSHIFT' Then Begin

        If sky_file_base EQ '' Then Begin

         message = 'No sky file selected. Please do so.'
         Widget_control , sky_process_info , Set_value = message

         Goto, r280

        Endif


;----------Read the values from the offset slider------------------------------

        Widget_control , sky_slider_offset_low , Get_value = sky_t_offset_low
        Widget_control , sky_slider_offset_high , Get_value = sky_t_offset_high
        Widget_control , sky_slider_shift , Get_value = sky_shift


;----------Apply the cut and the linear correction and show it-----------------

        SKY_APPLY_LIN_CUT

        If sky_subtract_apply EQ 1 Then Begin

         SHOW_LIN_CUT
         APPLY_LIN_CUT , 0

        Endif

 r280:
       Endif


;----------Main slider tracking switch-----------------------------------------

       If sky_uval EQ 'MAINSLIDERTRACKSWITCH' Then Begin

        If sky_file_base EQ '' Then Begin

         message = 'No sky file selected. Please do so.'
         Widget_control , sky_process_info , Set_value = message

         Goto, r200

        Endif

        If main_slider_track EQ 1 Then Begin

         main_slider_track = 0 
         message = ['Sky offset sliders are now activated',$
         'Use Main Slider Tracking Switch to track main offset sliders.']
         Widget_control , sky_process_info , Set_value = message

         Goto, r200

        Endif Else Begin

         main_slider_track = 1 
         message = ['Main offset sliders are tracked',$
         'Use Main Slider Tracking Switch for independend offset control']
         Widget_control , sky_process_info , Set_value = message

         sky_t_offset_low = t_offset_low 
         sky_t_offset_high = t_offset_high

         Widget_control , sky_slider_offset_low , Set_value = sky_t_offset_low
         Widget_control , sky_slider_offset_high , $
          Set_value = sky_t_offset_high
         Widget_control , sky_slider_shift , Get_value = sky_shift
       
         SKY_APPLY_LIN_CUT
        
        Endelse

 r200:
       Endif


;----------Do sky subtraction to the data--------------------------------------

       If sky_uval EQ 'SKYSUBTRACTDO' Then Begin

        If sky_file_base EQ '' Then Begin

         message = 'No sky file selected. Please do so.'
         Widget_control , sky_process_info , Set_value = message

         Goto, r300

        Endif

        sky_subtract_apply = 1

        message = 'Sky file subtracted from data: DONE'
        Widget_control , sky_process_info , Set_value = message

        If calibration_applied EQ 1 Then SKY_APPLY_CALIBRATION

        SKY_APPLY_LIN_CUT

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0

 r300:
       Endif


;----------Undo sky subtraction to the data------------------------------------

       If sky_uval EQ 'SKYSUBTRACTUNDO' Then Begin

        If sky_file_base EQ '' Then Begin

         message = 'No sky file selected. Please do so.'
         Widget_control , sky_process_info , Set_value = message

         Goto, r400

        Endif

        message = 'Sky file subtracted from data: UNDONE'
        Widget_control , sky_process_info , Set_value = message

        sky_subtract_apply = 0

        SHOW_LIN_CUT

        APPLY_LIN_CUT , 0

 r400:
       Endif


;----------Stop the viewing and delete the widgets-----------------------------

       If sky_uval EQ 'SKYDISMISS' Then Begin

        Widget_control , sky_ev.top , /Destroy

        If sky_file_base NE '' Then Wdelete , 5

        sky_subtract_tool_active = 0
        sky_subtract_apply = 0

       Endif


      End

;----------Pro SKY_SUBTRACT_DISPLAY_EVENT--------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------

