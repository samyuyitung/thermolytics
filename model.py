# AN ANNOTATED FORTRAN PROGRAM FOR A CORE-SHELL MODEL OP HUMAN TEMPERATURE REGULATION

# The environmental factors and the type of activity are defined in an initial "read" statement by metabolic_rate, mech_efficiency, heat_transfer_coef, clothing_insul, temp_air, rel_humidity
# A "do" statement may be used for temp_air or rel_humidity or both

# Standard man = 81.7 kg, 1.77 m, 2.0 sq.m dubois area
# In program:
	# 1.163 = conv. factor kcal/hr to watts
	# 1.163 = specific heat of blood in whr/(lc)
	# 0.7 = latent heat in watthr/g
	# 0.97 = specific heat of body in whr/(kgc)
	# 2.2 = lewis relation

# ACTUAL INPUTS
	# Metabolic rate metabolic_rate
	# Work accomplished
	# Combined heat transfer coefficient heat_transfer_coef
	# Convective heat transfer coefficient conv_heat_transfer_coef
	# Insulation of normal clothing used
	# Dry bulb (air) temperature temp_air
	# Relative humidity rel_humidity

# ACTUAL OUTPUTS
	# Average skin temperature temp_skin_avg
	# Core temperature temp_core
	# Regulatory sweating ESRW
	# Skin wettedness wrsw

import math

# Input parameters
mass_body = 81.7
temp_skin_avg = 30.0	# skin temperature (clothed body surface temp)
heart_rate_rest = 60.0	# resting heart rate (BPM?)
heart_rate = 160.0	# heart rate (BPM?)
rel_humidity = 0.65	# relative humidity (%)
temp_air = 25.0		# air temperature (C)

def get_sat_vap_pressure(temp_air):		# saturated vapor pressure (mmHg)
	p = 0.61121*math.exp((18.678 - temp_air/234.5)*(temp_air/(257.14 + temp_air)))
	p_mmhg = p*760/101.325		# conversion from kPa to mmHg
	return p_mmhg

