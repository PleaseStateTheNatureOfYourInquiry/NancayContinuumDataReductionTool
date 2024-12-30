
;----------BEGIN---------------------------------------------------------------
;----------Pro NCDRT-----------------------------------------------------------

;-----NANCAY CONTINUUM DATA REDUCTION TOOL-------------------------------------
;-----VERSION 1.0 , 05 - 02 - 2004 --------------------------------------------

;-----This IDL routine is designed to reduce Nancay continuum data for---------
;-----unresolved sources-------------------------------------------------------
;-----Author : Maarten Roos Serote --------------------------------------------
;-----email : roos@oal.ul.pt --------------------------------------------------


   Pro NCDRT

;----------Instructions--------------------------------------------------------

;       If n_params () EQ 0 Then Begin

;        Print , ' ' 
;        Print , ' '

;       Return
;       End

     NCDRT_DISPLAY

    End


;----------Pro NCDRT-----------------------------------------------------------
;----------END-----------------------------------------------------------------


;----------BEGIN---------------------------------------------------------------
;----------Pro NCDTR_DISPLAY---------------------------------------------------


    Pro NCDRT_DISPLAY

;----------LOADOBS-------------------------------------------------------------

     Common NPOINTS , n_points
     Common CHANNELDATA , channel_data
     Common TPEAKLOW , t_peak_low 
     Common TPEAKHIGH , t_peak_high
     Common TOFFSETLOW , t_offset_low 
     Common TOFFSETHIGH , t_offset_high
     Common XDRIFT , x_drift
     Common YDRIFTOBJECT , y_drift_object
     Common LINEAR_OFFSET , linear
     Common SQUARE_OFFSET , square
     Common SCANNUMBER , scan_number
     Common OFFSETCOEFS , offset_coefs
     Common PEAKFLUX , peak_flux
     Common NOISE_LEVEL_PEAK , noise_level_peak
     Common NOISE_LEVEL_OFFSET , noise_level_offset
     Common NOISE_LEVEL_TOTAL , noise_level_total
     Common GAUSSPARM , gauss_parm

     Common BASE_ID , base
     Common CHANNEL_SELECT_ID , channel_select
     Common LOAD_OBS_ID , load_obs
     Common SAVE_RES_ID , save_res
     Common FILE_INFO_ID , file_info
     Common SHOW_LIN_CUT_ID , show_lin_cut
     Common APPLY_LIN_CUT_ID , apply_lin_cut
     Common SHOW_QDR_CUT_ID , show_qdr_cut
     Common APPLY_QDR_CUT_ID , apply_qdr_cut
     Common CURRENT_RES_ID , current_res
     Common PRINT_PLOT_ID , print_plot
     Common SLIDER_OFFSET_LOW_ID , slider_offset_low
     Common SLIDER_OFFSET_HIGH_ID , slider_offset_high
     Common SLIDER_PEAK_LOW_ID , slider_peak_low
     Common SLIDER_PEAK_HIGH_ID , slider_peak_high

;----------Create the base of NANCAY-------------------------------------------

     base = Widget_base(title='Nancay Continuum Data Reduction Tool (V1.0)' , $
                        column=1)


;----------The load and save buttons-------------------------------------------

     load_obs = Widget_button(base, value='Load Data' , $
                                 uvalue = 'LOADOBS')

     save_res = Widget_button(base, value='Save Result' , $
                                 uvalue = 'SAVERES')


