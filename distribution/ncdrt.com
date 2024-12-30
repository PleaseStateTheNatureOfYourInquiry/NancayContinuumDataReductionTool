.run ncdrt.pro
.run ncdrt_display.pro  
.run ncdrt_display_event.pro
.run load_obs.pro
.run read_list.pro
.run read_res.pro
.run read_res_av.pro
.run save_res.pro
.run show_lin_cut.pro
.run apply_lin_cut.pro
.run write_result_2_ps.pro

.run apply_calibration.pro
.run calibration_display.pro
.run calibration_display_event.pro
.run delete_from_cal_table.pro
.run plot_calibration_data.pro
.run plot_calibration_data_ps.pro
.run read_cal_table.pro
.run write_2_cal_table.pro
.run radio_flux.pro

.run sky_apply_calibration.pro
.run sky_apply_lin_cut.pro
.run sky_load_obs.pro
.run sky_subtract_display.pro
.run sky_subtract_display_event.pro