def get_temp_core(mass_body, temp_skin_avg, heart_rate_rest, heart_rate, rel_humidity, temp_air):

	# Initial conditions - Body in physiol. thermal equilibrium
	mass_skin = 0.04*mass_body
	mass_core = 0.96*mass_body
	metabolic_rate = 1.0 - 0.0858*(heart_rate_rest - heart_rate)	# metabolic rate or M = 5(291) from Table 1
	skin_temp = 34.1	# OPTIONAL: skin temperature
	temp_core = 36.6	# core temperature
	heat_evap_res = 0.0023*metabolic_rate*(44.0 - rel_humidity*get_sat_vap_pressure(temp_air))	# respired vapor loss (W/m^2)
	mech_efficiency = 0.2
	work = mech_efficiency * metabolic_rate 			# mechanical efficiency (W/M) * metabolic rate ~ 0.2 * metabolic_rate

	# More initial stuff
	bar_pressure = 760.0		# barometric/atmospheric pressure (mmHg)
	rad_exchange_coef = 0.72*5.670367*10**(-8)*0.98*4*((temp_skin_avg + temp_skin_avg)/2 + 273.15)**3			# FIX: linear radiation exchange coefficient (W/m^2C)
	conv_heat_transfer_coef = max(3.0*(bar_pressure/760.0)**0.53,2.38*(temp_skin_avg - temp_air)**0.25)			# convection heat transfer coefficient (W/m^2C) # 5.66*(metabolic_rate/58.2 - 0.85)**0.39,
	heat_transfer_coef = rad_exchange_coef + conv_heat_transfer_coef				# combined heat transfer coefficient (W/m^2C)
	heat_evap_diff = 5.0			# skin vapor loss by diffusion (W/m^2)
	heat_evap = heat_evap_res + heat_evap_diff	# total evaporative heat loss (W/m^2)
	heat_evap_sweat = 0.0			# skin evaporative loss by regulatory sweating (W/m^2)
	heat_unevap_sweat = 0.0			# unevaporated sweat from skin surface

	wrsw = 0.0			# 
	# rad_exchange_coef = 5.23			# OPTIONAL: linear radiation exchnage coefficient
	# conv_heat_transfer_coef = heat_transfer_coef - rad_exchange_coef		# OPTIONAL: convection heat transfer coefficient

	# For next two cards see ref.21
	clothing_insul = 0.1			# insulation of clothing (clo)
	clothing_factor = 1.0/(1.0 + 0.155*heat_transfer_coef*clothing_insul)		# clothing thermal efficiency factor
	clothing_perm_factor = 1.0/(1.0 + 0.143*(heat_transfer_coef - rad_exchange_coef)*clothing_insul)		# permeation efficiency factor for clothing

	# conductance_min = min. conductance in w/(sq.m*c)
	conductance_min = 5.28

	# blood_flow_skin_norm = normal skin blood flow L/(sq.m*hr)
	blood_flow_skin_norm = 6.3
	blood_flow_skin = blood_flow_skin_norm
	time = 0.0

	# Heat balance equations for passive system
	while (time - 1.00) < 0:

		# Heat flow from core to skin to air in w/sq.m
		heat_storage_core = metabolic_rate - (temp_core - temp_skin_avg)*(conductance_min + 1.163*blood_flow_skin) - heat_evap_res - work
		heat_storage_skin = (temp_core - temp_skin_avg)*(conductance_min + 1.163*blood_flow_skin) - heat_transfer_coef*(temp_skin_avg - temp_air)*clothing_factor - (heat_evap - heat_evap_res)

		# Thermal capactiy of skin shell for av. man in w.hr/c
		therm_cap_skin = 0.97*mass_skin

		# Thermal capacity of core for av. man in w.hr/c
		therm_cap_core = 0.97*mass_core

		# Change in skin shell and core in deg. C per hour
		change_in_temp_skin = (heat_storage_skin*2.0)/therm_cap_skin
		change_in_temp_core = (heat_storage_core*2.0)/therm_cap_core

		# Note unit of time is one hour
		change_in_time = 1.0/60.0

		# To adjust integration over small steps in change_in_temp_skin and change_in_temp_core
		un = abs(change_in_temp_skin)
		if (un*change_in_time - 0.1) > 0:
			change_in_time = 0.1/un
		un = abs(change_in_temp_core)
		if (un*change_in_time - 0.1) > 0:
			change_in_time = 0.1/un
		time = time + change_in_time
		temp_skin_avg = temp_skin_avg + change_in_temp_skin*change_in_time
		temp_core = temp_core + change_in_temp_core*change_in_time
		print temp_core

		# Control system
		# Defining sig. for controls for vaso-constrict.-dialation
		# From skin
		signal_skin = (temp_skin_avg - 34.1)
		if (signal_skin) <= 0:
			signal_cold_skin = -signal_skin
			signal_warm_skin = 0.0
		else:
			signal_cold_skin = 0.0
			signal_warm_skin = signal_skin
		# From core
		signal_core = (temp_core - 36.6)
		if (signal_core) <= 0:
			signal_cold_core = -signal_core
			signal_warm_core = 0.0
		else:
			signal_warm_core = signal_core
			signal_cold_core = 0.0
		# Factors 0.5(cold) and 75.(warm) govern stric and dilat
		stric = 0.5*signal_cold_skin
		dilat = 75.0*signal_warm_core
		# Control of skin blood flow
		blood_flow_skin = (blood_flow_skin_norm + dilat)/(1.0 + stric)
		# Control of reg. sweating
		# mass_roc_sweat in G/(SQ.M*heart_rate)
		# During rest
		if (metabolic_rate - 60.0) <= 0:
			mass_roc_sweat = 100.0*signal_warm_core*signal_warm_skin
		# During exercise
		else:
			mass_roc_sweat = 250.0*signal_warm_core + 100.0*signal_warm_core*signal_warm_skin
		# Bullard van Beaumont effect, modified by Stolwijk
		heat_evap_sweat = 0.7*mass_roc_sweat*2.0**((temp_skin_avg - 34.1)/3.0)
		# To avoid impossible solutions max. mass_roc_sweat is 16 g/min
		if (heat_evap_sweat - 500.0) <= 0:
			wrsw = wrsw + (heat_evap_sweat*2.0/(0.7*100.0))*change_in_time
			heat_evap_max = 2.2*conv_heat_transfer_coef*(get_sat_vap_pressure(temp_skin_avg) - rel_humidity*get_sat_vap_pressure(temp_air))*clothing_perm_factor
			wetness_sweat = heat_evap_sweat/heat_evap_max
			wetness = (0.06*0.94*wetness_sweat)

			# Note total evaporative loss from skin is wetness*heat_evap_max
			heat_evap_diff = wetness*heat_evap_max - heat_evap_sweat
			heat_evap = heat_evap_res + heat_evap_sweat + heat_evap_diff
			if (heat_evap_sweat - heat_evap_max) > 0:
				heat_evap = heat_evap_res + heat_evap_max
				heat_evap_sweat = heat_evap_max
				heat_evap_diff = 0.0
				wetness_sweat = 1.0
				wetness = 1.0

			# To calculate quasi-equilibrium after one hour exposure
			# The exposure time (1.00) can be changed up or down to 0.25
			dry = heat_transfer_coef*(temp_skin_avg-temp_air)*clothing_factor
			# Store in watt per sq.meter STORC in deg.C per hour
			# Store is also equal to heat_storage_skin plus heat_storage_core
			heat_storage = metabolic_rate - heat_evap - dry - work
			temp_body_roc = heat_storage*2.0/(mass_body*0.97)
			
			# Calculation twet from temp_air and rel_humidity
			wet_bulb_temp = temp_air
			en = -1.0
			while en < 0:
				# CHECK the X on the new line
				en = rel_humidity - (get_sat_vap_pressure(wet_bulb_temp) - 0.00066*760.0*(temp_air - wet_bulb_temp)*(1.0+0.00115*wet_bulb_temp))/get_sat_vap_pressure(temp_air)
				if en < 0:
					wet_bulb_temp = wet_bulb_temp - 0.10

			# Calculate temp_dew
			temp_dew = -10.0
			d_dew = -1.0
			while d_dew < 0:
				xn = get_sat_vap_pressure(wet_bulb_temp) - (temp_air - wet_bulb_temp)/2.0
				d_dew = (get_sat_vap_pressure(temp_dew) - xn)
				if d_dew < 0:
					temp_dew = temp_dew + 0.10
			
			# The Nishi Environmental equations
			xa = clothing_factor*heat_transfer_coef
			xb = 2.2*1.4*conv_heat_transfer_coef*clothing_perm_factor
			toh = (xa*temp_air + wetness*xb*temp_dew)/(xa + wetness*xb)

			# Add cards for printout of heat exchange data
			# Add cards for printout of physiological data

	return temp_core

get_temp_core(mass_body,temp_skin_avg,heart_rate_rest,heart_rate,rel_humidity,temp_air)
