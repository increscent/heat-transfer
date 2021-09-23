import fileinput
import matplotlib.pyplot as plt
import numpy as np

xdata = []
ydata = []

# Read the csv
for line in fileinput.input():
    if fileinput.isfirstline():
        continue

    fields = line.split(',')
    assert len(fields) == 2


    [time, temp] = list(map(float, map(lambda x: x.strip(), fields)))
    xdata.append(time)
    ydata.append(temp)

# Plot the data
fig = plt.figure()
ax = fig.add_subplot(1, 1, 1)
ax.plot(xdata, ydata, color='tab:blue')

# Set the limits
ax.set_xlim([0, max(xdata)])
ax.set_ylim([min(ydata) - 10, max(ydata) + 10])

ax.set_title('Temperature over time')

# Display the plot
plt.show()
