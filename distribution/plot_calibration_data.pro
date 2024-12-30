
;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------Pro PLOT_CALIBRATION_DATA-------------------------------------------
;----------date: 26 - 07 - 2004------------------------------------------------


      PRO PLOT_CALIBRATION_DATA

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


;----------Start PLOT_CALIBRATION_DATA-----------------------------------------

       Wset , 4
       Erase

       plot_region = FLTARR(16,4)

       plot_region(0,*) = [0,0.83,0.5,1]
       plot_region(1,*) = [0.5,0.83,1,1]
       plot_region(2,*) = [0,0.75,0.5,0.83]
       plot_region(3,*) = [0.5,0.75,1,0.83]

       plot_region(4,*) = [0,0.58,0.5,0.75]
       plot_region(5,*) = [0.5,0.58,1,0.75]
       plot_region(6,*) = [0,0.5,0.5,0.58]
       plot_region(7,*) = [0.5,0.5,1,0.58]

       plot_region(8,*) = [0,0.33,0.5,0.5]
       plot_region(9,*) = [0.5,0.33,1,0.5]
       plot_region(10,*) = [0,0.25,0.5,0.33]
       plot_region(11,*) = [0.5,0.25,1,0.33]


       plot_region(12,*) = [0,0.08,0.5,0.25]
       plot_region(13,*) = [0.5,0.08,1,0.25]
       plot_region(14,*) = [0,0,0.5,0.08]
       plot_region(15,*) = [0.5,0,1,0.08]
      
       !p.multi = [0,2,8]

       dtime = 0.1 * (calibration_time(n_cal_points-1) - calibration_time(0))
       time_low = -dtime
       time_high = 11 * dtime
       xtitle_string_base = 'Julian obs. time - ' + $
        STRCOMPRESS(STRING(calibration_time(0)))


       If n_cal_points EQ 1 Then Begin

        time_low = -1
        time_high = 1
        time_low_det = -1
        time_high_det = 1
        Goto, r200

       Endif


       If (julian_obs LT calibration_time(0)) OR $ 
          (julian_obs GT calibration_time(n_cal_points-1)) Then Begin

        time_low_det = time_low
        time_high_det = time_high
        Goto, r200

       Endif


;----------Check on equality of observation and calibration time---------------

       t_obs = WHERE(julian_obs EQ calibration_time,count_eq)

       If count_eq GT 0 Then Begin

        If t_obs(0) EQ 0 Then Begin

         time_low_det = -1
         time_high_det = 1
         Goto, r200

        Endif

        If t_obs(0) EQ n_cal_points-1 Then Begin

         time_low_det = $
          calibration_time(n_cal_points-1) - calibration_time(0) - 1
         time_high_det = $
          calibration_time(n_cal_points-1) - calibration_time(0) + 1
         Goto, r200

        Endif

         time_low_det = calibration_time(t_obs(0)) - calibration_time(0) - 1
         time_high_det = calibration_time(t_obs(0)) - calibration_time(0) + 1
         Goto, r200

       Endif


;----------If the observation time is somewhere in the middle of the-----------
;----------calibration_time----------------------------------------------------

       t_obs = WHERE(julian_obs GT calibration_time,count)
       time_id = t_obs(count-1)
        
       time_low_det = calibration_time(time_id) - calibration_time(0)         
       time_high_det =  calibration_time(time_id+1) - calibration_time(0)

 r200:

;----------Channels 1 and 2 + 1+3 and 2+4 general plot-------------------------

       For i = 0,1 Do Begin

        !p.region = plot_region(i,*)
        PLOT_CALIBRATION_DATA_ALL_2CHANNELS , i , xtitle_string_base $
         , time_low , time_high

       Endfor


;----------Channels 1 and 2 + 1+3 and 2+4 detailed plot------------------------

       For i = 0,1 Do Begin

        !p.region = plot_region(i+2,*)
        PLOT_CALIBRATION_DATA_DETAIL_2CHANNELS , i , xtitle_string_base $
         , time_low_det , time_high_det

       Endfor


;----------Channels 3 and 4 + 5+7 and 6+8 general plot-------------------------

       For i = 2,3 Do Begin

        !p.region = plot_region(i+2,*)
        PLOT_CALIBRATION_DATA_ALL_2CHANNELS , i , xtitle_string_base $
         , time_low , time_high

       Endfor


;----------Channels 3 and 4 + 5+7 and 6+8 detailed plot------------------------

       For i = 2,3 Do Begin

        !p.region = plot_region(i+4,*)
        PLOT_CALIBRATION_DATA_DETAIL_2CHANNELS , i , xtitle_string_base $
         , time_low_det , time_high_det

       Endfor