;----------The selected values for cutting out the main source-----------------

     file_info = Widget_text(base , xsize=40)

     channel_select = Widget_text(base , xsize=40 , /Editable , $
                                  uvalue='CHANNELSELECT')

     show_lin_cut = Widget_button(base, value='Show Linear Cut' , $
                                  uvalue = 'SHOWLINCUT')

     apply_lin_cut = Widget_button(base, value='Apply Linear Cut' , $
                                  uvalue = 'APPLYLINCUT')

     show_qdr_cut = Widget_button(base, value='Show Quadratic Cut' , $
                                  uvalue = 'SHOWQDRCUT')

     apply_qdr_cut = Widget_button(base, value='Apply Quadratic Cut' , $
                                  uvalue = 'APPLYQDRCUT')


     slider_offset_low = Widget_slider(base, minimum = 0, maximum = 119 , $
        title = 'Offset Low' , uvalue = 'SLIDERCUTLOW', scroll = 1)

     slider_offset_high = Widget_slider(base, minimum = 0, maximum = 119 , $
        title = 'Offset High' , uvalue = 'SLIDERCUTHIGH', scroll = 1)

     slider_peak_low = Widget_slider(base, minimum = 0, maximum = 119 , $
        title = 'Peak Low' , uvalue = 'SLIDERPEAKLOW', scroll = 1)

     slider_peak_high = Widget_slider(base, minimum = 0, maximum = 119 , $
        title = 'Peak High' , uvalue = 'SLIDERPEAKHIGH', scroll = 1)


;----------Show the results with the current selection for the cut values------

     current_res = Widget_text(base , xsize=50 , ysize=10, $
                                 uvalue='CURRENTRES')

;     print_plot = Widget_button(base, value='Print Plot' , $
;                                  uvalue = 'PrintPlot')


;----------The QUIT button-----------------------------------------------------

     button = Widget_button(base , value='quit' , uvalue = 'QUIT')




;---------Realize the widgets--------------------------------------------------

     Widget_control , base , /realize


;----------Open a plot Window to show the fits---------------------------------

     Window , 2 , xsize=450 , ysize=750 , $
              title = 'NCDRT - Results'

     Window , 3 , xsize=450 , ysize=200 , $
              title = 'NCDRT - Scissors'


;----------The Xmanager takes control of the widgets---------------------------

     Xmanager, 'NCDRT_DISPLAY', base , /NO_BLOCK


    End


;----------Pro NCDRT_DISPLAY---------------------------------------------------
;----------END-----------------------------------------------------------------



;----------BEGIN---------------------------------------------------------------
;----------Pro NCDRT_DISPLAY_EVENT---------------------------------------------

    Pro NCDRT_DISPLAY_EVENT , ev


     Common BASE_ID
     Common CHANNEL_SELECT_ID

;----------LOADOBS-------------------------------------------------------------

     Common NPOINTS
     Common CHANNELDATA
     Common TPEAKLOW
     Common TPEAKHIGH
     Common TOFFSETLOW
     Common TOFFSETHIGH
     Common XDRIFT
     Common YDRIFTOBJECT
     Common LINEAR_OFFSET
     Common SQUARE_OFFSET
     Common SCANNUMBER
     Common OFFSETCOEFS
     Common PEAKFLUX
     Common NOISE_LEVEL_PEAK
     Common NOISE_LEVEL_OFFSET
     Common NOISE_LEVEL_TOTAL
     Common GAUSSPARM

     Common LOAD_OBS_ID
     Common SAVE_RES_ID
     Common FILE_INFO_ID
     Common SHOW_LIN_CUT_ID
     Common APPLY_LIN_CUT_ID
     Common SHOW_QDR_CUT_ID
     Common APPLY_QDR_CUT_ID
     Common CURRENT_RES_ID
     Common PRINT_PLOT_ID

     Common SLIDER_OFFSET_LOW_ID
     Common SLIDER_OFFSET_HIGH_ID
     Common SLIDER_PEAK_LOW_ID
     Common SLIDER_PEAK_HIGH_ID
 


     Widget_control , ev.top , Get_uvalue = upper
     Widget_control , ev.id ,  Get_uvalue = uval



;----------Stop the viewing and delete the widgets-----------------------------

     If uval EQ 'QUIT' Then Begin

       Wdelete , 2
       Wdelete , 3
       Widget_control , ev.top , /Destroy

     Endif


