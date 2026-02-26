# CompositeFringePatterns
The data and code that support the findings of the article "Composite fringe patterns in temporal phase unwrapping for fringe projection profilometry"<br/>
<br/>
The Sructure of the project is the following:<br/>
Folders of adquired images<br/>
+- Adquired composite patterns. The naming convention is AdquiredCompositeAWB, where A, indicates the number of steps(8 or 12), and B indicate the temporal frequency(2, 3, or 4)<br/> 
+---AquiredComposite12W2<br/>
+---AquiredComposite12W4<br/>
+---AquiredComposite8W2<br/>
+---AquiredComposite8W3<br/>
<br/>
+- Adquired High- and Low frequency patterns. The naming convention is AdquiredHighFreqA and AdquiredLowFreqA, where A, indicates the number of steps<br/>
+---AquiredHighFreq12<br/>
+---AquiredHighFreq6<br/>
+---AquiredHighFreq8<br/>
+---AquiredLowFreq12<br/>
+---AquiredLowFreq6<br/>
+---AquiredLowFreq8<br/>
<br/>
+- Calibration files of the experimental system, used for image correction and units convertion.<br/>
+---CalibrationFiles<br/>
<br/>
+- The MATLAB API includes the necessary functions for processing images, generating surfaces, and creating figures.<br/>
\---MATLAB_API<br/>
    +---Classes<br/>
    +---Enums<br/>
    +---FigureGeneration<br/>
    +---Helpers<br/>
    \---PSAs<br/>
<br/>
 <br/>
The main code files are as follows:<br/>
 - CompositePatternsProcessing.m<br/>
 - DualFrequencyPatternsProcessing.m<br/>
These files are responsible for processing composite fringe patterns and dual frequency patterns, respectively. The phase is retrieved and unwrapped using temporal phase unwrapping.<br/>
<br/>
And<br/>
 - Simulations.m <br/>
 is the file that simulates and compares the techniques by varying distinct parameters.<br/>