;----------Channels 5 and 6 + 1to4 and 5to8 general plot-----------------------

       For i = 4,5 Do Begin

        !p.region = plot_region(i+4,*)
        PLOT_CALIBRATION_DATA_ALL_2CHANNELS , i , xtitle_string_base $
         , time_low , time_high

       Endfor


;----------Channels 5 and 6 + 1to4 and 5to8 detailed plot----------------------

       For i = 4,5 Do Begin

        !p.region = plot_region(i+6,*)
        PLOT_CALIBRATION_DATA_DETAIL_2CHANNELS , i , xtitle_string_base $
         , time_low_det , time_high_det

       Endfor


;----------Channels 7 + 1to8 general plot--------------------------------------

       !p.region = plot_region(6+6,*)
       PLOT_CALIBRATION_DATA_ALL_2CHANNELS , 6 , xtitle_string_base $
         , time_low , time_high


;----------Channels 8 general plot---------------------------------------------

       i = 7
       !p.region = plot_region(i+6,*)
       PLOT_CALIBRATION_DATA_ALL_1CHANNEL , i , xtitle_string_base $
         , time_low , time_high


;----------Channels 7 + 1to8 detailed plot-------------------------------------

       !p.region = plot_region(6+8,*)
       PLOT_CALIBRATION_DATA_DETAIL_2CHANNELS , 6 , xtitle_string_base $
         , time_low_det , time_high_det


;----------Channels 8 detailed plot--------------------------------------------

       i = 7
       !p.region = plot_region(i+8,*)
       PLOT_CALIBRATION_DATA_DETAIL_1CHANNEL , i , xtitle_string_base $
         , time_low_det , time_high_det



       !p.multi = 0
       !p.region = 0

      End

;----------Pro PLOT_CALIBRATION_DATA-------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------







;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro PLOT_CALIBRATION_DATA_ALL_1CHANNEL------------------------------
;----------date: 26 - 07 - 2004------------------------------------------------


      PRO PLOT_CALIBRATION_DATA_ALL_1CHANNEL , i , xtitle_string_base $
       , time_low , time_high

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


       xtitle_string = channel_print(i) + ' ' + xtitle_string_base
       
       plot_cal_factor = calibration_factors(*,i)
       j = WHERE(plot_cal_factor GT 0,count_j)
       k = WHERE(plot_cal_factor LT 0,count_k)

       If count_j GT 0 Then Begin

        Plot,calibration_time(j)-calibration_time(0),$
         calibration_factors(j,i),$
         xrange=[time_low,time_high],xs=1,yrange=[0.7,1.3],ys=1,$
         xtitle=xtitle_string,$
         ytitle='flux lit./obs.',$
         charsize=1.3

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
         ytitle='flux lit./obs.',$
         charsize=1.3

       Endelse

;----------Plot symbols where the calibration factor was not taken into account
;----------(i.e. its value is -1.0)--------------------------------------------

       If count_k GT 0 Then Begin

        y = FLTARR(count_k)
        y(*) = 0.75
        Oplot,calibration_time(k)-calibration_time(0),y,psym=7

       Endif


;----------Line with the time position of the current observation--------------

       If (julian_obs GE calibration_time(0)) AND $
          (julian_obs LE calibration_time(n_cal_points-1)) Then Begin $

        Plots,$
         [julian_obs-calibration_time(0),julian_obs-calibration_time(0)],$
         [0.7,1.3],lines=1

       Endif

       End

;----------Pro PLOT_CALIBRATION_DATA_ALL_1CHANNEL------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------



;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro PLOT_CALIBRATION_DATA_DETAIL_1CHANNEL---------------------------
;----------date: 26 - 07 - 2004------------------------------------------------


      PRO PLOT_CALIBRATION_DATA_DETAIL_1CHANNEL , i , xtitle_string_base $
       , time_low , time_high

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


       plot_cal_factor = calibration_factors(*,i)
       j = WHERE(plot_cal_factor GT 0,count_j)
       k = WHERE(plot_cal_factor LT 0,count_k)

       If count_j GT 0 Then Begin

        Plot,calibration_time(j)-calibration_time(0),$
         calibration_factors(j,i),$
         xrange=[time_low,time_high],xs=1,yrange=[0.7,1.3],ys=1,$
         ytitle ='lit / obs',ymargin=[0,0],chars=1.3,xticks=2

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
         ytitle ='lit / obs',ymargin=[0,0],chars=1.3,xticks=2

       Endelse