;----------Load a file from the directory--------------------------------------

     If uval EQ 'LOADOBS' Then Begin

      channel_files = STRARR(8)

      file_base = DIALOG_PICKFILE(/READ,FILTER='*_f1.fits')

      dump = STRPOS(file_base,'f0')
      file_dir = STRMID(file_base,0,dump)
      scan_number = STRMID(file_base,dump,7)

      check = scan_number + '.res'

      Get_lun , check_lun
      Openr , check_lun , check , error = err
      Close , check_lun
      Free_lun , check_lun

      channel_files(0) =  file_dir + scan_number + '_f1.fits'
      channel_files(1) =  file_dir + scan_number + '_f2.fits'
      channel_files(2) =  file_dir + scan_number + '_f3.fits'
      channel_files(3) =  file_dir + scan_number + '_f4.fits'
      channel_files(4) =  file_dir + scan_number + '_f5.fits'
      channel_files(5) =  file_dir + scan_number + '_f6.fits'
      channel_files(6) =  file_dir + scan_number + '_f7.fits'
      channel_files(7) =  file_dir + scan_number + '_f8.fits'

      channel_dump = READFITS(channel_files(0),/SILENT)
      channel_dump = REFORM(channel_dump)
      dim_channel = SIZE(channel_dump)
      n_points = dim_channel(1)
      channel_data = FLTARR(8,n_points-3)

      channel_data(0,*) = channel_dump(3:n_points-1)

      For i = 1,7 Do Begin

       channel_dump = READFITS(channel_files(i),/SILENT)
       channel_dump = REFORM(channel_dump)
       channel_data(i,*) = channel_dump(3:n_points-1)

      Endfor

      If err EQ 0 Then Begin

       info = 'Result exists: ' + scan_number + ', no. of points: ' $
               + STRCOMPRESS(STRING(n_points))

      Endif Else Begin

       info = scan_number + ', no. of points: ' + STRCOMPRESS(STRING(n_points))
      
      Endelse

      Widget_control , file_info , Set_value = info


      If (n_points EQ 63) Then Begin

       t_offset_low = 15
       t_offset_high = 35
       t_peak_low = 15
       t_peak_high = 35

       Widget_control , slider_offset_low , Set_value = t_offset_low
       Widget_control , slider_offset_high , Set_value = t_offset_high
       Widget_control , slider_peak_low , Set_value = t_peak_low
       Widget_control , slider_peak_high , Set_value = t_peak_high

      Endif


      If (n_points EQ 93) Then Begin

       t_offset_low = 30
       t_offset_high = 45
       t_peak_low = 30
       t_peak_high = 45

       Widget_control , slider_offset_low , Set_value = t_offset_low
       Widget_control , slider_offset_high , Set_value = t_offset_high
       Widget_control , slider_peak_low , Set_value = t_peak_low
       Widget_control , slider_peak_high , Set_value = t_peak_high

      Endif


      If (n_points EQ 123) Then Begin

       t_offset_low = 40
       t_offset_high = 70
       t_peak_low = 40
       t_peak_high = 70

       Widget_control , slider_offset_low , Set_value = t_offset_low
       Widget_control , slider_offset_high , Set_value = t_offset_high
       Widget_control , slider_peak_low , Set_value = t_peak_low
       Widget_control , slider_peak_high , Set_value = t_peak_high

      Endif

      Widget_control , channel_select , Set_value = '1 1 1 1 1 1 1 1'


     Endif


;----------Show the selected cut-----------------------------------------------

     If uval EQ 'SHOWLINCUT' Then Begin

