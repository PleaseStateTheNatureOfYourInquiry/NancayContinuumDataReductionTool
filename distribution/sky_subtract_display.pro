
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro SKY_SUBTRACT_DISPLAY--------------------------------------------
;----------date: 16 - 08 - 2004------------------------------------------------


      Pro SKY_SUBTRACT_DISPLAY

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @SKY_SUBTRACT.CB
       @SKY_CUT_SETTING.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_SKY.CB


;----------Start SKY_SUBTRACT_DISPLAY------------------------------------------

       sky_base = $
        Widget_base(group_leader=base,$
         title='NCDRT V2.0 Sky Subtract Tool' , column=1 )


;----------Load sky observation button-----------------------------------------

       sky_load_obs = Widget_button(sky_base, value='Load Sky Data File' , $
                                      uvalue = 'SKYLOADOBS')


;----------Information about the current sky observation-----------------------

       sky_file_info = Widget_text(sky_base , xsize=80 , ysize=6)


;----------Messages------------------------------------------------------------

       sky_process_info = Widget_text(sky_base , xsize=80 , ysize=2)


;----------Main slider track switch--------------------------------------------

       main_slider_track_switch = Widget_button(sky_base, $
        value='Main Slider Tracking Switch' , $
        uvalue = 'MAINSLIDERTRACKSWITCH')


;----------The cutting sliders-------------------------------------------------

       sky_slider_offset_low = Widget_slider(sky_base, minimum = 0, $
        maximum = 119 , title = 'Sky Offset Low' , $
        uvalue = 'SKYSLIDERCUTLOW', scroll = 1)

       sky_slider_offset_high = Widget_slider(sky_base, minimum = 0, $
        maximum = 119 , title = 'Sky Offset High' , $
        uvalue = 'SKYSLIDERCUTHIGH', scroll = 1)

       sky_slider_shift = Widget_slider(sky_base, minimum = -25, $
        maximum = +25 , title = 'Sky Shift' , $
        uvalue = 'SKYSLIDERSHIFT', scroll = 1)


;----------Do sky subtraction to the data--------------------------------------

       sky_subtract_do = Widget_button(sky_base, $
        value='Do Sky Subtraction' , $
        uvalue = 'SKYSUBTRACTDO')


;----------Undo sky subtraction to the data------------------------------------

       sky_subtract_undo = Widget_button(sky_base, $
        value='Undo Sky Subtraction' , $
        uvalue = 'SKYSUBTRACTUNDO')


;----------The Sky Subtration Tool DISMISS button------------------------------

       sky_dismiss = Widget_button(sky_base , value='Dismiss' , $
        uvalue = 'SKYDISMISS')


;---------Realize the widgets--------------------------------------------------

       Widget_control , sky_base , /realize

       sky_subtract_tool_active = 1

       sky_shift = 0
       Widget_control , sky_slider_shift , Set_value = sky_shift

       Xmanager, 'SKY_SUBTRACT_DISPLAY', sky_base , /NO_BLOCK

      End

;----------Pro SKY_SUBTRACT_DISPLAY--------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------


