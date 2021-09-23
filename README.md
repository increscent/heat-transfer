# heat-transfer
A simple heat transfer simulator for a Solar Water Heating system

## Purpose
We want to predict the temperature of the water in the main storage tank over discrete time segments based on:
* Variables such as solar irradiance, hot water demand, and electric heater/heat pump usage.
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
T = (1 - L)T₋₁ + (Qₛ + Qₕ) / (C x V) - (<i>d</i>W x D) / V

* T: Temperature of main tank during the time slice
* L: Heat loss coefficient of main tank
* T₋₁: Temperature of main tank during the previous time slice
* Qₛ: Solar energy transferred to the main tank during the time slice
* Qₕ: Energy transferred by the electric heater (EH) or heat pump (HP) to the main tank during the time slice
* C: Specific heat of the heat transfer fluid
* V: Volume of the main tank
* <i>d</i>W: Difference in temperature between the set point and the cold tap water
* D: Demand in liters for water at the set point temperature during the time slice

There are a few more values to derive. First, the solar energy captured and transferred during a time slice:

Qₛ = I (e x A x N) <i>d</i>t

* I: Solar irradiance (kW/m²) during the time slice
* e: The thermal efficiency of the Solar Thermal Collector (STC)
* A: The area of a panel in the STC array
* N: The number of panels in the STC array
* <i>d</i>t: The length of the time slice

(Note: If a heat exchanger is used, the thermal efficiency will include the efficiency of the heat exchanger in addition to the efficiency of the STC. A heat exchanger is necessary if the heat transfer fluid is not water. And it may be desirable to use a heat exchanger even with water pipes if you are worried about contaminants entering the STC or plumbing.)

The heat energy transferred to the main tank from the electric heater (EH) or heat pump (HP) during a time slice:

Qₕ = COP x P x <i>d</i>t

* COP: Coefficient of Performance of the EH/HP
* P: Power consumption of the EH/HP

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