;----------Read the new values of the cut--------------------------------------

      Widget_control , slider_offset_low , Get_value = t_offset_low
      Widget_control , slider_offset_high , Get_value = t_offset_high
      Widget_control , slider_peak_low , Get_value = t_peak_low
      Widget_control , slider_peak_high , Get_value = t_peak_high

      half = FIX((n_points-3-1)/2)

      If t_offset_low GT half Then t_offset_low = half
      If t_offset_high LE half Then t_offset_high = half + 1
      If t_offset_high GT (n_points-3-1) Then t_offset_high = n_points-3-1

      If t_peak_low GT half Then t_peak_low = half
      If t_peak_high LE half Then t_peak_high = half + 1
      If t_peak_high GT (n_points-3-1) Then t_peak_high = n_points-3-1


      x_drift = FINDGEN(n_points-3)

      y_drift = channel_data(0,*)
      x_drift_offset = WHERE((x_drift LT t_offset_low) OR $
                             (x_drift GT t_offset_high)) 

      lin_coef = REGRESS(x_drift(x_drift_offset),y_drift(x_drift_offset),$
                         const=lin_const)

      y_drift_offset = lin_coef(0) * x_drift + lin_const(0)
      y_drift_corrected = y_drift - y_drift_offset

      title_info = 'F = ' + STRCOMPRESS(STRING(lin_coef(0))) + ' * t + ' + $
                            STRCOMPRESS(STRING(lin_const(0)))

      Wset , 3

      Plot,x_drift,y_drift_corrected,xtitle='drift-time (s)',$
           ytitle='Flux (Jy)',title=title_info
      Plots,[t_offset_low,t_offset_low],[-100,100],lines=1
      Plots,[t_offset_high,t_offset_high],[-100,100],lines=1

      Plots,[t_peak_low,t_peak_low],[-100,100],lines=2
      Plots,[t_peak_high,t_peak_high],[-100,100],lines=2

      Plots,[0,n_points-3],[0,0],lines=3

     Endif
      

;----------Show the selected cut-----------------------------------------------

     If uval EQ 'APPLYLINCUT' Then Begin

;----------Read the new values of the cut--------------------------------------

      linear = 1
      square = 0 

      Widget_control , slider_offset_low , Get_value = t_offset_low
      Widget_control , slider_offset_high , Get_value = t_offset_high
      Widget_control , slider_peak_low , Get_value = t_peak_low
      Widget_control , slider_peak_high , Get_value = t_peak_high

      half = FIX((n_points-3-1)/2)

      If t_offset_low GT half Then t_offset_low = half
      If t_offset_high LE half Then t_offset_high = half + 1
      If t_offset_high GT (n_points-3-1) Then t_offset_high = n_points-3-1

      If t_peak_low GT half Then t_peak_low = half
      If t_peak_high LE half Then t_peak_high = half + 1
      If t_peak_high GT (n_points-3-1) Then t_peak_high = n_points-3-1


      offset_coefs = FLTARR(8,3)
      noise_level_offset = FLTARR(8)
      noise_level_peak = FLTARR(8)
      noise_level_total = FLTARR(8)
      peak_flux = FLTARR(8)
      channel_info = STRARR(8)
      guess = fltarr(4)
      gauss_parm = fltarr(8,4)

      x_drift = FINDGEN(n_points-3)

      Wset , 2
      !p.multi = [0,2,4]

      For i = 0,7 Do Begin

       y_drift = channel_data(i,*)
       x_drift_offset = WHERE((x_drift LT t_offset_low) OR $
                              (x_drift GT t_offset_high))

       lin_coef = REGRESS(x_drift(x_drift_offset),y_drift(x_drift_offset),$
                          const=lin_const)
       offset_coefs(i,0) = lin_const(0)
       offset_coefs(i,1) = lin_coef(0)
       offset_coefs(i,2) = 0.

       y_drift_offset = lin_coef(0) * x_drift + lin_const(0)

       y_drift_corrected = y_drift - y_drift_offset


       x_object_index = WHERE((x_drift GE t_peak_low) AND $
                              (x_drift LE t_peak_high))

       x_object = x_drift(x_object_index)
       y_object = y_drift_corrected(x_object_index)


;       peak_estimate = MOMENT(y_object)
;       guess(0) = peak_estimate(0) * 2
       guess(0) = MAX(y_object)
       guess(1) = (t_peak_high + t_peak_low) / 2
       guess(2) = (t_peak_high - t_peak_low) / 2
       guess(3) = 0.


       y_peak_fit = GAUSSFIT(x_object,y_object,a,estimates=guess,nterms=4)

       x_peak = a(1)
       peak_flux(i) = a(0) + a(3)

       gauss_parm(i,0) = a(0)
       gauss_parm(i,1) = a(1)
       gauss_parm(i,2) = a(2)
       gauss_parm(i,3) = a(3)


