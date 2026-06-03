# Shack-Hartmann Simulation

## Overview
This repository contains the MATLAB scripts used for simulating a specific Shack-Hartmann wavefront sensor model receiving a plane wave image.

## Prerequisites
* MATLAB (version 2020 or newer)
* 
## ⚠️ Data Setup (Required)
Because the raw height map data is too large for version control, it is hosted on the cloud. **The scripts may fail to run if you do not download the data first.**

To set up your local environment:
1. Download the simulation data from: `[Insert OneDrive Link Here]`
2. Create a new folder named `height_maps/` in the root directory of this repository.
3. Extract the downloaded files (including `height_map_doe.mat`) into that new folder.

Before running the code, your folder structure must look exactly like this:
```text
SH-simulation/
├── .gitignore
├── README.md
├── [your_main_script].m
└── height_maps/               <-- You must create this folder
    └── height_map_doe.mat     <-- Place the 473MB downloaded file here