;----------Plot symbols where the calibration factor was not taken into account
;----------(i.e. its value is -1.0)--------------------------------------------

       If count_k GT 0 Then Begin

        y = FLTARR(count_k)
        y(*) = 0.75
        Oplot,calibration_time(k)-calibration_time(0),y,psym=7

       Endif


;----------Line with the time position of the current observation--------------

       If (julian_obs GE calibration_time(0)) AND $
          (julian_obs LE calibration_time(n_cal_points-1)) Then Begin $

        Plots,$
         [julian_obs-calibration_time(0),julian_obs-calibration_time(0)],$
         [0.7,1.3],lines=1

       Endif

       End

;----------Pro PLOT_CALIBRATION_DATA_DETAIL_1CHANNEL---------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------




;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro PLOT_CALIBRATION_DATA_ALL_2CHANNELS-----------------------------
;----------date: 26 - 07 - 2004------------------------------------------------


      PRO PLOT_CALIBRATION_DATA_ALL_2CHANNELS , i , xtitle_string_base $
       , time_low , time_high

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


       A = FINDGEN(16) * (!pi*2/16.)
       usersym , 0.3*COS(A) , 0.3*SIN(A)

       xtitle_string = channel_print(i) + ' ' + xtitle_string_base

       plot_cal_factor = calibration_factors(*,i)
       j = WHERE(plot_cal_factor GT 0,count_j)
       k = WHERE(plot_cal_factor LT 0,count_k)

       If count_j GT 0 Then Begin

        Plot,calibration_time(j)-calibration_time(0),$
         calibration_factors(j,i),$
         xrange=[time_low,time_high],xs=1,yrange=[0.7,1.3],ys=1,$
         xtitle=xtitle_string, $
         ytitle='flux lit. / obs.',$
         charsize=1.3

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
         xtitle=xtitle_string, $
         ytitle='flux lit. / obs.',$
         charsize=1.3

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
;        Oploterr,calibration_time(j)-calibration_time(0),$
;         calibration_factors(j,i+8),calibration_factors_error(j,i+8),psym=6

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


;----------Line with the time position of the current observation--------------

       If (julian_obs GE calibration_time(0)) AND $
          (julian_obs LE calibration_time(n_cal_points-1)) Then Begin $

        Plots,$
         [julian_obs-calibration_time(0),julian_obs-calibration_time(0)],$
         [0.7,1.3],lines=1

       Endif

      End


;----------Pro PLOT_CALIBRATION_DATA_ALL_2CHANNELS-----------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------END-----------------------------------------------------------------




;----------BEGIN---------------------------------------------------------------
;----------NCDRT V2.0----------------------------------------------------------
;----------Pro PLOT_CALIBRATION_DATA_DETAIL_2CHANNELS--------------------------
;----------date: 26 - 07 - 2004------------------------------------------------


      PRO PLOT_CALIBRATION_DATA_DETAIL_2CHANNELS , i , xtitle_string_base $
       , time_low , time_high

;----------The common blocks used in this procedure----------------------------

       @CALIBRATION.CB
       @CHANNEL.CB
       @CUT_SETTING.CB
       @LIN_CUT.CB
       @WIDGET_IDS.CB
       @WIDGET_IDS_CAL.CB


       A = FINDGEN(16) * (!pi*2/16.)
       usersym , 0.3*COS(A) , 0.3*SIN(A)

       plot_cal_factor = calibration_factors(*,i)
       j = WHERE(plot_cal_factor GT 0,count_j)
       k = WHERE(plot_cal_factor LT 0,count_k)

       If count_j GT 0 Then Begin

        Plot,calibration_time(j)-calibration_time(0),$
         calibration_factors(j,i),$
         xrange=[time_low,time_high],xs=1,yrange=[0.7,1.3],ys=1,$
         ytitle ='lit / obs',ymargin=[0,0],chars=1.3,xticks=2

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
         xtitle=xtitle_string, $
         ytitle ='lit / obs',ymargin=[0,0],chars=1.3,xticks=2


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
       usersym , 0.3*COS(A) , 0.3*SIN(A), /fill

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


;----------Line with the time position of the current observation--------------

       If (julian_obs GE calibration_time(0)) AND $
          (julian_obs LE calibration_time(n_cal_points-1)) Then Begin $

        Plots,$
         [julian_obs-calibration_time(0),julian_obs-calibration_time(0)],$
         [0.7,1.3],lines=1

       Endif

      End

;----------Pro PLOT_CALIBRATION_DATA_DETAIL_2CHANNELS--------------------------
;----------NCDRT V2.1----------------------------------------------------------
;----------END-----------------------------------------------------------------