;----------The Noise level estimates-------------------------------------------

       noise_dump = MOMENT(y_drift_corrected(x_drift_offset))
       noise_level_offset(i) = SQRT(noise_dump(1))

       noise_dump = MOMENT((y_object - y_peak_fit))
       noise_level_peak(i) = SQRT(noise_dump(1))

       n_peak = SIZE(x_object_index)
       n_peak = n_peak(1)
       n_offset = SIZE(x_drift_offset)
       n_offset = n_offset(1)

       noise_dump = FLTARR(n_offset+n_peak)
       noise_dump(0:n_offset-1) = y_drift_corrected(x_drift_offset)
       noise_dump(n_offset:(n_offset+n_peak-1)) = y_object - y_peak_fit

       noise_dump = MOMENT(noise_dump)
       noise_level_total(i) = SQRT(noise_dump(1))

       channel_info(i) = STRCOMPRESS(STRING(i+1)) + '. ' + $
                         STRCOMPRESS(STRING(peak_flux(i))) + ' , ' + $
                         STRCOMPRESS(STRING(noise_level_peak(i))) + ' , ' + $
                         STRCOMPRESS(STRING(noise_level_offset(i))) + ' , ' + $
                         STRCOMPRESS(STRING(noise_level_total(i)))

    
       Plot,x_drift,y_drift_corrected,xtitle='drift-time (s)',$
            ytitle='Flux (Jy)',title='channel ' + STRCOMPRESS(STRING(i+1)),$
            charsize=1.3
       Oplot,x_object,y_peak_fit,lines=2
       Plots,[0,n_points-3],[0,0],lines=1

      Endfor

      !p.multi=0

      current_res_title1 = ' Ch.    Flux  Noise (Peak)  Noise (Offset) Noise (Total)'
      current_res_title2 = '         (Jy)      (Jy)             (Jy)     (Jy)'
      current_res_text = $
       [current_res_title1 , current_res_title2 , $
        channel_info(0) , $
        channel_info(1) , $
        channel_info(2) , $
        channel_info(3) , $
        channel_info(4) , $
        channel_info(5) , $
        channel_info(6) , $
        channel_info(7)]


      Widget_control , current_res , Set_value = current_res_text

     Endif


;----------Show the selected cut-----------------------------------------------

     If uval EQ 'SHOWQDRCUT' Then Begin

;----------Read the new values of the cut--------------------------------------

      Widget_control , slider_offset_low , Get_value = t_offset_low
      Widget_control , slider_offset_high , Get_value = t_offset_high
      Widget_control , slider_peak_low , Get_value = t_peak_low
      Widget_control , slider_peak_high , Get_value = t_peak_high

      half = FIX((n_points-3-1)/2)

      If t_offset_low GT half Then t_offset_low = half
      If t_offset_high LE half Then t_offset_high = half + 1
      If t_offset_high GT (n_points-3-1) Then t_offset_high = n_points-3-1

      If t_peak_low GT half Then t_peak_low = half
      If t_peak_high LE half Then t_peak_high = half + 1
      If t_peak_high GT (n_points-3-1) Then t_peak_high = n_points-3-1


      x_drift = FINDGEN(n_points-3)

      y_drift = channel_data(0,*)
      x_drift_offset = WHERE((x_drift LT t_offset_low) OR $
                             (x_drift GT t_offset_high)) 


      qdr_coef = POLY_FIT(x_drift(x_drift_offset),y_drift(x_drift_offset),2)

      y_drift_offset = qdr_coef(0) + $
                       x_drift * qdr_coef(1) + $
                       x_drift^2 * qdr_coef(2)

      y_drift_corrected = y_drift - y_drift_offset

;      x_peak = -qdr_coef(1) / (2 * qdr_coef(2))
;      y_peak = $
;       qdr_coef(0) + x_peak * qdr_coef(1) + x_peak * x_peak * qdr_coef(2)


      title_info = 'F = ' + STRCOMPRESS(STRING(qdr_coef(2))) + ' * t^2 + ' + $
                          STRCOMPRESS(STRING(qdr_coef(1))) + ' * t + ' + $
                          STRCOMPRESS(STRING(qdr_coef(0)))


      Wset , 3

      Plot,x_drift,y_drift_corrected,xtitle='drift-time (s)',$
           ytitle='Flux (Jy)',title=title_info
      Plots,[t_offset_low,t_offset_low],[-100,100],lines=1
      Plots,[t_offset_high,t_offset_high],[-100,100],lines=1

      Plots,[t_peak_low,t_peak_low],[-100,100],lines=2
      Plots,[t_peak_high,t_peak_high],[-100,100],lines=2

      Plots,[0,n_points-3],[0,0],lines=3

     Endif
      

