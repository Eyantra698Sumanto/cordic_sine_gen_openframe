![ChipFoundry Badge](https://img.shields.io/badge/ChipFoundry.io-Open%20Silicon%20Platform-darkgreen?style=for-the-badge&logo=buffer&logoColor=white)
![FOSSEE Badge](https://img.shields.io/badge/FOSSEE-Open%20Source%20EDA-purple?style=for-the-badge&logo=github&logoColor=white)
![Skywater130 Badge](https://img.shields.io/badge/Google-Skywater%20130nm-blue?style=for-the-badge&logo=google&logoColor=white)
![Microwatt Badge](https://img.shields.io/badge/Microwatt-RISC--V%20Core-orange?style=for-the-badge&logo=ibm&logoColor=white)
![OpenPOWER Badge](https://img.shields.io/badge/OpenPOWER-Architecture-1f6feb?style=for-the-badge&logo=ibm&logoColor=white)
![OpenLane Badge](https://img.shields.io/badge/OpenLane-PnR-red?style=for-the-badge&logo=opencollective&logoColor=white)
![Verilator Badge](https://img.shields.io/badge/Verilator-Simulation-yellow?style=for-the-badge&logo=gnu&logoColor=black)

# 💻📐CORDIC SINE/COSINE GENERATOR Microwatt Design Challenge

## 🧭Overview

This project implements a CORDIC (COordinate Rotation DIgital Computer) module in Verilog that computes sine and cosine of a given fixed-point angle input. It’s designed to satisfy the Microwatt Design Challenge (ChipFoundry) requirements, meaning it is:

- Open-source, with all materials needed for reproducibility

- Implementable in SKY130 using available standard cells

- Verified via RTL testbenches

- Documented clearly, including any AI involvement (if applicable)

This submission is the project proposal stage (for submission deadline Sep 22, 2025). Final implementation with all deliverables will be updated by the final deadline.

## 🛠️Motivation

- Trigonometric functions (sine, cosine) are widely used in DSP, graphics, navigation, controls.

- Software implementations are slow or costly in area/power for embedded / SoC settings.

- CORDIC gives a way to compute these functions using simple shift & add (and iterative rotations), which maps well to hardware.

### 💡Goals

- Provide an accurate, reproducible CORDIC Sine-Cosine generator suitable for integration with Microwatt or as part of an SoC in SKY130.

- Show design correctness, area/timing trade-offs, and documentation so that others can reproduce.

- Project Requirements (Microwatt Challenge Alignment)

- These are the requirements from the hackathon, and how this project intends to satisfy them:


## 📌 Project Requirements for Microwatt Challenge

These are the requirements from the hackathon, and how this project intends to satisfy them:

| Requirement                                | How this Project Meets / Plans to Meet It                                                                 |
|--------------------------------------------|------------------------------------------------------------------------------------------------------------|
| English documentation                      | README and all comments and documentation are in English.                                                  |
| Short description                          | Provided above.                                                                                            |
| Design must fit in OpenFrame User Project area | SKY130-compatible version / constraints will be used (floorplan / area estimates).                          |
| Testbenches for RTL verification           | Verilog testbench included; multiple input angles; compare outputs with reference (software) model.         |
| Constraints for STA / SDF if applicable    | Timing constraints will be defined for SKY130 implementation; provide SDF/.lib / standard cell timing data in final submission. |
| Open source license                        | MIT or Apache-2.0 license (to be placed at repo root).                                                      |
| Implemented in SKY130 / standard cells     | Adaptation to SKY130 planned; RTL is technology-agnostic except for constraints.                            |
| Reproducible implementation flow           | Use Yosys / Verilator / OpenLane or equivalent flow; provide all scripts, config files, and results.        |
| AI LLM prompt logs if used                 | If any part generated via AI (for Verilog, helpers, etc.), the logs / prompts will be included.              |
| Video/screenshots demonstrating process    | Will include in final repo: simulations, synthesis, layout (PNR), waveforms.                                |

---

## 🛠️ Detailed Design

| Aspect                  | Description                                                                                         |
|--------------------------|-----------------------------------------------------------------------------------------------------|
| Module Function          | Compute sine(x) and cosine(x) for a fixed-point angle x, using CORDIC in rotation mode.            |
| Fixed-Point Format       | Parameterizable bit-width; current version uses N-bit (e.g. 16-bit) signed angle; output with same or slightly larger bit-width to accommodate scaling / error. (Specify exact N once finalized.) |
| Number of Iterations / Stages | Parameterizable; currently “M” iterations/stages to trade off latency vs accuracy. (To fill in your chosen M.) |
| Angle Range Handling     | Handles full circle via quadrant reduction / angle normalization.                                   |
| Scaling / Gain Compensation | Either pre-scaling or post-scaling to correct for the CORDIC gain.                               |
| RTL Implementation       | Verilog, module(s): main CORDIC, angle normalization, optional scaling correction, testbench.       |
| Verification             | Simulation in Verilator / Icarus; compare output against high-precision software model (e.g. double precision sin/cos). Test with a variety of angles (0 to 360°, negative, quadrant boundaries). |
| Technology Target        | Design parameterized to be synthesizable in SKY130; standard cell compatibility; constraints to be applied. |
| Performance              | Will report latency (cycles per result), maximum clock frequency under SKY130, resource utilization (cells/gates), error metrics (max / RMS error) in final version. |

## 🗓️ Roadmap & Milestones

| Date              | Milestone                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------- |
| **Sep 22, 2025**  | Proposal submitted (this README + repo setup + basic RTL & verification)                    |
| **Mid-Oct 2025**  | Improved RTL (bit-width tuning, scaling), extended test coverage, error report              |
| **Late Oct 2025** | Synthesis / PNR in SKY130 (OpenLane / OpenFrame), include constraints, STA, SDF, cell usage |
| **Oct 31, 2025**  | Final version: full documentation, video & screenshots, license, reproducibility artifacts  |

### ***Below are the theoretical research being done for this project, it is a WIP***

## 📌 Introduction

Sine and cosine are fundamental functions that can be derived from complex functions and find applications across areas such as digital signal processing, wireless communication, biometrics, and robotics [1]. Several techniques exist for implementing hardware that computes sine and cosine, including Lookup Tables (LUTs), Maclaurin series expansion, and the CORDIC algorithm. The table lookup approach stores precomputed function values in memory for each possible input argument. This method is straightforward, as no on-the-fly calculations are needed, relying only on stored data. 

However, the size of the lookup table grows exponentially with the number of bits used to represent the output, leading to significant area requirements in hardware [2]. The Maclaurin series expresses a function as an infinite summation of its derivatives, evaluated at zero. In practice, the number of terms is chosen based on the desired accuracy [3]. For instance, achieving a maximum error of 3.90625 × 10⁻³ requires nine terms, which corresponds to a maximum error of 1.1309 × 10⁻³. This results in nine exponentiations, eight additions, and nine factorial operations. Since factorial values are constant, they can be stored in a lookup table to reduce computation. However, as bit-width increases, the hardware area consumption also rises.

The **CO**ordinate **R**otation **DI**gital **C**omputer (CORDIC) algorithm, introduced by J. E. Volder in 1959 [4], is widely used for trigonometric computations. With parameter adjustments, it can also evaluate other transcendental functions such as exponentials, logarithms, and square roots [5]. CORDIC is efficient and hardware-friendly, as it only requires additions, subtractions, bit shifts, and small table lookups. This makes it a low-cost and relatively fast approach compared to other methods. Different CORDIC architectures exist to address specific requirements: iterative designs minimize hardware area at the cost of throughput, while parallel and pipelined versions provide high speed and high throughput.

---

## 💾 Applications

A CORDIC uses only adders and bitshifts to compute the results, with the benefit that it can therefore be implemented using relatively basic hardware. Methods such as power series or table lookups usually need multiplications to be performed. If a hardware multiplier is not available, a CORDIC is generally faster, but if a multiplier can be used, other methods may be faster.

CORDICs can also be implemented in many ways, including a single-stage iterative method, which requires very few gates when compared to multiplier circuits. Also, CORDICs can compute many functions with precisely the same hardware, so they are ideal for applications with an emphasis on reduction of cost (e.g. by reducing gate counts in FPGAs) over speed. An example of this priority is in pocket calculators, where CORDICs are very frequently used.

- **Advantages:**  
  - Multiplier-less implementation  
  - Low hardware complexity  
  - Scalable precision  
  - Ideal for embedded systems, DSPs, and processors  

---

## 📐 Mathematical Modelling

The CORDIC algorithm is based on iterative **vector rotations** using predefined elementary angles. Consider the following rotations of vectors:

<img width="801" height="760" alt="image" src="https://github.com/user-attachments/assets/6da4892c-6825-4d66-b7d3-94f2b7c5f69e" />

If we were to have a computationally efficient method of rotating a vector, we can directly evaluate sine, cosine and arctan functions. However, rotation by an arbitrary angle is non-trivial (you have to know the sine and cosines, which is precisely what we don't have). We use two methods to make it easier:

Instead of performing rotations, we perform "pseudorotations", which are easier to compute.
Construct the desired angle θ from a sum of special angles, αi:

<img width="250" height="33" alt="image" src="https://github.com/user-attachments/assets/d26199b3-b311-4829-af8c-98e55d9224ad" />

The diagram belows shows a rotation and pseudo-rotation of a vector of length Ri about an angle of ai about the origin:

<img width="662.5" height="427" alt="image" src="https://github.com/user-attachments/assets/45739e7a-857d-4c24-a5c9-f9c80b63451f" />

A rotation about the origin produces the following co-ordinates:

<img width="250" height="96" alt="image" src="https://github.com/user-attachments/assets/f0d5aa1b-501c-44ab-84ea-2342dd36b50e" />

Recall the identity  <img width="225" height="39" alt="image" src="https://github.com/user-attachments/assets/7f464f73-caf4-4c18-b3ce-33771d3047db" />

Hence,

<img width="375" height="92" alt="image" src="https://github.com/user-attachments/assets/867463ee-596f-4b58-8703-325f36d6cce6" />

Our strategy will be to eliminate the factor of  <img width="150" height="46" alt="image" src="https://github.com/user-attachments/assets/9de72f4b-56ad-46bb-b4a5-28afd9ebfe15" /> and somehow remove the multiplication by **tan αᵢ**.  A pseudo-rotation produces a vector with the same angle as the rotated vector, but with a different length. In fact, the pseudo-rotation changes the length to:

<img width="330" height="61" alt="image" src="https://github.com/user-attachments/assets/79a6a9b1-bebe-4ac2-8d4a-a4ae715d3664" />

Thus we now have these co-ordinates following a pseudo-rotation:

<img width="227" height="108" alt="image" src="https://github.com/user-attachments/assets/dc77ad3b-3fe6-4bd0-a00a-fc786804ed08" />

The pseudo-rotation has succeeded in removing our length-factor, which would have required a costly division operation. However, the vector will grow by a factor of K over a sequence of n pseudo-rotations:

<img width="225" height="78" alt="image" src="https://github.com/user-attachments/assets/95927a1c-ccf0-4974-a051-05fe807094c6" />

The co-ordinates following the n pseudo-rotations are then:

<img width="360" height="213" alt="image" src="https://github.com/user-attachments/assets/518ea1ea-a806-4ed1-85b0-3fbd0959e98c" />

If the angles are always the same set, then K is fixed, and can be accounted for later. We choose these angle according to two criteria:

- We must also choose the angles so that any angle can be constructed from the sum of all them, with appropriate signs.
- We make all **tan αᵢ** a power of 2, so that the multiplication can be performed by a simple logical shift of a binary number.

The tangent function has a monotonically increasing gradient on the interval [0, π/2], so the tangent of a given angle is always less than twice the tangent of half the angle. This means that if we make the angles **αᵢ= tan⁻¹(2⁻ⁱ)**, we can satisfy both criteria. Note that the tangent function is odd, which means that to pseudo-rotate the other way, you just subtract, rather than add, the tangent of the angle.

<img width="345" height="386" alt="image" src="https://github.com/user-attachments/assets/419e5984-0d3d-44b1-9321-b8f48b255d14" />       <img width="155" height="386" alt="image" src="https://github.com/user-attachments/assets/5991f7a9-7d56-4947-b8f1-f1e32dd4f08b" />

In step i of the process, we pseudo-rotate by **dᵢ2⁻ⁱ**, where **dᵢ**  is the direction (or sign) of the rotation, which will be chosen at each step to force the angle to converge to the desired final rotation. For example, consider a rotation of 28°:

```
28 ≈ 45.0 − 26.57 + 14.04 − 7.13 + 3.58 − 1.79 + 0.90 − 0.45 + 0.22 + 0.11
   ≈ 27.91
```

The more steps we take, the better the approximation that we can make by successive rotations. Thus, we have the following iterative co-ordinate calculation:

<img width="196" height="90" alt="image" src="https://github.com/user-attachments/assets/448853a9-c94c-408e-a74d-51d4a79d4543" />

In order to achieve k bit of precision, k iterations are needed, because **tan⁻¹(2⁻ⁱ) ⪅ 2⁻ⁱ**, converging as i increases. By iterating through the above steps, the sine and cosine values ​​of the input value z0 can be obtained from the output values ​​of x and y. However, the limitation of the cordic algorithm is that the range of the input value is [-99.8829,99.8829], but in the design occasion, the target rotation angle needs to cover the entire cycle, so it is necessary to follow the symmetry of trigonometric functions on the basis of this cordic algorithm Do preprocessing.

*Extracted from [CORDIC Algorithm - Wikipedia](https://en.wikipedia.org/wiki/CORDIC)*   

---

## ⚙️ Methodology

To implement a **CORDIC Sine/Cosine Generator in Verilog**, we divide the design into the following parts:

We start by defining the input data, which includes angle, sine, and cosine values. Inputs are typically represented in fixed-point format to ensure precision. Initialize the registers for storing the intermediate values of sine, cosine, and the current angle. Set the iteration index to zero, and define the number of iterations required for convergence based on the desired precision.

### Iteration Process:

The algorithm iteratively rotates the input angle by either adding or subtracting pre-defined angles. These rotations are done using a series of bit-shift operations, representing division by powers of two. For each iteration, the algorithm decides whether to rotate clockwise or counterclockwise based on the current angle. Update the sine and cosine values after each rotation based on the direction and magnitude of the angle.

### Control Logic:

A state machine is implemented to control the flow of the algorithm, ensuring that each step of the iteration is executed in sequence. The state machine manages the computation of intermediate results and determines when the algorithm has converged to the desired precision. An Angle LUT (Look-Up Table) stores precomputed `atan(2⁻ⁱ)` values.

### Data Path Design:

The data path includes shift-adders for implementing the bit-shift operations required in each iteration. Separate blocks for sine and cosine calculations are designed, which continuously update during each iteration based on the control signals from the state machine.

### Termination Condition:

The algorithm terminates after a predefined number of iterations or when the angle has been reduced below a threshold, indicating convergence. At the end of the iterations, the sine and cosine values represent the final computed values for the given input angle.

### Output Stage:

Once the iterations are complete, the final sine and cosine values are available as outputs. These results are stored in output registers, which can be accessed by other parts of the system or external interfaces.

---

## 🛠️ Implementation

The implementation of the CORDIC sine–cosine generator in this design is based on the principle of iterative vector rotations using only shift and add operations, avoiding costly multipliers. The module is written in Verilog and structured into several key components that handle initialization, iterative rotation, and final output generation.

### 1. Parameterization and Data Width

The module is parameterized by **c_parameter**, which defines the bit-width of the input and output data. By default, it is set to 16 bits, ensuring sufficient precision for fixed-point arithmetic. The number of CORDIC stages (STG) is chosen to match this parameter, which allows the accuracy of sine and cosine results to scale directly with the data width. Inputs to the design are:

- ```clock``` → the system clock driving the sequential updates,

- ```angle``` → the target rotation angle,

- ```Xin, Yin``` → initial vector components.

- The outputs ```Xout and Yout``` represent the rotated vector after the final CORDIC iteration, effectively corresponding to cos(θ) and sin(θ) values. 

### 2. Lookup Table (LUT) for Arctangent Values

At the core of the algorithm lies a precomputed **arctan lookup table (atan_table)**, which stores values of **atan(2⁻ⁱ)** for iterations i = 0 … 30. These constants are represented in 32-bit signed fixed-point format. The lookup table ensures that each stage of the algorithm knows the precise angle of micro-rotation to apply. This allows the algorithm to converge toward the target angle using only shifts and adds. Each iteration selects whether to add or subtract a given arctangent based on the current residual angle.

The two most significant bits of the input angle indicate the quadrant (0–3). This allows the design to correctly interpret the rotation and map results back into the valid [-π/2, +π/2] domain.

### 3. Initialization (Stage 0)

The first stage prepares the initial vector (X[0], Y[0]) and the working angle Z[0] based on the input angle’s quadrant:

- If the angle is already within [-π/2, +π/2], the vector is used directly. Hence, for quadrants ```00``` and ```11```, no adjustment is needed.
- If the angle lies in another quadrant, the design applies a pre-rotation by swapping and/or negating ```Xin and Yin```. For quadrant ```01```, the vector is rotated by -90° and the angle adjusted accordingly. For quadrant ```10```, the vector is rotated by +90° with the appropriate angle correction. The effective angle ```Z[0]``` is also adjusted accordingly by adding or subtracting π/2.

This step guarantees that subsequent iterations always operate within the convergence range of the CORDIC algorithm.

### 4. Iterative Rotation Stages

The CORDIC pipeline consists of STG-1 iterative stages, implemented using a Verilog generate block. Each stage performs the following:

- Compute right-shifted versions of the vector ```(X[i] >>> i, Y[i] >>> i)```, effectively dividing by ```2⁻ⁱ```.

- Use the sign of the current residual angle ```Z[i]``` to determine the rotation direction.

- Update the vector using only additions and subtractions:

- If ```Z[i]``` < 0, the vector rotates positively.

- If ```Z[i]``` ≥ 0, the vector rotates negatively.

- Update the angle ```Z[i+1]``` by subtracting or adding the corresponding value from the ```atan_table.```

This process converges toward reducing the residual angle Z to zero while driving (X, Y) toward scaled cosine and sine values.

### 5. Final Output

After the last iteration, the results are taken directly from the final stage:

- **Xout → Approximates cos(θ) scaled by the CORDIC gain factor.**

- **Yout → Approximates sin(θ) scaled by the same gain.**

Since the CORDIC algorithm introduces a deterministic scale factor, this implementation leaves normalization to the system using the core. This design balances simplicity, precision, and hardware efficiency, making it suitable for FPGA or ASIC deployment where sine–cosine evaluation is required without multipliers


## 🔬 Verification

To validate the correctness of the CORDIC ```sine/cosine``` generator, a dedicated testbench (```cordic_test.v```) is developed. This testbench simulates the rotation mode of the CORDIC algorithm and checks whether the computed outputs (Xout, Yout) converge to the expected cosine and sine values for a given input angle.

### Testbench Structure

The testbench instantiates the CORDIC DUT (sine_cosine module) and provides it with:

- A clock signal ```CLK_100MHZ``` generated at 100 MHz using an initial block and a forever loop.

- Input values ```Xin, Yin```, and an angle θ which determine the initial rotation setup.

- A control signal ```start``` that initializes the computation at a defined simulation time.

The DUT then outputs:

- ```Xout``` → Corresponds to cos(θ) (scaled by the system’s gain factor).

- ```Yout``` → Corresponds to sin(θ) (scaled by the system’s gain factor).

### Input Initialization

The testbench begins by setting:

```Xin = VALUE = 32000/1.647``` → A pre-scaled value to account for the CORDIC gain factor (≈ 1.647). This ensures that the final outputs correspond to the true magnitude of sine and cosine.

```Yin = 0 ``` → Starts on the x-axis, ensuring rotation produces correct trigonometric values.

```angle = 0``` initially, but is later updated dynamically.

The variable ```i``` is used to iterate through degrees and compute the binary angle format:

```angle = ((1 << 32) * i) / 360```

For example, when ```i = 60```, the testbench sets the angle equivalent to 60°, properly scaled into a 32-bit representation.

### Clock and Control

The clock is generated with a ```10 ns period (100 MHz)```. The start signal is pulsed high for one cycle after initialization, then set low to begin the rotation process. On each positive clock edge, the DUT progresses through the CORDIC pipeline stages.

### Monitoring and Output

- The ```$display``` and ```$write``` system tasks are used to log simulation progress and computed values:
- At each test iteration, the angle in degrees and its binary fixed-point representation are printed.
- After a short simulation delay, the outputs ```Xout and Yout``` (cosine and sine) can be observed in the waveform (GTKWave) or logged in the terminal.

#### Expected results:

**For i = 0, Xout ≈ 32000, Yout ≈ 0.**

**For i = 60, Xout ≈ 16000, Yout ≈ 27700.**

The testbench demonstrates how CORDIC iteratively converges to the correct trigonometric results. By sweeping through different input angles, one can confirm both the functional correctness and the numerical accuracy of the design. This provides confidence that the design is ready for synthesis and GDS generation in the OpenROAD flow.

## 📊 Functional Simulation Results via EDA Playground
### Angle Width = 32, Iterations = 16
| Angle (deg) | Expected Cos | Actual Cos | % Deviation (Cos)  | Expected Sin | Actual Sin | % Deviation (Sin)  |
| ----------- | ------------ | ---------- | ------------------ | ------------ | ---------- | ------------------ |
| -180        | -32000       | -32002     | **0.006%**         | 0            | 2          | **∞ (tiny denom)** |
| -150        | -27713       | -27712     | **0.004%**         | -16000       | -16002     | **0.013%**         |
| -120        | -16000       | -16002     | **0.013%**         | -27713       | -27712     | **0.004%**         |
| -90         | 0            | -2         | **∞ (tiny denom)** | -32000       | -32001     | **0.003%**         |
| -60         | 16000        | 16002      | **0.013%**         | -27713       | -27713     | **0.000%**         |
| -30         | 27713        | 27712      | **0.004%**         | -16000       | -16002     | **0.013%**         |
| 0           | 32000        | 32001      | **0.003%**         | 0            | 0          | **0.000%**         |
| 30          | 27713        | 27711      | **0.007%**         | 16000        | 16002      | **0.013%**         |
| 60          | 16000        | 16002      | **0.013%**         | 27713        | 27711      | **0.007%**         |
| 90          | 0            | 0          | **0.000%**         | 32000        | 32001      | **0.003%**         |
| 120         | -16000       | -16002     | **0.013%**         | 27713        | 27712      | **0.004%**         |
| 150         | -27713       | -27713     | **0.000%**         | 16000        | 16002      | **0.013%**         |
| 180         | -32000       | -32001     | **0.003%**         | 0            | -2         | **∞ (tiny denom)** |

<img width="869" height="98" alt="image" src="https://github.com/user-attachments/assets/a65c5efe-29f5-4b48-93cb-a33550b7e773" />

**Simulation Waveform Output for Iteration = 16**

## 📚 References

1. [1] R. R. Teja and P. S. Reddy, “Sine/cosine generator using pipelinedcordic processor,” Proc. IACSIT International Journal of Engineeringand Techonology, vol. 3, no. 4, pp. 431–434, 2011.
2. [2] V. Kantabutra, “On hardware for computing exponential and trigono-metric functions,” Computers, IEEE Transactions on, vol. 45, no. 3, pp.328–339, 1996.
3. [3] C. K. Cockrum, “Implementation of the cordic algorithm in a digitaldown-converter,” 2008. [Online]. Available: cockrum.net/CockrumFall 2008 Final Paper.pdf
4. [4] J. E. Volder, “The CORDIC trigonometric computing technique,” Elec-tronic Computers, IRE Transactions on, no. 3, pp. 330–334, 1959.
5. [5] J. S. Walther, “A uniﬁed algorithm for elementary functions,” inProceedings of the May 18-20, 1971, spring joint computer conference.ACM, 1971, pp. 379–385.
6. Renardy, Antonius & Ahmadi, Nur & Fadila, Ashbir & Shidqi, Naufal & Adiono, Trio. (2015). FPGA implementation of CORDIC algorithms for sine and cosine generator. 10.1109/ICEEI.2015.7352460. 
7. Volder, J. E. (1959). "The CORDIC trigonometric computing technique." *IRE Transactions on Electronic Computers*  
8. Andraka, R. (1998). "A survey of CORDIC algorithms for FPGA based computers." *ACM/SIGDA*  
9. [CORDIC Algorithm - Wikipedia](https://en.wikipedia.org/wiki/CORDIC)  
10. [FPGA4Student - CORDIC in Verilog](https://www.fpga4student.com/)  

---

## 💻 Contributors
- Aditya Minocha(adityaminocha10@gmail.com), [eSim](https://esim.fossee.in/) Team, [FOSSEE](https://fossee.in/), IIT Bombay
- Sumanto Kar(jeetsumanto123@gmail.com, sumantokar@iitb.ac.in), [eSim](https://esim.fossee.in/) Team, [FOSSEE](https://fossee.in/), IIT Bombay
