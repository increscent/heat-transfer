# heat-transfer
A simple heat transfer simulator for a Solar Water Heating system

## Purpose
We want to predict the temperature of the water in the main storage tank over discrete time segments based on:
* Variables such as solar irradiance, hot water demand, and electric heater/heat pump usage.
* Constants such as panel array area and thermal efficiency.

The purpose of this simulator is simply to calculate the outputs based on the inputs. It does not suggest optimal inputs, though it can be used to compare the performance of different inputs.

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
T = (1 - L)T₋₁ + (Qₛ + Qₕ) / (C x V) - (<i>d</i>W x D x <i>d</i>t) / V

* T: Temperature of main tank during the time slice (◦C)
* L: Heat loss coefficient of main tank
* T₋₁: Temperature of main tank during the previous time slice (◦C)
* Qₛ: Solar energy transferred to the main tank during the time slice (kWh)
* Qₕ: Energy transferred by the electric heater (EH) or heat pump (HP) to the main tank during the time slice (kWh)
* C: Specific heat capacity of the heat transfer fluid [kW·h/(L◦C)]
* V: Volume of the main tank (L)
* <i>d</i>W: Difference in temperature between the set point and the cold tap water (◦C)
* D: Demand for water at the set point temperature (L/hr)
* <i>d</i>t: The length of the time slice (hours)

There are a few more values to derive. First, the solar energy captured and transferred during a time slice:

Qₛ = I (e x A x N) <i>d</i>t

* I: Solar irradiance during the time slice (kW/m²)
* e: The thermal efficiency of the Solar Thermal Collector (STC)
* A: The area of a panel in the STC array (m²)
* N: The number of panels in the STC array

(Note: If a heat exchanger is used, the thermal efficiency will include the efficiency of the heat exchanger in addition to the efficiency of the STC. A heat exchanger is necessary if the heat transfer fluid is not water. And it may be desirable to use a heat exchanger even with water pipes if you are worried about contaminants entering the STC or plumbing.)

The heat energy transferred to the main tank from the electric heater (EH) or heat pump (HP) during a time slice:

Qₕ = COP x P x <i>d</i>t

* COP: Coefficient of Performance of the EH/HP
* P: Power consumption of the EH/HP (kW)

## Inputs

These are the inputs to the simulator that the user provides:

* Time slice length:
  - Default: 6 minutes (0.1 hr)
* Starting temperature of main tank:
  - Default: 60 ◦C
* Set point temperature (what the building inhabitants expect):
  - Default: 60 ◦C
* Cold tap water temperature:
  - Default: 10 ◦C
* Solar irradiance over time:
  - The user provides a list of tuples (time, irradiance) and the irradiance value is used starting at that time until the time of the next tuple is reached. An irradiance value at time 0 is required.
  - Default: [(0, 1.361 kW/m²)]
* Area of each STC panel:
  - Default: 3 m²
* Number of panels in the STC array:
  - Default: 100
* Thermal efficiency of the STC:
  - This includes the thermal efficiency of the heat exchanger if one is used.
  - Default: 0.5
* Specific heat capacity of the heat transfer fluid:
  - Default: 0.0012 [kW·h/(L◦C)]
* Power supplied to the electric heater or heat pump over time:
  - The user provides a list of tuples (time, power) and the power value is used starting at the time until the time of the next tuple is reached. A power value at time 0 is required.
  - Default: [(0, 0 kW)]
* Coefficient of performance of the electric heater or heat pump
  - Default: 0.75
* Demand for hot water over time:
  - The user provides a list of tuples (time, liters per hour) and the demand value is used starting at the time until the time of the next tuple is reached. A demand value at time 0 is required.
  - Default: [(0, 500 L/hr)]
* Volume of the main tank:
  - Default: 10000 L

## Outputs

* The temperature of the main tank at each time slice:
  - Given as an array of tuples (time, temperature (◦C))

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