;----------Show the selected cut-----------------------------------------------

     If uval EQ 'APPLYQDRCUT' Then Begin

;----------Read the new values of the cut--------------------------------------

      linear = 0
      square = 1

      Widget_control , slider_offset_low , Get_value = t_offset_low
      Widget_control , slider_offset_high , Get_value = t_offset_high
      Widget_control , slider_peak_low , Get_value = t_peak_low
      Widget_control , slider_peak_high , Get_value = t_peak_high

      half = FIX((n_points-3-1)/2)

      If t_offset_low GT half Then t_offset_low = half
      If t_offset_high LE half Then t_offset_high = half + 1
      If t_offset_high GT (n_points-3-1) Then t_offset_high = n_points-3-1

      If t_peak_low GT half Then t_peak_low = half
      If t_peak_high LE half Then t_peak_high = half + 1
      If t_peak_high GT (n_points-3-1) Then t_peak_high = n_points-3-1

      offset_coefs = FLTARR(8,3)
      noise_level_offset = FLTARR(8)
      noise_level_peak = FLTARR(8)
      noise_level_total = FLTARR(8)
      peak_flux = FLTARR(8)
      channel_info = STRARR(8)
      guess = fltarr(4)
      gauss_parm = fltarr(8,4)

      x_drift = FINDGEN(n_points-3)

      Wset , 2
      !p.multi = [0,2,4]

      For i = 0,7 Do Begin

       y_drift = channel_data(i,*)
       x_drift_offset = WHERE((x_drift LT t_offset_low) OR $
                              (x_drift GT t_offset_high)) 


       qdr_coef = POLY_FIT(x_drift(x_drift_offset),y_drift(x_drift_offset),2)

       y_drift_offset = qdr_coef(0) + $
                        x_drift * qdr_coef(1) + $
                        x_drift^2 * qdr_coef(2)

       y_drift_corrected = y_drift - y_drift_offset

;       x_peak = -qdr_coef(1) / (2 * qdr_coef(2))
;       y_peak = $
;        qdr_coef(0) + x_peak * qdr_coef(1) + x_peak * x_peak * qdr_coef(2)

       offset_coefs(i,0) = qdr_coef(0)
       offset_coefs(i,1) = qdr_coef(1)
       offset_coefs(i,2) = qdr_coef(2)

       x_object_index = WHERE((x_drift GE t_peak_low) AND $
                              (x_drift LE t_peak_high))

       x_object = x_drift(x_object_index)
       y_object = y_drift_corrected(x_object_index)

;       peak_estimate = MOMENT(y_object)
;       guess(0) = peak_estimate(0) * 2
       guess(0) = MAX(y_object)
       guess(1) = (t_peak_high + t_peak_low) / 2
       guess(2) = (t_peak_high - t_peak_low) / 2
       guess(3) = 0.

       y_peak_fit = GAUSSFIT(x_object,y_object,a,estimates=guess,nterms=4)

       x_peak = a(1)
       peak_flux(i) = a(0) + a(3)

       gauss_parm(i,0) = a(0)
       gauss_parm(i,1) = a(1)
       gauss_parm(i,2) = a(2)
       gauss_parm(i,3) = a(3)


