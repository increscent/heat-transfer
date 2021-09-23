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

## Sources
I used the following sources to understand the terminology and components of SWH systems:
* [https://en.wikipedia.org/wiki/Heat_transfer](https://en.wikipedia.org/wiki/Heat_transfer)
* [https://en.wikipedia.org/wiki/Solar_water_heating](https://en.wikipedia.org/wiki/Solar_water_heating)
* [https://www.energy.gov/energysaver/solar-water-heaters](https://www.energy.gov/energysaver/solar-water-heaters)
* [https://www.energy.gov/energysaver/heat-exchangers-solar-water-heating-systems](https://www.energy.gov/energysaver/heat-exchangers-solar-water-heating-systems)
* [https://www.energy.gov/energysaver/solar-water-heaters/heat-transfer-fluids-solar-water-heating-systems](https://www.energy.gov/energysaver/solar-water-heaters/heat-transfer-fluids-solar-water-heating-systems)

I used this paper to understand the variables and equations involved in SWH systems:
```
W. Li, K. Thirugnanam, W. Tushar, C. Yuen, K. T. Chew and S. Tai, "Improving the Operation of Solar Water Heating Systems in Green Buildings via Optimized Control Strategies," in IEEE Transactions on Industrial Informatics, vol. 14, no. 4, pp. 1646-1655, April 2018, doi: 10.1109/TII.2018.2797018.
```

Here's a copy: [Improving the Operation of Solar Water Heating Systems in Green Buildings...](/notes/improving-solar-water-heating-systems.pdf)
