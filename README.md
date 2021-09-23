# heat-transfer
A simple heat transfer simulator for a Solar Water Heating system

## Purpose
We want to predict the temperature of the water in the main storage tank over discrete time segments based on:
* Variables such as solar irradiance, hot water usage, and electric heater/heat pump usage.
* Constants such as panel array area and thermal efficiency.

## Solar Water Heating (SWH) System

For this simulator I assume a system similar to the one described by Li et al. (see [sources](#sources)). However, it is simpler because I only consider the main tank (no kitchen tank) and the heat pump could also be an electric heater. Here's the layout:

```
       -----------------------------------------------------         
       |                                                   |         
    -------                                                |         
    |||||||                                                |         
    |||||||                                                |         
    |||||||                                                |         
    |||||||                                           _____|______   
    |||||||                            -----------    |          |   
    |||||||                            | Electric|    |          |   
    |||||||                            | Water   |----|          |   
    |||||||                            | Heater  |    |  Main    |   
    -------                            |  or     |    |  Tank    |   
    Flat Plate                         | Heat    |----|          |   
       or                              | Pump    |    |          |   
    Evacuated                          -----------    |          |   
     Tube                                             |          |   
    Collector                                         |          |   
       |                                              |__________|   
       |                          Circulator Pump          ||        
       -----------------------------( < )--------------------        
```

## Equations

These equations are similar (and in some cases identical) to those given by Li et al. (see [sources](#sources)).

Temperature of the main tank during a discrete time segment:
T<sup>M</sup><sub>h</sub> = (1 - l<sup>M</sup>)T<sup>M</sup><sub>h-1</sub> + (Q<sup>s</sup><sub>h<sub> + Q<sup>eh</sup><sub>h</sub>) / (CV) - (<i>d</i>T<sup>w</sup><sub>h</sub> D<sup>w</sup><sub>h</sub>) / V

T<sup>M</sup><sub>h</sub>: Temperature of main tank during time slice h
l<sup>M</sup>: Heat loss coefficient of main tank
T<sup>M</sup><sub>h-1</sub>: Temperature of main tank during previous time slice
Q<sup>s</sup><sub>h<sub>: Solar energy transferred to the main tank during time slice h
Q<sup>eh</sup><sub>h<sub>: Energy transferred by electric heater to the main tank during time slice h
C: Specific heat of the heat transfer fluid
V: Volume of the main tank
<i>d</i>T<sup>w</sup><sub>h</sub>: Difference in temperature between the set point and the cold tap water
D<sup>w</sup><sub>h</sub>: Demand in liters for water during time slice h at the set point temperature

## Sources
I used the following sources to understand the terminology and components of SWH systems:
* [https://en.wikipedia.org/wiki/Heat_transfer](https://en.wikipedia.org/wiki/Heat_transfer)
* [https://en.wikipedia.org/wiki/Solar_water_heating](https://en.wikipedia.org/wiki/Solar_water_heating)
* [https://www.energy.gov/energysaver/solar-water-heaters](https://www.energy.gov/energysaver/solar-water-heaters)
* [https://www.energy.gov/energysaver/heat-exchangers-solar-water-heating-systems](https://www.energy.gov/energysaver/heat-exchangers-solar-water-heating-systems)
* [https://www.energy.gov/energysaver/solar-water-heaters/heat-transfer-fluids-solar-water-heating-systems](https://www.energy.gov/energysaver/solar-water-heaters/heat-transfer-fluids-solar-water-heating-systems)

I used this paper to understand the variables and equations involved in SWH systems:
```W. Li, K. Thirugnanam, W. Tushar, C. Yuen, K. T. Chew and S. Tai, "Improving the Operation of Solar Water Heating Systems in Green Buildings via Optimized Control Strategies," in IEEE Transactions on Industrial Informatics, vol. 14, no. 4, pp. 1646-1655, April 2018, doi: 10.1109/TII.2018.2797018.```

Here's a copy: [Improving the Operation of Solar Water Heating Systems in Green Buildings...](notes/improving-solar-water-heating-systems.pdf)