;----------The Noise level estimates-------------------------------------------

       noise_dump = MOMENT(y_drift_corrected(x_drift_offset))
       noise_level_offset(i) = SQRT(noise_dump(1))

       noise_dump = MOMENT((y_object - y_peak_fit))
       noise_level_peak(i) = SQRT(noise_dump(1))

       n_peak = SIZE(x_object_index)
       n_peak = n_peak(1)
       n_offset = SIZE(x_drift_offset)
       n_offset = n_offset(1)

       noise_dump = FLTARR(n_offset+n_peak)
       noise_dump(0:n_offset-1) = y_drift_corrected(x_drift_offset)
       noise_dump(n_offset:(n_offset+n_peak-1)) = y_object - y_peak_fit
       noise_dump = MOMENT(noise_dump)
       noise_level_total(i) = SQRT(noise_dump(1))

       channel_info(i) = STRCOMPRESS(STRING(i+1)) + '. ' + $
                         STRCOMPRESS(STRING(peak_flux(i))) + ' , ' + $
                         STRCOMPRESS(STRING(noise_level_peak(i))) + ' , ' + $
                         STRCOMPRESS(STRING(noise_level_offset(i))) + ' , ' + $
                         STRCOMPRESS(STRING(noise_level_total(i)))

    
       Plot,x_drift,y_drift_corrected,xtitle='drift-time (s)',$
            ytitle='Flux (Jy)',title='channel ' + STRCOMPRESS(STRING(i+1)),$
            charsize=1.3
       Oplot,x_object,y_peak_fit,lines=2
       Plots,[0,n_points-3],[0,0],lines=1

      Endfor

      !p.multi=0

      current_res_title1 = ' Ch.    Flux  Noise (Peak)  Noise (Offset) Noise (Total)'
      current_res_title2 = '         (Jy)      (Jy)             (Jy)     (Jy)'
      current_res_text = $
       [current_res_title1 , current_res_title2 , $
        channel_info(0) , $
        channel_info(1) , $
        channel_info(2) , $
        channel_info(3) , $
        channel_info(4) , $
        channel_info(5) , $
        channel_info(6) , $
        channel_info(7)]

      Widget_control , current_res , Set_value = current_res_text

     Endif



;----------quadratic fits-----------------------------------------------------


;---------gaussian fits--------------------------------------------------------


;        Print,flux
;        ok = 'y'
;        Read,ok,PROMPT=' All OK (y/n)'
;        If ok EQ 'n' Then Begin

;         Read,n_ignore,Prompt='Number of channels to be ignored'
;         For i = 1,n_ignore Do Begin

;          Read,ignore_channel,PROMPT='Channel number'
;          flux(ignore_channel) = 0.0
          
;         Endfor

;        Endif
  
;        Printf,2,scan_number,flux(0),flux(1),flux(2),flux(3),flux(4),flux(5),flux(6),flux(7),$
;               Format='(A6,1x,8(1x,e9.2))'


;       Endwhile



