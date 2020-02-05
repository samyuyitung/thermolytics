//
//  TwoNode.swift
//  Thermolytic
//
//  Created by Sam Yuyitung on 2019-11-27.
//  Copyright © 2019 Sam Yuyitung. All rights reserved.
//
 
// AN ANNOTATED FORTRAN PROGRAM FOR A CORE-SHELL MODEL OP HUMAN TEMPERATURE REGULATION
// The environmental factors and the type of activity are defined in an initial "read" statement by metabolic_rate, mech_efficiency, heat_transfer_coef, clothing_insul, temp_air, rel_humidity
// A "do" statement may be used for temp_air or rel_humidity or both
// Standard man = 81.7 kg, 1.77 m, 2.0 sq.m dubois area
//
// In program:
// 1.163 = conv. factor kcal/hr to watts
// 1.163 = specific heat of blood in whr/(lc)
// 0.7 = latent heat in watthr/g
// 0.97 = specific heat of body in whr/(kgc)
// 2.2 = lewis relation
//
// ACTUAL INPUTS
// Metabolic rate metabolic_rate
// Work accomplished
// Combined heat transfer coefficient heat_transfer_coef
// Convective heat transfer coefficient conv_heat_transfer_coef
// Insulation of normal clothing used
// Dry bulb (air) temperature temp_air
// Relative humidity rel_humidity
//
// ACTUAL OUTPUTS
// Average skin temperature temp_skin_avg
// Core temperature temp_core
// Regulatory sweating ESRW
// Skin wettedness wrsw


import Foundation

// Input parameters
//var mass_body = 81.7
//var temp_skin_avg = 30.0    // skin temperature (clothed body surface temp)
//var heart_rate_rest = 60.0  // resting heart rate (BPM?)
//var heart_rate = 160.0      // heart rate (BPM?)
//var rel_humidity = 0.65     // relative humidity (%)
//var temp_air = 25.0         // air temperature (C)

class TwoNode {
    
    struct Fields {
        var bodyMass: Double
        var averageSkinTemp: Double
        var restingHeartRate: Double
        var heartRate: Double
        var ambientHumidity: Double
        var ambientTemperature: Double
    }

    
    static func get_sat_vap_pressure(temp: Double) -> Double {     // saturated vapor pressure (mmHg)
        let p = 0.61121*pow(M_E,(18.678 - temp/234.5)*(temp/(257.14 + temp)))
        return p*760/101.325                              // conversion from kPa to mmHg
    }

