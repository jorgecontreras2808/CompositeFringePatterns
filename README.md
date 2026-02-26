# CompositeFringePatterns
The data and code that support the findings of the article "Composite fringe patterns in temporal phase unwrapping for fringe projection profilometry"

The Sructure of the project is the following:
Folders of adquired images
� Adquired composite patterns. The naming convention is AdquiredCompositeAWB, where A, indicates the number of steps(8 or 12), and B indicate the temporal frequency(2, 3, or 4) 
����AquiredComposite12W2
����AquiredComposite12W4
����AquiredComposite8W2
����AquiredComposite8W3

� Adquired High- and Low frequency patterns. The naming convention is AdquiredHighFreqA and AdquiredLowFreqA, where A, indicates the number of steps
����AquiredHighFreq12
����AquiredHighFreq6
����AquiredHighFreq8
����AquiredLowFreq12
����AquiredLowFreq6
����AquiredLowFreq8
����CalibrationFiles

� The MATLAB API includes the necessary functions for processing images, generating surfaces, and creating figures.
����MATLAB_API
    ����Classes
    ����Enums
    ����FigureGeneration
    ����Helpers
    ����PSAs
 
The main code files are as follows:
 - CompositePatternsProcessing.m
 - DualFrequencyPatternsProcessing.m
These files are responsible for processing composite fringe patterns and dual frequency patterns, respectively. The phase is retrieved and unwrapped using temporal phase unwrapping.

And
 - Simulations.m 
 is the file that simulates and compares the techniques by varying distinct parameters.