;----------Write the results to a file-----------------------------------------

     If uval EQ 'SAVERES' Then Begin

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

      Get_lun , file_unit

      result_file = scan_number + '.res'

      Openw , file_unit , result_file

      Printf , file_unit , ' '
      Printf , file_unit , ' File : ' + result_file
      Printf , file_unit , ' '
      Printf , file_unit , ' Nancay Continuum Data Reduction Tool V1.0'
      Printf , file_unit , ' '
      Printf , file_unit , ' Drifts: first 3 points (noise tube) not considered'
      Printf , file_unit , ' '
      Printf , file_unit , ' Offset cutting (IDL) ' , $
       t_offset_low , t_offset_high 
      Printf , file_unit , ' '

      If linear EQ 1 Then Begin 

       Printf , file_unit , ' Offset linear fitting y_offset = a * t + b'
       Printf , file_unit , ' '
       Printf , file_unit , '                  a           b'
       Printf , file_unit , Format = '(A,2x,2(E10.3,2x))',' Channel 1:',$
                offset_coefs(0,1) , offset_coefs(0,0)
       Printf , file_unit , Format = '(A,2x,2(E10.3,2x))',' Channel 2:',$
                offset_coefs(1,1) , offset_coefs(1,0)
       Printf , file_unit , Format = '(A,2x,2(E10.3,2x))',' Channel 3:',$
                offset_coefs(2,1) , offset_coefs(2,0)
       Printf , file_unit , Format = '(A,2x,2(E10.3,2x))',' Channel 4:',$
                offset_coefs(3,1) , offset_coefs(3,0)
       Printf , file_unit , Format = '(A,2x,2(E10.3,2x))',' Channel 5:',$
                offset_coefs(4,1) , offset_coefs(4,0)
       Printf , file_unit , Format = '(A,2x,2(E10.3,2x))',' Channel 6:',$
                offset_coefs(5,1) , offset_coefs(5,0)
       Printf , file_unit , Format = '(A,2x,2(E10.3,2x))',' Channel 7:',$
                offset_coefs(6,1) , offset_coefs(6,0)
       Printf , file_unit , Format = '(A,2x,2(E10.3,2x))',' Channel 8:',$
                offset_coefs(7,1) , offset_coefs(7,0)
      
      Endif

      If square EQ 1 Then Begin 

       Printf , file_unit , ' Offset quadratic fitting: y_offset = a * t^2 + b * t + c'
       Printf , file_unit , ' '
       Printf , file_unit , '                  a           b           c'
       Printf , file_unit , Format = '(A,2x,3(E10.3,2x))',' Channel 1:',$
                offset_coefs(0,0) , offset_coefs(0,1) , offset_coefs(0,2)
       Printf , file_unit , Format = '(A,2x,3(E10.3,2x))',' Channel 2:',$
                offset_coefs(1,0) , offset_coefs(1,1) , offset_coefs(1,2)
       Printf , file_unit , Format = '(A,2x,3(E10.3,2x))',' Channel 3:',$
                offset_coefs(2,0) , offset_coefs(2,1) , offset_coefs(2,2)
       Printf , file_unit , Format = '(A,2x,3(E10.3,2x))',' Channel 4:',$
                offset_coefs(3,0) , offset_coefs(3,1) , offset_coefs(3,2)
       Printf , file_unit , Format = '(A,2x,3(E10.3,2x))',' Channel 5:',$
                offset_coefs(4,0) , offset_coefs(4,1) , offset_coefs(4,2)
       Printf , file_unit , Format = '(A,2x,3(E10.3,2x))',' Channel 6:',$
                offset_coefs(5,0) , offset_coefs(5,1) , offset_coefs(5,2)
       Printf , file_unit , Format = '(A,2x,3(E10.3,2x))',' Channel 7:',$
                offset_coefs(6,0) , offset_coefs(6,1) , offset_coefs(6,2)
       Printf , file_unit , Format = '(A,2x,3(E10.3,2x))',' Channel 8:',$
                offset_coefs(7,0) , offset_coefs(7,1) , offset_coefs(7,2)

      Endif

      Printf , file_unit , ' '
      Printf , file_unit , ' Peak cutting (IDL) ' ,  $
       t_peak_low , t_peak_high 
      Printf , file_unit , ' '
      Printf , file_unit , ' '
      Printf , file_unit , ' Fit to the peaks is Gaussian:'
      Printf , file_unit , '  a = height, t0 = center, w = width and c = constant level'
      Printf , file_unit , '  Peak flux = a + c'
      Printf , file_unit , ' '

      Printf , file_unit , ' ch.    Flux   Noise    Noise    Noise      a       t0        w       c '
      Printf , file_unit , '               (peak)  (offset) (total)'
      Printf , file_unit , '        (Jy)    (Jy)     (Jy)     (Jy)'

      Printf , file_unit , 'C_END'

      For i = 1 , 8 Do Begin

       If channels(i-1) EQ 1 Then Begin

        Printf , file_unit , Format = '(1x,I1,2x,8(F8.5,1x))' , i , $
         peak_flux(i-1) , noise_level_peak(i-1) , noise_level_offset(i-1) , $
         noise_level_total(i-1) , gauss_parm(i-1,0) , gauss_parm(i-1,1) , $
         gauss_parm(i-1,2) , gauss_parm(i-1,3)

       Endif Else Begin

        Printf , file_unit , Format = '(1x,I1,2x,8(F8.5,1x))' , i , $
         -1.0 , -1.0 , -1.0 , -1.0 , -1.0 , -1.0 , -1.0 , -1.0

       Endelse

      Endfor

     Close , file_unit

     Free_lun , file_unit

     Endif


    End


;----------Pro NCDRT_DISPLAY_EVENT--------------------------------------------
;----------END-----------------------------------------------------------------

 