    static func getCoreTemp(mass_body: Double, temp_skin_avg: Double, heart_rate_rest: Double, heart_rate: Double, rel_humidity: Double, temp_air: Double) -> Double {
        
        // Initial conditions - Body in physiol. thermal equilibrium
        let mass_skin = 0.04*mass_body
        let mass_core = 0.96*mass_body
        let metabolic_rate = 1.0 - 0.0858*(heart_rate_rest - heart_rate)    // metabolic rate or M = 5(291) from Table 1
        var temp_core = 36.6                                // core temperature
        let heat_evap_res = 0.0023*metabolic_rate*(44.0 - rel_humidity*get_sat_vap_pressure(temp: temp_air))    // respired vapor loss (W/m^2)
        let mech_efficiency = 0.2
        let work = mech_efficiency * metabolic_rate         // mechanical efficiency (W/M) * metabolic rate ~ 0.2 * metabolic_rate
        
        // More initial stuff
        let bar_pressure = 760.0            // barometric/atmospheric pressure (mmHg)
        let rad_exchange_coef = 0.72*5.670367*pow(10,-8)*0.98*4*pow(((temp_skin_avg + temp_skin_avg)/2 + 273.15),3)            // FIX: linear radiation exchange coefficient (W/m^2C)
        let conv_heat_transfer_coef = max(3.0*pow((bar_pressure/760.0),0.53),2.38*pow((temp_skin_avg - temp_air),0.25))            // convection heat transfer coefficient (W/m^2C) // 5.66*(metabolic_rate/58.2 - 0.85)**0.39,
        let heat_transfer_coef = rad_exchange_coef + conv_heat_transfer_coef            // combined heat transfer coefficient (W/m^2C)
        var heat_evap_diff = 5.0            // skin vapor loss by diffusion (W/m^2)
        var heat_evap = heat_evap_res + heat_evap_diff    // total evaporative heat loss (W/m^2)
        var heat_evap_sweat = 0.0            // skin evaporative loss by regulatory sweating (W/m^2)
    
        // rad_exchange_coef = 5.23            // OPTIONAL: linear radiation exchnage coefficient
        // conv_heat_transfer_coef = heat_transfer_coef - rad_exchange_coef        // OPTIONAL: convection heat transfer coefficient
        
        // For next two cards see ref.21
        let clothing_insul = 0.1            // insulation of clothing (clo)
        let clothing_factor = 1.0/(1.0 + 0.155*heat_transfer_coef*clothing_insul)        // clothing thermal efficiency factor
        let clothing_perm_factor = 1.0/(1.0 + 0.143*(heat_transfer_coef - rad_exchange_coef)*clothing_insul)        // permeation efficiency factor for clothing
        
        // conductance_min = min. conductance in w/(sq.m*c)
        let conductance_min = 5.28
        
        // blood_flow_skin_norm = normal skin blood flow L/(sq.m*hr)
        let blood_flow_skin_norm = 6.3
        var blood_flow_skin = blood_flow_skin_norm
        
        var time = 0.0
        
        // Initialize variables for below
        var heat_storage_skin = 0.0
        var heat_storage_core = 0.0
        var therm_cap_skin = 0.0
        var therm_cap_core = 0.0
        var change_in_temp_skin = 0.0
        var change_in_temp_core = 0.0
        var change_in_time = 0.0
        var un = 0.0
        var signal_skin = 0.0
        var signal_cold_skin = 0.0
        var signal_warm_skin = 0.0
        var signal_core = 0.0
        var signal_cold_core = 0.0
        var signal_warm_core = 0.0
        var stric = 0.0
        var dilat = 0.0
        var mass_roc_sweat = 0.0
        var heat_evap_max = 0.0
        var wetness_sweat = 0.0
        var wetness = 0.0
        var dry = 0.0
        var heat_storage = 0.0
        var temp_body_roc = 0.0
        var wet_bulb_temp = 0.0
        var en = 0.0
        var temp_dew = 0.0
        var d_dew = 0.0
        var xn = 0.0
        var xa = 0.0
        var xb = 0.0
        var toh = 0.0
        var temp_skin = temp_skin_avg
        var wrsw = 0.0
        
        // Heat balance equations for passive system
        while time < 1.00 {
            
            // Heat flow from core to skin to air in w/sq.m
            heat_storage_core = metabolic_rate - (temp_core - temp_skin)*(conductance_min + 1.163*blood_flow_skin) - heat_evap_res - work
            heat_storage_skin = (temp_core - temp_skin)*(conductance_min + 1.163*blood_flow_skin) - heat_transfer_coef*(temp_skin - temp_air)*clothing_factor - (heat_evap - heat_evap_res)
            
            // Thermal capactiy of skin shell for av. man in w.hr/c
            therm_cap_skin = 0.97*mass_skin
            
            // Thermal capacity of core for av. man in w.hr/c
            therm_cap_core = 0.97*mass_core
            
            // Change in skin shell and core in deg. C per hour
            change_in_temp_skin = (heat_storage_skin*2.0)/therm_cap_skin
            change_in_temp_core = (heat_storage_core*2.0)/therm_cap_core
            
            // Note unit of time is one hour
            change_in_time = 1.0/60.0
            
            // To adjust integration over small steps in change_in_temp_skin and change_in_temp_core
            un = abs(change_in_temp_skin)
            if (un*change_in_time - 0.1) > 0 {
                change_in_time = 0.1/un
            }
            un = abs(change_in_temp_core)
            if (un*change_in_time - 0.1) > 0 {
                change_in_time = 0.1/un
            }
            time = time + change_in_time
            temp_skin = temp_skin + change_in_temp_skin*change_in_time
            temp_core = temp_core + change_in_temp_core*change_in_time
            
            // Control system
            // Defining sig. for controls for vaso-constrict.-dialation from skin
            signal_skin = (temp_skin - 34.1)
            signal_cold_skin = 0.0
            signal_warm_skin = 0.0
            if (signal_skin) <= 0 {
                signal_cold_skin = -signal_skin
                signal_warm_skin = 0.0
            }
            else {
                signal_cold_skin = 0.0
                signal_warm_skin = signal_skin
            }
            // From core
            signal_core = (temp_core - 36.6)
            signal_cold_core = 0.0
            signal_warm_core = 0.0
            if (signal_core) <= 0 {
                signal_cold_core = -signal_core
                signal_warm_core = 0.0
            }
            else {
                signal_warm_core = signal_core
                signal_cold_core = 0.0
            }
            // Factors 0.5(cold) and 75.(warm) govern stric and dilat
            stric = 0.5*signal_cold_skin
            dilat = 75.0*signal_warm_core
            // Control of skin blood flow
            blood_flow_skin = (blood_flow_skin_norm + dilat)/(1.0 + stric)
            // Control of reg. sweating
            // mass_roc_sweat in G/(SQ.M*heart_rate)
            // During rest
            if (metabolic_rate - 60.0) <= 0 {
                mass_roc_sweat = 100.0*signal_warm_core*signal_warm_skin
            }
                // During exercise
            else {
                mass_roc_sweat = 250.0*signal_warm_core + 100.0*signal_warm_core*signal_warm_skin
            }
            // Bullard van Beaumont effect, modified by Stolwijk
            heat_evap_sweat = 0.7*mass_roc_sweat*pow(2.0,((temp_skin - 34.1)/3.0))
            // To avoid impossible solutions max. mass_roc_sweat is 16 g/min
            if (heat_evap_sweat - 500.0) <= 0 {
                wrsw = wrsw + (heat_evap_sweat*2.0/(0.7*100.0))*change_in_time
                heat_evap_max = 2.2*conv_heat_transfer_coef*(get_sat_vap_pressure(temp: temp_skin) - rel_humidity*get_sat_vap_pressure(temp: temp_air))*clothing_perm_factor
                wetness_sweat = heat_evap_sweat/heat_evap_max
                wetness = (0.06*0.94*wetness_sweat)
                
                // Note total evaporative loss from skin is wetness*heat_evap_max
                heat_evap_diff = wetness*heat_evap_max - heat_evap_sweat
                heat_evap = heat_evap_res + heat_evap_sweat + heat_evap_diff
                if (heat_evap_sweat - heat_evap_max) > 0 {
                    heat_evap = heat_evap_res + heat_evap_max
                    heat_evap_sweat = heat_evap_max
                    heat_evap_diff = 0.0
                    wetness_sweat = 1.0
                    wetness = 1.0
                }
                
                // To calculate quasi-equilibrium after one hour exposure
                // The exposure time (1.00) can be changed up or down to 0.25
                dry = heat_transfer_coef*(temp_skin-temp_air)*clothing_factor
                // Store in watt per sq.meter STORC in deg.C per hour
                // Store is also equal to heat_storage_skin plus heat_storage_core
                heat_storage = metabolic_rate - heat_evap - dry - work
                temp_body_roc = heat_storage*2.0/(mass_body*0.97)
                
                // Calculation twet from temp_air and rel_humidity
                wet_bulb_temp = temp_air
                en = -1.0
                while en < 0 {
                    // CHECK the X on the new line
                    let sat_vap_pressure_air = get_sat_vap_pressure(temp: temp_air)
                    en = rel_humidity - (get_sat_vap_pressure(temp: wet_bulb_temp) - 0.00066*760.0*(temp_air - wet_bulb_temp)*(1.0+0.00115*wet_bulb_temp))/sat_vap_pressure_air
                    if en < 0 {
                        wet_bulb_temp = wet_bulb_temp - 0.10
                    }
                }
                
                // Calculate temp_dew
                temp_dew = -10.0
                d_dew = -1.0
                while d_dew < 0 {
                    xn = get_sat_vap_pressure(temp: wet_bulb_temp) - (temp_air - wet_bulb_temp)/2.0
                    d_dew = (get_sat_vap_pressure(temp: temp_dew) - xn)
                    if d_dew < 0 {
                        temp_dew = temp_dew + 0.10
                    }
                }
                
                // The Nishi Environmental equations
                xa = clothing_factor*heat_transfer_coef
                xb = 2.2*1.4*conv_heat_transfer_coef*clothing_perm_factor
                toh = (xa*temp_air + wetness*xb*temp_dew)/(xa + wetness*xb)
                
                // Add cards for printout of heat exchange data
                // Add cards for printout of physiological data
            }
        }
        return temp_core
    }
}
